@call vcvars64.bat
@nmake -nologo VERSION=86 SYMBOLS=0 UPX=0 CUSTOM="tbcload" %*
