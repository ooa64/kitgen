#!/bin/sh
# the next line restarts using tclsh \
exec wish8.6 "$0" "$@"

package require Tcl 8.6-
package require Tk

wm title . "CSV View"
wm withdraw .

array set state {}
array set option {
    -filename ""
    -filetype ""
    -encoding ""
    -theme ""
    -scale ""
    -font ""
    -width 100
    -height 30
    -limit 1000
    -bulk 100
    -debug 0
}

##nagelfar syntax %W x*

if {![dict exists [namespace ensemble configure dict -map] getdef]} {
    ##nagelfar subcmd+ dict getdef
    ##nagelfar syntax dict\ getdef x x x x*
    proc ::tcl::dict::getdef {dict args} {
        ::set keys [::lrange $args 0 end-1]
        if {[::dict exists $dict {*}$keys]} {
            return [::dict get $dict {*}$keys]
        } else {
            return [::lindex $args end]
        }
    }
    namespace ensemble configure dict -map \
        [linsert [namespace ensemble configure dict -map] end getdef ::tcl::dict::getdef]
}

proc appInit {argc argv} {
    global state option

    if {$argc % 2 == 0} {
        array set option $argv  
    } else {
        array set option [linsert $argv end-1 "-filename"]
    }
    if {![string is integer -strict $option(-width)] || $option(-width) < 50 ||
            ![string is integer -strict $option(-height)] || $option(-height) < 10} {
        error "invalid width/height option"
    }
    if {![string is integer -strict $option(-limit)] ||
            ![string is integer -strict $option(-bulk)]} {
        error "invalid bulk/limit option"
    }
    if {$option(-theme) ne ""} {
        if {$option(-theme) eq "dark"} {
            appThemeDark
        }
        ::ttk::setTheme $option(-theme) 
        option add *Toplevel*foreground [ttk::style lookup . -foreground]
        option add *Toplevel*background [ttk::style lookup . -background]
    }
    if {[string is double -strict $option(-scale)]} {
        set scale [expr {min( max( $option(-scale), 0.2 ), 5.0 )}]
        if {[tk windowingsystem] eq "win32"} {
            tk scaling $scale
        } else {
            foreach font {Default Text Fixed Heading Caption Tooltip Icon Menu} {
                set size [font configure Tk${font}Font -size]
                font configure Tk${font}Font -size [expr {int($scale*$size)}]
            }
        }
    }
    if {$option(-font) eq "fixed"} {
        ttk::style configure Treeview -font TkFixedFont
    } elseif {$option(-font) ne ""} {
        ttk::style configure Treeview -font [font create TkCustomFont -family $option(-font)]
    }
    set font [ttk::style lookup Treeview -font]
    if {$font eq ""} {
        set font TkDefaultFont
    }
    set state(font:width) [expr {[font measure $font "X"] + 1}]
    set state(font:height) [expr {[font metrics $font -linespace] + 2}]

    ttk::style configure Treeview -rowheight $state(font:height)

    bind Treeview <Home>      {%W xview moveto 0}
    bind Treeview <End>       {%W xview moveto 1}
    bind Treeview <Left>      {%W xview scroll -$::state(font:width) unit}
    bind Treeview <Right>     {%W xview scroll $::state(font:width) unit}
    bind Treeview <<Copy>> {
        clipboard clear -displayof %W
        foreach i [%W selection] {
            clipboard append -displayof %W [join [%W item $i -values] \t]\n
        }
    }
    bind Treeview <<SelectPrevLine>> {
        if {[set i [%W prev [%W focus]]] ne ""} {
           %W selection add [list $i]; %W focus $i; %W see $i
        }
    }
    bind Treeview <<SelectNextLine>> {
        if {[set i [%W next [%W focus]]] ne ""} {
           %W selection add [list $i]; %W focus $i; %W see $i
        }
    }
    bind Treeview <<SelectAll>> {%W selection set [%W children {}]}
    bind Treeview <<SelectNone>> {%W selection remove [%W selection]}

    bind TButton <Left>        {focus [tk_focusPrev %W]}
    bind TButton <Right>       {focus [tk_focusNext %W]}
    bind TButton <Up>          {focus [tk_focusPrev %W]}
    bind TButton <Down>        {focus [tk_focusNext %W]}
    bind TButton <Return>      {%W invoke; break}

    bind Button <Left>        {focus [tk_focusPrev %W]}
    bind Button <Right>       {focus [tk_focusNext %W]}
    bind Button <Up>          {focus [tk_focusPrev %W]}
    bind Button <Down>        {focus [tk_focusNext %W]}
    bind Button <Return>      {%W invoke; break}

    option add *Menu*TearOff off

    if {$option(-debug)} {
        catch {console show}
        catch {package require tkcon; bind all <F9> {tkcon show}}
    }
    debuglog {startup option: [array get option]}
}

proc appAbout {} {
    set packages {}
    lappend packages [list Tcl [package require Tcl]]
    lappend packages [list Tk [package require Tk]]
    foreach p {tclcsv tcldbf xlsreader ooxml} {
        ##nagelfar ignore Non constant package require
        if {![catch {package require $p} v]} {
            lappend packages [list $p $v]
        }
    }
    tk_messageBox -type "ok" -title "About" -message "CSV View 1.0" \
            -detail [string cat \n [join $packages \n] \n]
}

