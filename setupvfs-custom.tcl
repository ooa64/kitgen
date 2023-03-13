    vfscopy lib/yajltcl1.7.0/yajl.tcl
    set fn $vfs/lib/yajltcl1.7.0/pkgIndex.tcl
    set f [open $fn w]
    puts $f "package ifneeded yajltcl 1.7.0 \"load {} Yajltcl; \[list source \[file join \$dir yajl.tcl]]\""
    close $f
