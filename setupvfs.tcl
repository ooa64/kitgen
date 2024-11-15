# setupvfs.tcl -- new tclkit-{cli,dyn,gui} generation bootstrap
#
# jcw, 2006-11-16

proc history {args} {} ;# since this runs so early, all debugging support helps

if {[lindex $argv 0] ne "-init-"} {
  puts stderr "setupvfs.tcl has to be run by kit-cli with the '-init-' flag"
  exit 1
}

set argv [lrange $argv 2 end] ;# strip off the leading "-init- setupvfs.tcl"

set debugOpt 0
set encOpt 0 
set msgsOpt 0 
set threadOpt none
set tzOpt 0 
set customOpt {}
set minimalEncodings 0

while {1} {
  switch -- [lindex $argv 0] {
    -d { incr debugOpt }
    -e { incr encOpt }
    -E { incr minimalEncodings }
    -m { incr msgsOpt }
    -t { set threadOpt dynamic }
    -T { set threadOpt static }
    -z { incr tzOpt }
    -c {
        set customOpt [lindex $argv 1]
        set argv [lrange $argv 1 end]
    }
    default { break }
  }
  set argv [lrange $argv 1 end]
}

if {[llength $argv] != 2} {
  puts stderr "Usage: [file tail [info nameofexe]] -init- [info script]\
    ?-d? ?-e? ?-m? ?-t? ?-z? ?-c path? destfile (cli|dyn|gui)
    -d        output some debugging info from this setup script
    -e        include all encodings i.s.o. 7 basic ones (encodings/)
    -m        include all localized message files (tcl 8.5, msgs/)
    -t        include the thread extension as shared lib in vfs
    -z        include timezone data files (tcl 8.5, tzdata/)
    -c path   include a custom script for additional vfs setup"
  exit 1
}

set lite [expr {![catch {load {} vlerq}]}]

load {} vfs ;# vlerq is already loaded by now

# map of proper version numbers to replace @ markers in paths given to vfscopy
# this relies on having all necessary extensions already loaded at this point
set versmap [list tcl8@ tcl$tcl_version tk8@ tk$tcl_version \
                 vfs1@ vfs[package require vfs]]
if {$lite} {
    lappend versmap vqtcl4@ vqtcl[package require vlerq] 
} else {
    lappend versmap Mk4tcl@ Mk4tcl[package require Mk4tcl]
}

if {$debugOpt} {
  puts "Starting [info script]"
  puts "     exe: [info nameofexe]"
  puts "    argv: $argv"
  puts "   tcltk: $tcl_version"
  puts "  loaded: [info loaded]"
  puts " versmap: $versmap"
  puts ""
}

set tcl_library ../tcl/library
source ../tcl/library/init.tcl ;# for tcl::CopyDirectory
source ../../8.x/tclvfs/library/vfsUtils.tcl
source ../../8.x/tclvfs/library/vfslib.tcl ;# override vfs::memchan/vfsUtils.tcl
if {$lite} {
    source ../../8.x/vqtcl/library/m2mvfs.tcl
} else {
    source ../../8.x/tclvfs/library/mk4vfs.tcl
}

set clifiles {
  boot.tcl
  config.tcl
  tclkit.ico
  lib/tcl8@/auto.tcl
  lib/tcl8@/history.tcl
  lib/tcl8@/init.tcl
  lib/tcl8@/opt0.4
  lib/tcl8@/package.tcl
  lib/tcl8@/parray.tcl
  lib/tcl8@/safe.tcl
  lib/tcl8@/tclIndex
  lib/tcl8@/word.tcl
  lib/vfs1@/mk4vfs.tcl
  lib/vfs1@/pkgIndex.tcl
  lib/vfs1@/starkit.tcl
  lib/vfs1@/vfslib.tcl
  lib/vfs1@/vfsUtils.tcl
  lib/vfs1@/tarvfs.tcl
  lib/vfs1@/zipvfs.tcl
}

if {[package vcompare [package provide vfs] 1.4] < 0} {
    # vfs 1.3 needed these two
    lappend clifiles \
        lib/vfs1@/mk4vfscompat.tcl \
        lib/vfs1@/zipvfscompat.tcl
}

if {$lite} {
    lappend clifiles \
        lib/vqtcl4@/m2mvfs.tcl \
        lib/vqtcl4@/mkclvfs.tcl \
        lib/vqtcl4@/mklite.tcl \
        lib/vqtcl4@/pkgIndex.tcl \
        lib/vqtcl4@/ratcl.tcl
}