proc appThemeDark {} {
    array set colors {
        -background #33393b
        -foreground #ffffff
        -selectbackground #215d9c 
        -selectforeground #ffffff
        -fieldbackground #191c1d
        -bordercolor #000000
        -insertcolor #ffffff
        -troughcolor #191c1d
        -focuscolor #215d9c
        -lightcolor #5c6062
        -darkcolor #232829
    }
    ttk::style theme create dark -parent clam -settings {
        ttk::style configure . {*}[array get colors]
        ttk::style configure TCheckbutton -indicatormargin {1 1 4 1} \
                -indicatorbackground $colors(-fieldbackground) \
                -indicatorforeground $colors(-foreground)
        ttk::style configure TButton \
                -anchor center -width -11 -padding 5 -relief raised
        ttk::style map TEntry \
                -bordercolor [list focus $colors(-selectbackground)]
        ttk::style map TCombobox \
                -bordercolor [list focus $colors(-selectbackground)]
        ttk::style configure ComboboxPopdownFrame \
                -relief solid -borderwidth 1
        ttk::style configure Heading \
                -font TkHeadingFont -relief raised
        ttk::style configure Treeview \
                -background $colors(-fieldbackground)
        ttk::style map Treeview \
                -background [list selected $colors(-selectbackground)] \
                -foreground [list selected $colors(-selectforeground)] \
                -bordercolor [list focus $colors(-selectbackground)]
    }
    option add *TCombobox*Listbox.foreground $colors(-foreground)
    option add *TCombobox*Listbox.background $colors(-fieldbackground)
    option add *TCombobox*Listbox.selectForeground $colors(-selectforeground)
    option add *TCombobox*Listbox.selectBackground $colors(-selectbackground)
    option add *Canvas.background $colors(-background)
    option add *Canvas.highlightColor $colors(-selectbackground)
    option add *Canvas.highlightBackground $colors(-background)
    option add *Canvas.highlightThickness 2
}

proc appToplevelBindings {toplevel} {
    if {[tk windowingsystem] eq "win32"} {
        bind $toplevel <Control-Key> {+appWindowsCopyPasteFix %W %K %k}
    }
}

proc appWindowsCopyPasteFix {W K k} {
    switch $k {
        67 {if {"$K" ni {"C" "c"}} {event generate $W <<Copy>>}}
        86 {if {"$K" ni {"V" "v"}} {event generate $W <<Paste>>}}
        88 {if {"$K" ni {"X" "x"}} {event generate $W <<Cut>>}}
    }
}

proc appToplevelCreate {toplevel} {
    if {[winfo exists $toplevel]} {
        wm deiconify $toplevel
        return 0
    }
    toplevel $toplevel -height 1
    $toplevel configure -width [winfo width [winfo parent $toplevel]]
    return 1
}

# NOTE: replacement for
# tk::PlaceWindow $toplevel "widget" [winfo parent $toplevel]
# tk::SetFocusGrab $tolevel $grabfocus
proc appToplevelPlace {toplevel title {grabfocus {}}} {
    global state
    set x $state(font:width)
    set y $state(font:height)

    set rootx [winfo rootx [winfo parent $toplevel]]
    set rooty [winfo rooty [winfo parent $toplevel]]
    wm geometry $toplevel +[expr {$rootx+8*$x+$x}]+[expr {$rooty+$y+4}]
    wm title $toplevel $title
    wm deiconify $toplevel
    update idletasks
    if {$grabfocus ne ""} {
        grab $toplevel
        focus $grabfocus
    }
}

proc windowCreate {toplevel} {
    global state option

    set state(window) [expr {$toplevel eq "." ? "" : $toplevel}]

    set x $state(font:width)
    set y $state(font:height)
    set w $state(window)

    menu $w.menu
    menu $w.menu.file
    menu $w.menu.view
    menu $w.menu.help
    $w.menu add cascade -menu $w.menu.file -label "File"
    $w.menu add cascade -menu $w.menu.view -label "View"
    $w.menu add cascade -menu $w.menu.help -label "Help"
    $w.menu.file add command -command {fileOpen} -label "Open" -accelerator "Ctrl-O"
    $w.menu.file add separator
    $w.menu.file add command -command {windowClose} -label "Quit" -accelerator "Ctrl-Q" 
    $w.menu.view add command -command {infoCreate} -label "Info" -accelerator "Ctrl-I"
    $w.menu.view add command -command {recordCreate} -label "Record" -accelerator "Enter"
    $w.menu.view add separator
    $w.menu.view add command -command {findCreate} -label "Find" -accelerator "Ctrl-F"
    $w.menu.view add command -command {findNext 0} -label "Find Prev" -accelerator "Shift-F3"
    $w.menu.view add command -command {findNext 1} -label "Find Next" -accelerator "F3"
    $w.menu.help add command -command {appAbout} -label "About"
    $toplevel configure -menu $w.menu -takefocus 0 -bg [ttk::style lookup . -background]

    sheetCreate 50 10

    wm protocol $toplevel WM_DELETE_WINDOW {windowClose}
    wm minsize $toplevel [expr {50*$x}] [expr {10*$y}]
    wm maxsize $toplevel [winfo vrootwidth $toplevel] [winfo vrootheight $toplevel]
    wm geometry $toplevel [format "%dx%d+%d+%d" \
            [expr {$option(-width)*$x}] [expr {$option(-height)*$y}] \
            [expr {max(([winfo screenwidth $toplevel]-$option(-width)*$x)/2,0)}] \
            [expr {max(([winfo screenheight $toplevel]-$option(-height)*$y)/2,0)}]]
    appToplevelBindings $toplevel
    windowToplevelBindings $toplevel
    wm deiconify $toplevel
    raise $toplevel
    focus $toplevel
}

