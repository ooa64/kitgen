
set setupvfs_local [file join [file dirname [file normalize [info script]]] setupvfs-local.tcl]

if {[file readable $setupvfs_local]} {
  puts "Local vfs setup ..."
  source $setupvfs_local
}

if {"tbcload" in $::env(CUSTOM)} {
  vfscreate lib/tbcload1.7.2/pkgIndex.tcl \
     "package ifneeded tbcload 1.7.2 \"load {} Tbcload\""
}

if {"tdom" in $::env(CUSTOM)} {
  vfscopy lib/tdom0.9.5/tdom.tcl
  vfscreate lib/tdom0.9.5/pkgIndex.tcl \
     "package ifneeded tdom 0.9.5 \"load {} Tdom; \[list source \[file join \$dir tdom.tcl]]\""
}

if {"tls" in $::env(CUSTOM)} {
  vfscreate lib/tls1.7.22/pkgIndex.tcl \
     "package ifneeded tls 1.7.22 \"load {} Tls\""
}

if {"yajltcl" in $::env(CUSTOM)} {
  vfscopy lib/yajltcl1.7.0/yajl.tcl
  vfscreate lib/yajltcl1.7.0/pkgIndex.tcl \
     "package ifneeded yajltcl 1.7.0 \"load {} Yajltcl; \[list source \[file join \$dir yajl.tcl]]\""
}

if {"tcltdjson" in $::env(CUSTOM)} {
  vfscreate lib/tcltdjson0.1/pkgIndex.tcl \
      "package ifneeded tcltdjson 0.1 \"load {} Tcltdjson\""
}

if {"tclcsv" in $::env(CUSTOM)} {
  vfscopy lib/tclcsv2.4.3/csv.tcl
  vfscreate lib/tclcsv2.4.3/pkgIndex.tcl \
     "package ifneeded tclcsv 2.4.3 \"load {} Tclcsv; ; \[list source \[file join \$dir csv.tcl]]\""
}

if {"tcldbf" in $::env(CUSTOM)} {
  vfscreate lib/tcldbf2.1.0/pkgIndex.tcl \
     "package ifneeded tcldbf 2.1.0 \"load {} Tcldbf\""
}

if {"xlsreader" in $::env(CUSTOM)} {
  vfscreate lib/xlsreader1.0.1/pkgIndex.tcl \
     "package ifneeded xlsreader 1.0.1 \"load {} Xlsreader\""
}

if {"parser" in $::env(CUSTOM)} {
  vfscreate lib/tclparser1.9/pkgIndex.tcl \
     "package ifneeded parser 1.9 \"load {} Parser\""
}