set guifiles {
  lib/tk8@/bgerror.tcl
  lib/tk8@/button.tcl
  lib/tk8@/choosedir.tcl
  lib/tk8@/clrpick.tcl
  lib/tk8@/comdlg.tcl
  lib/tk8@/console.tcl
  lib/tk8@/dialog.tcl
  lib/tk8@/entry.tcl
  lib/tk8@/focus.tcl
  lib/tk8@/listbox.tcl
  lib/tk8@/menu.tcl
  lib/tk8@/mkpsenc.tcl
  lib/tk8@/msgbox.tcl
  lib/tk8@/msgs
  lib/tk8@/obsolete.tcl
  lib/tk8@/optMenu.tcl
  lib/tk8@/palette.tcl
  lib/tk8@/panedwindow.tcl
  lib/tk8@/safetk.tcl
  lib/tk8@/scale.tcl
  lib/tk8@/scrlbar.tcl
  lib/tk8@/spinbox.tcl
  lib/tk8@/tclIndex
  lib/tk8@/tearoff.tcl
  lib/tk8@/text.tcl
  lib/tk8@/tk.tcl
  lib/tk8@/tkfbox.tcl
  lib/tk8@/unsupported.tcl
  lib/tk8@/xmfbox.tcl
  lib/tk8@/images/logo64.gif
}
# handle new or deleted files
foreach f {
    lib/tk8@/prolog.ps
    lib/tk8@/fontchooser.tcl
    lib/tk8@/icons.tcl
    lib/tk8@/iconlist.tcl
    lib/tk8@/megawidget.tcl
    lib/tk8@/images/lamp.png
} {
    set fx [string map $versmap $f]
    if {[file exists build/$fx]} {
        lappend guifiles $f
    }
}

if {$encOpt} {
  lappend clifiles lib/tcl8@/encoding
} else {
    # Microsoft Windows & DOS code pages:
    # Win     DOS
    # cp1250  cp852 - Central Europe
    # cp1251  cp855 - Cyrillic
    #         cp866 - Cyrillic II
    # cp1252  cp850 - Latin I
    #         cp437 - English (US)
    # cp1253  cp737 - Greek
    # cp1254  cp857 - Turkish
    # cp1255  cp862 - Hebrew
    # cp1255  cp720 - Arabic
    # cp1257  cp775 - Baltic                  
    # cp1258        - VietNam
    # cp874         - Thai
    # cp932         - Japanese
    # cp936         - Chinese Simplified
    # cp950         - Chinese Traditional

    # IBM Code pages:
    # cp437 - USA
    # cp850 - Europe
    # cp851 - Greek
    # cp852 - Latin2
    # cp855 - Cyrillic
    # cp856 - Hebrew
    # cp857 - Turkey
    # cp860 - Portugal
    # cp861 - Iceland
    # cp862 - Hebrew
    # cp863 - fr_CA
    # cp864 - Arabic
    # cp865 - Nordic
    # cp866 - Cyrillic2
    # cp874 - Thai

    # Minimal set
    #foreach e {ascii cp1251 cp1252 iso8859-1 iso8859-2 iso8859-3
    #    iso8859-4 iso8859-5 iso8859-6 iso8859-7 iso8859-8 iso8859-9
    #    iso8859-10 iso8859-13 iso8859-14 iso8859-15 iso8859-16
    #    koi8-r macRoman} {
    #    lappend clifiles lib/tcl8@/encoding/$e.enc
    #}

    #  Load the basic encodings set...
    foreach e {ascii cp1250 cp1251 cp1252 cp1253 cp1254 cp1255 cp1256 cp1257
        cp1258 cp437 cp737 cp775 cp850 cp852 cp855 cp857 cp860 cp861 cp862
        cp863 cp864 cp865 cp866 cp869 cp874 cp932 
        iso2022 iso2022-jp iso2022-kr iso8859-1 iso8859-10 iso8859-13
        iso8859-14 iso8859-15 iso8859-16 iso8859-2 iso8859-3 iso8859-4
        iso8859-5 iso8859-6 iso8859-7 iso8859-8 iso8859-9 jis0201
    } {
      lappend clifiles lib/tcl8@/encoding/$e.enc
    }
    # Usually include the remaining encodings to match activetcl basekits.
    # This just avoids the largest files:
    #  big5 cp932 cp936 cp949 cp950 euc-cn euc-jp euc-kr gn12345 gb2312
    #  gb2312-raw jis0208 jis0212 ksc601 shiftjis
    if {!$minimalEncodings} {
      foreach e {
        dingbats ebcdic gb1988
        koi8-r koi8-u macCentEuro macCroatian macCyrillic macDingbats
        macGreek macIceland macRoman macRomania macThai macTurkish
        macUkraine symbol tis-620
      } {
        lappend clifiles lib/tcl8@/encoding/$e.enc
      }
    }
}