proc windowClose {} {
    global state

    if {[info exists state(file:handle)]} {
        fileClose
    }
    exit
}

proc windowToplevelBindings {toplevel} {
    if {[tk windowingsystem] eq "win32"} {
        # NOTE: use keycode bindings to ignore keyboard mode on windows
        ##nagelfar ignore +2 String argument to switch is constant
        bind $toplevel <Control-Key> \
                {+switch %k 79 fileOpen 81 windowClose 73 infoCreate 70 findCreate}
    } else {
        foreach {k c} {o fileOpen q windowClose i infoCreate f findCreate} {
            bind $toplevel <Control-$k> [list $c]
            bind $toplevel <Control-[string toupper $k]> [list $c]
        }
    }
    bind $toplevel <F3> {findNext 1}
    bind $toplevel <Shift-F3> {findNext 0}
}

proc sheetCreate {width height} {
    global state
    set w $state(window)

    set state(item:base) ""
    set state(item:first) ""
    set state(item:last) ""
    set state(find:string) ""
    set state(find:field) "all"
    set state(find:nocase) "0"
    set state(find:regexp) "0"

    ttk::treeview $w.tree -height $height \
            -yscrollcommand "$w.vbar set" -xscrollcommand "$w.hbar set"
    ttk::scrollbar $w.vbar -orient vertical -command "$w.tree yview"
    ttk::scrollbar $w.hbar -orient horizontal -command "$w.tree xview"
    ttk::label $w.status 
    grid $w.tree $w.vbar -sticky "news"
    grid $w.hbar "x" -sticky "we"
    grid $w.status - -sticky "w"

    grid columnconfigure [winfo parent $w.tree] 0 -weight 1
    grid rowconfigure [winfo parent $w.tree] 0 -weight 1

    after idle [list focus -force $w.tree]
}

proc sheetDestroy {} {
    global state
    set w $state(window)

    if {[winfo exists $w.tree]} {
        destroy $w.tree $w.vbar $w.hbar $w.status
    }
}

proc sheetBindings {} {
    global state
    set w $state(window)
    set x $state(font:width)

    bind $w.tree <Return> {+recordCreate}
    bind $w.tree <Double-1> {+recordCreate}
    bind $w.tree <<TreeviewSelect>> {+recordLoad focus}

    bind $w.tree <Control-Home> {sheetSelect $::state(item:first); break}
    bind $w.tree <Control-End> {sheetSelect $::state(item:last); break}

    bind $w.tree <Prior> {after idle {sheetSelect [%W identify item {*}$::state(item:base)]}}
    bind $w.tree <Next> {after idle {sheetSelect [%W identify item {*}$::state(item:base)]}}

    bind $w.tree <Down> {+fileLoadContinue focus}
    bind $w.tree <Next> {+fileLoadContinue focus}
    bind $w.vbar <ButtonRelease-1> {+fileLoadContinue bar %x %y}
}

proc sheetSelect {item} {
    global state
    set w $state(window)

    if {$item ne ""} {
        $w.tree see $item
        $w.tree focus $item
        $w.tree selection set [list $item]
    }
}

proc sheetRecordNo {item} {
    global state
    set w $state(window)

    regsub -all {[^\d]*} [$w.tree "item" $item -text] ""
}

proc recordCreate {} {
    global state
    set w $state(window)
    set x $state(font:width)
    set y $state(font:height)

    if {![info exists state(file:handle)]} {
        return
    }
    if {![appToplevelCreate $w.record]} {
        return
    }
    wm withdraw $w.record

    canvas $w.record.c -height 1 -width 1 -yscrollcommand "$w.record.v set"
    ttk::scrollbar $w.record.v -command "$w.record.c yview"
    ttk::frame $w.record.c.f -padding 4
    foreach c [lrange [$w.tree cget -columns] 0 end-1] {
        ttk::label $w.record.c.f.l$c -text [$w.tree heading $c -text] -anchor "e"
        ttk::entry $w.record.c.f.e$c -width 50 -state readonly
        grid $w.record.c.f.l$c $w.record.c.f.e$c - - -sticky "we" -padx 4 -pady 2
    }
    grid columnconfigure $w.record.c.f 1 -weight 1

    ttk::frame $w.record.f
    ttk::button $w.record.f.b1 -text "Prev" -command {recordLoad "prev"}
    ttk::button $w.record.f.b2 -text "Next" -command {recordLoad "next"}
    ttk::button $w.record.f.b3 -text "Close" -command [list destroy $w.record]
    pack $w.record.f.b3 $w.record.f.b2 $w.record.f.b1 -side "right" -padx 4 -pady 4
    grid $w.record.c $w.record.v -sticky "news"
    grid $w.record.f - -sticky "we"
    grid columnconfigure $w.record 0 -weight 1
    grid rowconfigure $w.record 0 -weight 1

    update idletasks
    $w.record.c.f configure -width [winfo reqwidth $w.record.c.f] -height [winfo reqheight $w.record.c.f]
    $w.record.c create window 0 0 -anchor nw -window $w.record.c.f
    $w.record.c configure -scrollregion [$w.record.c bbox all] \
            -height [expr {20*$y}] -width [winfo reqwidth $w.record.c.f]

    bind $w.record <Escape> [list destroy $w.record]
    wm transient $w.record [winfo parent $w.record]

    windowToplevelBindings $w.record
    appToplevelBindings $w.record
    appToplevelPlace $w.record "DBF Record"
    wm maxsize $w.record [winfo width $w.record] [lindex [wm maxsize $w.record] 1]

    recordLoad "focus"
}

