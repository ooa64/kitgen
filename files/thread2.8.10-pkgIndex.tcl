package ifneeded Thread 2.8.10 {load {} Thread}
package ifneeded Ttrace 2.8.10 [list ::apply {{dir} {
    if {[info exists ::env(TCL_THREAD_LIBRARY)] &&
	[file readable $::env(TCL_THREAD_LIBRARY)/ttrace.tcl]} {
	source -encoding utf-8 $::env(TCL_THREAD_LIBRARY)/ttrace.tcl
    } elseif {[file readable [file join $dir .. lib ttrace.tcl]]} {
	source -encoding utf-8 [file join $dir .. lib ttrace.tcl]
    } elseif {[file readable [file join $dir ttrace.tcl]]} {
	source -encoding utf-8 [file join $dir ttrace.tcl]
    }
    if {[namespace which ::ttrace::update] ne ""} {
	::ttrace::update
    }
}} $dir]