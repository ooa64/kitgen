if {"yajltcl" in $::env(CUSTOM)} {
    vfscopy lib/yajltcl1.7.0/yajl.tcl
    set fn $vfs/lib/yajltcl1.7.0/pkgIndex.tcl
    set f [open $fn w]
    puts $f "package ifneeded yajltcl 1.7.0 \"load {} Yajltcl; \[list source \[file join \$dir yajl.tcl]]\""
    close $f
}

if {"tcltdjson" in $::env(CUSTOM)} {
    vfscopy lib/tcltdjson0.1/pkgIndex.tcl
    set fn $vfs/lib/tcltdjson0.1/pkgIndex.tcl
    set f [open $fn w]
    puts $f "package ifneeded tcltdjson 0.1 \"load {} Tcltdjson\""
    close $f
}