proc recordDestroy {} {
    global state
    set w $state(window)

    if {[winfo exists $w.record]} {
        destroy $w.record
    }
}

proc recordLoad {position} {
    global state
    set w $state(window)
 
    if {![winfo exists $w.record]} {
        return
    }
    set item [$w.tree focus]
    if {$item eq ""} {
        destroy $w.record
    }
    switch -- $position {
        "first" {set item $state(item:first)}
        "last" {set item $state(item:last)}
        "next" {set item [$w.tree next $item]}
        "prev" {set item [$w.tree prev $item]}
    }
    if {$item eq ""} {
        fileLoadContinue "focus"
        return
    }
    if {$position ne "focus"} {
        sheetSelect $item
        update
        return
    }
    set r [sheetRecordNo $item]
    set c 0
    foreach v [$w.tree "item" $item -values] {
        update
        if {![winfo exists $w.record] || $item ne [$w.tree focus]} {
            return
        }
        incr c
        if {[$w.record.c.f.e$c get] ne $c} {
            $w.record.c.f.e$c configure -state normal
            $w.record.c.f.e$c delete 0 end
            $w.record.c.f.e$c insert end $v
            $w.record.c.f.e$c configure -state readonly
        }
    }

    wm title $w.record "CSV Record - $r"
}

proc findCreate {} {
    global state
    set w $state(window)

    if {![info exists state(file:handle)]} {
        return
    }
    if {![appToplevelCreate $w.find]} {
        return
    }

    ttk::label $w.find.l1 -text "Find" -anchor "e"
    ttk::entry $w.find.string -textvariable ::state(find:string) -width 50
    grid $w.find.l1 $w.find.string - - - -sticky "we" -padx 4 -pady 2

    ttk::label $w.find.l2 -text "Field" -anchor "e"
    ttk::combobox $w.find.field -state readonly -textvariable ::state(find:field) \
            -values [concat [list "all"] [lmap f $state(file:fields) {lindex $f 0}]]

    grid $w.find.l2 $w.find.field -sticky "we" -padx 4 -pady 2

    ttk::checkbutton $w.find.nocase -variable ::state(find:nocase) -text "ignore case"
    grid x $w.find.nocase -sticky "w" -padx 4 -pady 2

    ttk::checkbutton $w.find.regexp -variable ::state(find:regexp) -text "regular expression"
    grid x $w.find.regexp -sticky "w" -padx 4 -pady 2

    ttk::label $w.find.status
    ttk::button $w.find.b1 -text "Prev" -command [list findNext 0]
    ttk::button $w.find.b2 -text "Next" -command [list findNext 1]
    ttk::button $w.find.b3 -text "Close" -command [list destroy $w.find]
    grid $w.find.status - $w.find.b1 $w.find.b2 $w.find.b3 -sticky "e" -padx 4 -pady 2
    grid configure $w.find.status -sticky "w"

    bind $w.find.string <Return> [list findNext 1]
    bind $w.find <Escape> [list destroy $w.find]
    wm transient $w.find [winfo parent $w.find]

    appToplevelPlace $w.find "DBF Find" $w.find.string
    appToplevelBindings $w.find
}

proc findNext {forward {item ""}} {
    global state
    set w $state(window)

    if {![info exists state(file:handle)]} {
        return
    }
    if {![winfo exists $w.find]} {
        return
    }
    if {$state(find:string) eq ""} {
        return
    }
    $w.find.b1 configure -state disabled
    $w.find.b2 configure -state disabled
    bind $w.find.string <Return> {}

    set i [lsearch -index 0 $state(file:fields) $state(find:field)]
    if {$i >= 0} {
        set columns [expr {$i + 1}]
    } else {
        set columns [lrange [$w.tree cget -columns] 0 end-1]
    }

    if {$item eq ""} {
        set item [$w.tree focus]
    }
    if {$item eq ""} {
        set nextitem [expr {$forward ? $state(item:first) : $state(item:last)}]
    } else {
        set nextitem [expr {$forward ? [$w.tree next $item] : [$w.tree prev $item]}]
    }

    while {true} {
        update

        if {![winfo exists $w.find]} {
            return
        }
        if {$forward && $nextitem eq ""} {
            set nextitem [$w.tree next $item]
            if {$nextitem eq "" && [fileLoadContinue "anyway"]} {
                # NOTE: after idle stops both processes (loading and searching)
                after 1 [list findNext $forward $item]
                return
            }
        }
        if {$nextitem eq ""} {
            destroy $w.find
            tk_messageBox -parent [winfo toplevel $w.tree] \
                    -icon "info" -title "Find" -message "Not found"
            break
        }
        set item $nextitem

        $w.find.status configure -text [string cat "Row " [sheetRecordNo $item]]

        foreach c $columns {
            set s [$w.tree set $item $c]
            if {$state(find:regexp)} {
                if {$state(find:nocase)} {
                    set result [regexp -nocase $state(find:string) $s]
                } else {
                    set result [regexp $state(find:string) $s]
                }
            } else {
                if {$state(find:nocase)} {
                    set result [string first [string toupper $state(find:string)] [string toupper $s]]
                } else {
                    set result [string first $state(find:string) $s]
                }
                incr result
            }
            if {$result} {
                destroy $w.find
                sheetSelect $item
                return
            }
        }
        set nextitem [expr {$forward ? [$w.tree next $item] : [$w.tree prev $item]}]
    }
}

