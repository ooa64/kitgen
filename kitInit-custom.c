#if defined(KIT_INCLUDES_TBCLOAD)
    Tcl_AppInitProc Tbcload_Init, Tbcload_SafeInit;
    Tcl_StaticPackage(0, "Tbcload", Tbcload_Init, Tbcload_SafeInit);
#endif

#if defined(KIT_INCLUDES_TLS)
    Tcl_AppInitProc Tls_Init, Tls_SafeInit;
    Tcl_StaticPackage(0, "tls", Tls_Init, Tls_SafeInit);
#endif

#if defined(KIT_INCLUDES_YAJLTCL)
    Tcl_AppInitProc Yajltcl_Init, Yajltcl_SafeInit;
    Tcl_StaticPackage(0, "yajltcl", Yajltcl_Init, Yajltcl_SafeInit);
#endif

#if defined(KIT_INCLUDES_TCLTDJSON)
    Tcl_AppInitProc Tcltdjson_Init;
    Tcl_StaticPackage(0, "tcltdjson", Tcltdjson_Init, NULL);
#endif

#if defined(KIT_INCLUDES_TCLDBF)
    Tcl_AppInitProc Tcldbf_Init;
    Tcl_StaticPackage(0, "Tcldbf", Tcldbf_Init, NULL);
#endif

#if defined(KIT_INCLUDES_TCLPARSER)
    Tcl_AppInitProc Tclparser_Init;
    Tcl_StaticPackage(0, "parser", Tclparser_Init, NULL);
#endif

