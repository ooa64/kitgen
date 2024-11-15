if {"tbcload" in $::env(CUSTOM)} {
  vfscreate lib/tbcload1.7.0/pkgIndex.tcl \
     "package ifneeded tbcload 1.7.0 \"load {} Tbcload\""
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