proc infoCreate {} {
    global state option
    set w $state(window)
    set x $state(font:width)

    if {![info exists state(file:handle)]} {
        return
    }
    if {![appToplevelCreate $w.info]} {
        return
    }

    set info [list \
        "File name" [file tail $state(file:name)] \
        "File size" [file size $state(file:name)] \
        "File type" $state(file:type) \
        "Records"   $state(file:rows)]
    set info [concat $info $state(file:info)]
    set i 0
    foreach {n v} $info {
        ttk::label $w.info.il$i -text $n -anchor "e"
        ttk::entry $w.info.ie$i
        grid $w.info.il$i $w.info.ie$i -sticky "we" -padx 4 -pady 2
        $w.info.ie$i insert end $v
        $w.info.ie$i configure -state readonly
        incr i
    }
    set options $state(file:options)
    if {[dict exists $options "-encoding"]} {
        ttk::label $w.info.l-encoding -text "-encoding" -anchor "e"
        ttk::combobox $w.info.e-encoding -values [lsort -dictionary [encoding names]]
        grid $w.info.l-encoding $w.info.e-encoding -sticky "we" -padx 4 -pady 2
        $w.info.e-encoding insert end [dict get $options "-encoding"]
        $w.info.e-encoding configure -state readonly
        dict unset options "-encoding"
        incr i
    }
    foreach {n v} $options {
        ttk::label $w.info.l$n -text $n -anchor "e"
        ttk::entry $w.info.e$n
        grid $w.info.l$n $w.info.e$n -sticky "we" -padx 4 -pady 2
        $w.info.e$n insert end $v
        incr i
    }

    ttk::button $w.info.ok -text "OK" -command {infoOk}
    grid "x" $w.info.ok -sticky "e" -padx 4 -pady 2

    grid columnconfigure $w.info 1 -weight 1
    grid rowconfigure $w.info 5 -weight 1
    bind $w.info <Escape> [list destroy $w.info]

    appToplevelPlace $w.info "File Info" $w.info.ok
    appToplevelBindings $w.info
}

proc infoOk {} {
    global state option
    set w $state(window)

    if {![winfo exists $w.info]} {
        return
    }

    set changed false
    foreach {n v} $state(file:options) {
        set v [$w.info.e$n get]
        if {$v ne [dict get $state(file:options) $n]} {
            dict set state(file:options) $n $v
            set changed true
        }
    }

    destroy $w.info

    if {$changed} {
        after cancel $state(file:loading)
        set state(file:loading) ""
        fileReload
        recordLoad "focus"
    }
}

