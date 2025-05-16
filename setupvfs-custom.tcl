
set setupvfs_local [file join [file dirname [file normalize [info script]]] setupvfs-local.tcl]

if {[file readable $setupvfs_local]} {
  puts "Local vfs setup ..."
  source $setupvfs_local
}

if {"tbcload" in $::env(CUSTOM)} {
  vfscreate lib/tbcload1.7.2/pkgIndex.tcl \
     "package ifneeded tbcload 1.7.2 \"load {} Tbcload\""
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

if {"tcldbf" in $::env(CUSTOM)} {
  vfscreate lib/tcldbf2.1.0/pkgIndex.tcl \
     "package ifneeded tcldbf 2.1.0 \"load {} Tcldbf\""
}

if {"parser" in $::env(CUSTOM)} {
  vfscreate lib/tclparser1.9/pkgIndex.tcl \
     "package ifneeded parser 1.9 \"load {} Parser\""
}
