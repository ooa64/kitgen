#if defined(KIT_INCLUDES_TCLTLS)
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