proc fileOpen {{filetype ""} {filename ""} args} {
    global state option
    set w $state(window)
    set x $state(font:width)

    if {$filename eq ""} {
        debuglog {open $filetype $filename}
        set filename [tk_getOpenFile -parent [winfo parent $w.tree] \
                -filetypes {
                    {"CSV files" .csv}
                    {"XLS files" .xls}
                    {"XLSX files" .xlsx}
                    {"DBF files" .dbf}
                    {"All files" *}
                }]
        if {$filename eq ""} {
            return
        }
    }
    if {$filetype eq ""} {
        switch -nocase -glob $filename {
            *.csv {set filetype "csv"}
            *.xls {set filetype "xls"}
            *.xlsx {set filetype "xlsx"}
            *.dbf {set filetype "dbf"}
            default {set filetype "csv"}
        }
    }

    fileClose

    $w.status configure -text "Opening $filename"
    update idletasks

    try {
        fileOpen:$filetype $filename {*}[expr {[llength $args] ? $args : [array get option]}]
    } on error {message} {
        fileClose
        bgerror "Error opening $filetype file\n$filename\n$message"
        return
    } finally {
        $w.status configure -text ""
    }

    set state(file:type) $filetype
    set state(file:name) [file normalize $filename]
    set state(file:limit) $option(-limit)
    set state(file:loading) ""
    set state(file:count) 0

    wm title [winfo toplevel $w.tree] \
            [string cat "CSV View - " [file nativename $state(file:name)]]

    # NOTE: use synthetic column names (1,2,...) to avoid duplicated names

    set fields $state(file:fields)
    set columns [dict create]

    set c 0
    $w.tree configure -columns [concat [lmap f $fields {incr c}] [list \#end]]
    $w.tree column \#0 -width [expr {8*$x+$x}] -minwidth [expr {8*$x+$x}] -stretch 0 -anchor "e"
    $w.tree column \#end -minwidth 0 -width 0 -stretch 1

    set c 0
    foreach f $fields {
        incr c
        lassign $f n a -
        $w.tree heading $c -text $n
        $w.tree column $c -stretch 0 -anchor $a
        dict set columns $c [string length $n]
    }

    fileLoad

    foreach row [$w.tree children {}] {
        foreach c [dict keys $columns] v [$w.tree item $row -values] {
            if {$c ne ""} {
                dict set columns $c [expr {max( [dict get $columns $c], [string length $v] )}]
            }
        }
    }
    foreach c [dict keys $columns] {
        $w.tree column $c -width [expr {min( [dict get $columns $c], 50 ) * $x + 8}]
    }

    after idle [list focus $w.tree]

    sheetBindings
    sheetSelect $state(item:first)
}

proc fileClose {} {
    global state

    if {![info exists state(file:handle)]} {
        return
    }
    if {[info exists state(file:loading)]} {
        after cancel $state(file:loading)
        set state(file:loading) ""
    }

    wm title [winfo toplevel $state(window).tree] "CSV View"

    recordDestroy
    sheetDestroy

    if {[info exists state(file:type)]} {
        fileClose:$state(file:type)
    }

    array unset state file:*

    sheetCreate 50 10
}

proc fileReload {} {
    global state

    if {![info exists state(file:handle)]} {
        return
    }
    fileOpen $state(file:type) $state(file:name) {*}$state(file:options)
}

proc fileLoad {{update ""}} {
    global state option
    set w $state(window)

    set item ""
    set count $state(file:count)
    set maxcount [expr {$count + $option(-bulk)}]
    if {$state(file:limit) > 0} {
        set maxcount [expr {min( $maxcount, $state(file:limit) )}]
    }
    while {$count < $maxcount} {
        set values [fileRow:$state(file:type) $count]
        if {[fileEof:$state(file:type) $count]} {
            break
        }
        incr count
        if {[llength $values] > [llength $state(file:fields)]} {
            # NOTE: add missing fields (see: fileOpen)
            set fields $state(file:fields)
            for {set c [llength $fields]} {$c < [llength $values]} {incr c} {
                lappend fields [list $c "w"]
            }
            set c 0
            $w.tree configure -columns [concat [lmap f $fields {incr c}] [list \#end]]
            set c 0
            foreach f $fields {
                incr c
                lassign $f n a -
                $w.tree heading $c -text $n
                $w.tree column $c -stretch 0 -anchor $a
            }            
            set state(file:fields) $fields
        }
        set item [$w.tree insert {} end -text $count -values $values]
    }
    if {$state(file:count) == 0} {
        set state(item:first) [lindex [$w.tree children {}] 0]
        set state(item:base) [lmap i [lrange [$w.tree bbox $state(item:first)] 0 1] {incr i}]
    }
    set state(item:last) $item
    set state(file:count) $count

    $w.status configure -text "$count/$state(file:rows) rows loaded"

    if {$update ne ""} {
        update
    }
    if {![fileEof $count]} {
        # NOTE: after idle breaks sync with find process
        set state(file:loading) [after 1 {fileLoad "update"}]
    } else {
        set state(file:loading) ""
    }
}

proc fileLoadContinue {what args} {
    global state option
    set w $state(window)

    if {$state(file:loading) ne ""} {
        # NOTE: loading is scheduled
        return true
    }
    if {![fileEof $state(file:count)]} {
        # NOTE: limit is not reached
        return true
    }
    if {[fileEof:$state(file:type) $state(file:count)]} {
        # NOTE: real EOF reached
        return false
    }
    switch -- $what {
        "bar" {
            if {[lindex [$w.vbar get] 1] < 1.0} {
                return true
            }
        }
        "focus" {
            if {[$w.tree next [$w.tree focus]] ne {}} {
                return true
            }
        }
        default {}
    }
    switch -- [tk_dialog $w.dialog "Question" "Load more rows?" "" \
            2 "Yes, $option(-limit) rows" "Yes, all rows" "   Cancel   "] {
        0 {
            set state(file:limit) [expr {$state(file:limit) + $option(-limit)}]
        }
        1 {
            set state(file:limit) 0 ;# unlimited
        }
        default {
            return false
        }
    }
    set state(file:loading) [after idle {fileLoad "update"}]

    return true
}

proc fileEof {row} {
    global state

    expr {[fileEof:$state(file:type) $row] || \
            ($state(file:limit) > 0 && $row >= $state(file:limit))}
}

proc fileOpen:csv {filename args} {
    package require tclcsv
    global state option

    set state(file:handle) [open $filename]
    set encoding [dict getdef $args "-encoding" ""]
    if {$encoding eq ""} {
        set encoding [fconfigure $state(file:handle) -encoding]
        fconfigure $state(file:handle) -encoding "binary"
        fconfigure $state(file:handle) -encoding \
                [getencoding [read $state(file:handle) 4096] $encoding]
        seek $state(file:handle) 0
    } else {
        fconfigure $state(file:handle) -encoding $encoding
    }
    set encoding [fconfigure $state(file:handle) -encoding]

    set csvoptions {
        -comment -delimiter -doublequote -escape -quote
        -skipleadingspace -excludefields -includefields -skipblanklines -skiplines -startline
    }
    try {
        set options [tclcsv::sniff -delimiters [list "," ";" ":" "|" "\t"] $state(file:handle)]
        if {[dict getdef $options "-escape" ""] ni {"\\"}} {
            dict unset options "-escape"
        }
        if {[dict getdef $options "-comment" ""] ni {"#" ";"}} {
            dict unset options "-comment"
        }
        debuglog {sniff options $options}
    } on error {message} {
        set options {-delimiter , -quote \"}
        debuglog {sniff error $message, using $options}
    }
    set options [dict merge $options \
            [dict filter $args script {n v} {expr {$n in $csvoptions && $v ne ""}}]]

    set nlens 0
    set nrows 0
    set nfields 0
    set delimiter [dict get $options "-delimiter"]
    while {[gets $state(file:handle) line] >= 0} {
        if {$line eq ""} {continue}
        set n [llength [split $line $delimiter]]
        set nfields [expr {max($nfields, $n)}]
        incr nlens [string length $line]
        incr nrows
        if {$nrows > 100} break
    }
    fconfigure $state(file:handle) -blocking 0
    seek $state(file:handle) 0
    debuglog {file config [fconfigure $state(file:handle)]}
    debuglog {file probe nlens $nlens, nrows $nrows, nfields $nfields}
    if {$nrows == 0} {
        error "can't process file with empty header"
    }

    set fields {}
    set skipline false
    set line [gets $state(file:handle)]
    seek $state(file:handle) 0
    if {[regexp {^#\s*DBF\s.*\mSTRUCT\s([^/]+)\s/STRUCT\M} $line => struct]} {
        foreach c [split $struct ,] {
            if {[regexp {^ *(\w+) +([CNDL]) +(\d+)( +(\d+))? *$} $c => cname ctype cwidth - cdec]} {
                lappend fields [list $cname [expr {$ctype in {F M N} ? "e" : "w"}] $cwidth]
            } else {
                break
            }
        }
        set skipline true
    } else {
        try {
            set f [tclcsv::sniff_header {*}$options $state(file:handle)]
            set i 0
            foreach ctype [lindex $f 0] cname [lindex $f 1] {
                incr i
                lappend fields [list \
                        [expr {$cname eq "" ? $i : [string trim $cname]}] \
                        [expr {$ctype in {integer real} ? "e" : "w"}]]
            }
            set skipline [llength [lindex $f 1]]
            debuglog {sniff_header fields $fields}
        } on error {message} {
            if {$nfields == 0} {
                error $message
            }
            for {set i 0} {$i < $nfields} {} {
                lappend fields [list [incr i] "w"]
            }
            debuglog {sniff_header error $message, using $fields}
        }
    }
    if {$skipline} {
        dict lappend options "-skiplines" 0
    }
    set state(file:rows) [expr {[file size $filename] / ($nlens / $nrows) - !!$skipline}]
    set state(file:info) {}
    set state(file:fields) $fields
    set state(file:options) [dict merge [list -encoding $encoding] \
            [join [lmap n $csvoptions {list $n ""}]] $options]
    set state(file:reader) [tclcsv::reader new {*}$options $state(file:handle)]
}

proc fileClose:csv {} {
    global state

    if {[info exists state(file:reader)]} {
        $state(file:reader) destroy
    }
    if {[info exists state(file:handle)]} {
        close $state(file:handle)
    }
}

proc fileRow:csv {row} {
    global state

    set value [$state(file:reader) next]
    if {[$state(file:reader) eof]} {
        set state(file:rows) $row
        return {}
    }
    if {$row >= $state(file:rows)} {
        set state(file:rows) [expr {$row+1}]
    }
    return $value
}

proc fileEof:csv {row} {
    global state

    $state(file:reader) eof
}

proc fileOpen:dbf {filename args} {
    package require tcldbf 2.1-
    global state option

    dbf state(file:handle) -open $filename -readonly
    if {[dict getdef $args "-encoding" ""] ne ""} {
        $state(file:handle) encoding [dict get $args "-encoding"]
    }
    set state(file:rows) [$state(file:handle) info records]
    set state(file:info) [list "Codepage" [$state(file:handle) codepage]]
    set state(file:fields) {}
    set state(file:dbf:fields) {}
    foreach f [$state(file:handle) fields] {
        lappend state(file:fields) [list \
                [lindex $f 0] \
                [expr {[lindex $f 2] in {F M L N} ? "e" : "w"}] \
                [lindex $f 3]]
        lappend state(file:dbf:fields) $f
    }
    set state(file:options) [list -encoding [$state(file:handle) encoding]]
}

proc fileClose:dbf {} {
    global state

    if {[info exists state(file:handle)]} {
        $state(file:handle) forget
    }
}

proc fileRow:dbf {row} {
    global state

    expr {$row >= [$state(file:handle) info records] ? \
            {} : [$state(file:handle) record $row]}
}

proc fileEof:dbf {row} {
    global state

    expr {$row >= [$state(file:handle) info records]}
}

proc fileOpen:xls {filename args} {
    package require xlsreader 1.0.4-
    global state option

    set params {}
    if {[dict getdef $args "-encoding" ""] ne ""} {
        lappend params -encoding [dict get $args "-encoding"]
    }
    set data [xlsreader read $filename {*}$params]
    set sheet [dict getdef $args "-sheet" 1]
    if {![string is integer -strict $sheet] || $sheet <= 0 || $sheet > [llength $data]} {
        error "Invalid sheet $sheet, must be a number from 1 to [llength $data]"
    }
    set state(file:handle) [lindex $data $sheet-1]
    set state(file:rows) [llength $state(file:handle)]
    set state(file:info) [list "Sheets" [llength $data]]
    set state(file:options) [list -sheet $sheet -encoding [dict getdef $args "-encoding" ""]]
    set state(file:fields) {} ;# TODO: list of fields: {field anchor ?size?}
    unset data
}

proc fileClose:xls {} {
}

proc fileRow:xls {row} {
    global state

    expr {$row >= $state(file:rows) ? \
            {} : [lindex $state(file:handle) $row]}
}

proc fileEof:xls {row} {
    global state

    expr {$row >= [llength $state(file:handle)]}
}


proc fileOpen:xlsx {filename args} {
    package require ooxml
    global state

    set data [ooxml::xl_read $filename -valuesonly -datefmt "%Y-%m-%d"]
    set sheets [dict get $data "sheets"]
    set sheet [dict getdef $args "-sheet" 1]
    if {![string is integer -strict $sheet] || $sheet <= 0 || $sheet > [llength $sheets]} {
        error "Invalid sheet $sheet, must be a number from 1 to [llength $sheets]"
    }
    set state(file:sheet) [expr {$sheet-1}]
    set state(file:handle) [dict filter $data key "$state(file:sheet),*"]
    set state(file:rows) [expr {[dict get $state(file:handle) "$state(file:sheet),max_row"] + 1}]
    set state(file:cols) [expr {[dict get $state(file:handle) "$state(file:sheet),max_column"] + 1}]
    set state(file:info) [list "Sheets" [llength $sheets]]
    set state(file:options) [list -sheet $sheet]
    set state(file:fields) {} ;# TODO: list of fields: {field anchor ?size?}
    unset data
}

proc fileClose:xlsx {} {
}

proc fileRow:xlsx {row} {
    global state

    if {$row >= $state(file:rows)} {
        return {}
    }
    set values {}
    set sheet $state(file:sheet)
    for {set col 0} {$col < $state(file:cols)} {incr col} {
        lappend values [dict getdef $state(file:handle) "$sheet,v,$row,$col" ""]
    }
    return $values
}

proc fileEof:xlsx {row} {
    global state

    expr {$row >= $state(file:rows)}
}

# proc fileOpen:xxx {filename args}
#     set option(-encoding) - current settings
#     set state(file:handle) - like [open $filename]
#     set state(file:rows) - total number of rows (maybe, approximated)
#     set state(file:info) - dictionary of readonly info: title value ...
#     set state(file:options) - dictionary of options: option value
#     set state(file:fields) - list of fields: {field anchor ?size?}
# proc fileClose:xxx {}
# proc fileRow:xxx {row}
# proc fileEof:xxx {row}

proc getencoding {binary default} {
    set mfu "\u0410 \u041e \u0412 \u041d \u0420 \u041a \u041b \u0418"
    set cyr "\u0410\u0411\u0412\u0413\u0490\u0414\u0415\u0401\u0404\u0416\u0417\u0418\u0406\u0407\u0419\u041a\u041b\u041c\u041d\u041e\u041f\u0420\u0421\u0422\u0423\u0424\u0425\u0426\u0427\u0428\u0429\u042a\u042b\u042c\u042d\u042e\u042f"
    set enc {cp866 cp1251 utf-8}
    set d {}
    set t 0
    if {[string first \x00 $binary] >= 0} {
        error "can't process binary file"
    }
    foreach e $enc {
        foreach c [split [encoding convertfrom $e $binary] {}] {
            if {$c > "\x7f" && [string is alpha $c]} {
                dict incr d [string toupper $c]
                incr t
            }
        }
        if {[llength $d] < 16} {
            lappend detect $e 10
            break
        }
        set d [lsort -stride 2 -index 1 -integer -decreasing \
                [dict map {k v} $d {expr {$v*100/$t}}]]
        set r 0
        foreach {c v} [lrange $d 0 15] {
            if {[string first $c $cyr] < 0} {
                set r 9
                break
            }
            if {$c ni $mfu} {
                incr r
            }
        }
        lappend detect $e $r
    }
    set detect [lsort -dictionary -stride 2 -index 1 -integer $detect]
    set encoding [lindex $detect 0]
    debuglog {encoding detected using [string bytelength $binary] bytes: $detect}
    expr {[dict get $detect $encoding] <= 5 ? $encoding : $default}
}

proc bgerror {message {flag 1}} {
    if {$::option(-debug)} {
        puts stderr "$message\nTRACE: $::errorInfo"
        tailcall tk::dialog::error::bgerror $message $flag
    } else {
        tk_messageBox -parent . -icon "error" -title "Error" -message $message
        return ""
    }
}

proc tkerror {message} {
    tailcall bgerror $message
}

proc debuglog {message} {
    if {$::option(-debug)} {
        set s [lindex [::info level -1] 0]
        puts stderr [concat [uplevel 1 namespace current] $s: [uplevel 1 subst [list $message]]]
    }
}

try {
    appInit $argc $argv
} on error {message} {
    puts stderr $message
    tk_messageBox -icon "error" -title "Startup error" -message $message
    exit 1
}

windowCreate .

if {$argc == 0 && $tcl_platform(os) eq "Darwin"} {
    proc ::tk::mac::OpenDocument {args} {
        fileOpen "" [lindex $args 0] {*}[array get option]
    }
} else {
    fileOpen $option(-filetype) $option(-filename) {*}[array get option]
}