switch -exact -- $threadOpt {
  static {
    foreach file [glob -tails -dir build/lib/thread2.8.10 *.tcl] {
      lappend clifiles lib/thread2.8.10/$file
    }
    lappend clifiles lib/thread2.8.10/pkgIndex.tcl
  }
  dynamic {
    lappend clifiles lib/[glob -tails -dir build/lib thread2*]
  }
}

if {$tcl_version eq "8.4"} {
  lappend clifiles lib/tcl8@/http2.5 \
            		   lib/tcl8@/ldAout.tcl \
            		   lib/tcl8@/msgcat1.3 \
            		   lib/tcl8@/tcltest2.2
} else {
  lappend clifiles lib/tcl8 \
                   lib/tcl8@/clock.tcl \
                   lib/tcl8@/tm.tcl

  lappend guifiles lib/tk8@/ttk

  if {$msgsOpt} {
    lappend clifiles lib/tcl8@/msgs
  }
  if {$tzOpt} {
    lappend clifiles lib/tcl8@/tzdata
  }
}

# look for a/b/c in three places:
#   1) build/files/b-c
#   2) build/files/a/b/c
#   3) build/a/b/c

proc locatefile {f} {
  set a [file split $f]
  set n "build/files/[lindex $a end-1]-[lindex $a end]"
  if {[file exists $n]} {
    if {$::debugOpt} {
      puts "  $n  ==>  \$vfs/$f"
    }
  } elseif {[string match "lib/vfs*/pkgIndex.tcl" $f]} {
      set n [mk_tclvfs_index build/$f]
      if {$::debugOpt} {puts "  $n ==> \$vfs/$f" }
  } else {
    set n build/files/$f
    if {[file exists $n]} {
      if {$::debugOpt} {
        puts "  $n  ==>  \$vfs/$f"
      }
    } else {
      set n build/$f
    }
  }
  return $n
}

# We use a modified tclvfs pkgIndex with a reduced set of vfs' and force
# the use of vfslib.tcl for utility functions.
proc mk_tclvfs_index {src} {
  global versmap
  set fin [open $src r]
  set fout [open ${src}.tclkit w]
  set script [string map [list @V [package provide vfs]] {
      package ifneeded vfs @V "load {} vfs;\
          source \[file join [list $dir] vfsUtils.tcl\];\
          source \[file join [list $dir] vfslib.tcl\]"
  }]
  puts $fout $script
  while {[gets $fin line] != -1} {
    foreach pkg {starkit vfslib vfs::mk4 vfs::zip vfs::tar mk4vfs} {
      if {[string match "package ifneeded $pkg *" $line]} {
        puts $fout $line
      }
    }
  }
  close $fin
  close $fout
  return ${src}.tclkit
}

# copy file to m2m-mounted vfs
proc vfscopy {argv} {
  global vfs versmap
  
  foreach f $argv {
    # avoid emacs and cvs temporary files.
    if {[string match "*~" $f] || [string match ".#*" $f]} {
      puts "skipping file '$f'"
      continue
    }
    set f [string map $versmap $f]
    
    set d $vfs/[file dirname $f]
    if {![file isdir $d]} {
      file mkdir $d
    }

    set src [locatefile $f]
    set dest $vfs/$f

    # If the source is a directory, recurse.
    if {[file isdir $src]} {
      set contents {}
      foreach ff [glob -nocomplain -directory $src -tails *] {
        lappend contents $f/$ff
      }
      vfscopy $contents
      continue
    }
    
    if {$::debugOpt} {
      puts "  $f \[$src\] ==>  \$vfs/$f"
    }

    switch -- [file extension $src] {
      .tcl - .tm - .txt - .msg - .test {
        # get line-endings right for text files - this is crucial for boot.tcl
        # and several scripts in lib/vlerq4/ which are loaded before vfs works
        set fin [open $src r]
        set fout [open $dest w]
        fconfigure $fout -translation lf
        if {[file extension $src] in {.tcl .tm .msg}} {
          # strip line comments and white space from the standard scripts
          set continue 0
          set s ""
          while {![eof $fin]} {
            append s [string trim [gets $fin]]
            # FIXME: buggy on double slash at the string end?
            if {[string index $s end] eq "\\"} {
              set s [string replace $s end end " "]
            } else {
              if {[string length $s]} {
                if {[string index $s 0] ne "#" || [string range $s 0 3] eq "#def"} {
                  puts $fout $s
                }
              }
              set s ""
            }
          }
        } else {
            fcopy $fin $fout
        }
        close $fin
        close $fout
      }
      default {
        file copy $src $dest
      }
    }
    
    file mtime $dest [file mtime $src]
  }
}

# create file in m2m-mounted vfs
proc vfscreate {f content} {
  global vfs versmap
  set f [string map $versmap $f]
  set d $vfs/[file dirname $f]
  if {![file isdir $d]} {
    file mkdir $d
  }

  set h [open $vfs/$f w]
  if {[file extension $f] in {.tcl .tm .txt .msg .test}} {
    fconfigure $h -translation lf
  }
  puts $h $content
  close $h

  if {$::debugOpt} {
    puts "  $f ==>  \$vfs/$f"
  }
}

# Create a pkgIndex file for a statick package 'pkg'. If the version
# is not provided then it is detected when creating the vfs.
proc staticpkg {pkg {ver {}} {init {}}} {
    global vfs
    if {$ver eq {}} {
        load {} $pkg
        set ver [package provide $pkg]
    }
    if {$init eq {}} {set init $pkg}
    vfscreate lib/$pkg/pkgIndex.tcl "package ifneeded $pkg $ver {load {} $init}"
}

set vfs [lindex $argv 0]
if {$lite} {
    vfs::m2m::Mount $vfs $vfs
} else {
    vfs::mk4::Mount $vfs $vfs
}

switch [info sharedlibext] {
  .dll {
    catch {
      # avoid hard-wiring a Thread extension version number in here
      set dll [glob build/bin/thread2*.dll]
      load $dll
      set vsn [package require Thread]
      file copy -force $dll build/lib/libthread$vsn.dll
      unset dll vsn
    }
    # create dde and registry pkgIndex files with the right version
    foreach ext {dde registry} {
      if {[catch {
          load {} $ext
          vfscreate lib/$ext/pkgIndex.tcl \
              "package ifneeded $ext [package provide $ext] {load {} $ext}"
      } err]} { puts "ERROR: $err"}
    }
    catch {
      # wtf?
      #file delete [glob build/lib/libtk8?.a] ;# so only libtk8?s.a will be found
    }
    catch {
      file copy -force [glob build/bin/tk8*.dll] build/lib/libtk$tcl_version.dll
    }
  }
  .so {
    catch {
      # for some *BSD's, lib names have no dot and/or end with a version number
      file rename [glob build/lib/libtk8*.so*] build/lib/libtk$tcl_version.so
    }
  }
}

# Create package index files for the static extensions.
# vlerq registry dde and vfs are handled above or using files/*
set exts {rechan}
if {![package vsatisfies [package provide Tcl] 8.6]} { lappend exts zlib }
if {[package vcompare [package provide Tcl] 8.4] == 0} { lappend exts pwb }
#if {$threadOpt eq "static"} { lappend exts Thread }
foreach ext $exts {
    staticpkg $ext
}
if {!$lite} { staticpkg Mk4tcl }
if {[lsearch [info loaded] {{} Itcl}] != -1} {
    catch {load {} Itcl}
    lappend versmap itcl3@ itcl[package provide Itcl]
    lappend clifiles lib/itcl3@/itcl.tcl
    lappend clifiles lib/itcl3@/pkgIndex.tcl
#   staticpkg Itcl [package provide Itcl]
}

if {[package vcompare [package provide Tcl] 8.4] == 0} {
    set tkver $tcl_version
} else {
    set tkver [info patchlevel]
}

switch [lindex $argv 1] {
  cli {
    vfscopy $clifiles
  }
  gui {
    vfscopy $clifiles
    vfscopy $guifiles
    vfscreate lib/tk8@/pkgIndex.tcl "package ifneeded Tk $tkver {load {} Tk}"
  }
  dyn {
    vfscopy $clifiles
    vfscopy $guifiles
    vfscopy lib/libtk$tcl_version[info sharedlibext]
    vfscreate lib/tk8@/pkgIndex.tcl "package ifneeded Tk $tkver\
      \[list load \[file join \[list \$dir\] ..\
      libtk$tcl_version\[info sharedlibext\]\] Tk\]"
  }
  default {
    puts stderr "Unknown type, must be one of: cli, dyn, gui"
    exit 1
  }
}

if {$customOpt ne {}} {
    source $customOpt
}

vfs::unmount $vfs

if {$debugOpt} {
  puts "\nDone with [info script]"
}

# Local variables:
# mode: tcl
# indent-tabs-mode: nil
# tcl-indent-level: 2
# End:
