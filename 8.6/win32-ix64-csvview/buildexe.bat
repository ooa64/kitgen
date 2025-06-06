call vcvars64

nmake -nologo VERSION=86 SYMBOLS=0 UPX=0 CUSTOM="tdom tclcsv tcldbf xlsreader" %*
if errorlevel 1 exit

rd /fr csvview.vfs
md csvview.vfs
md csvview.vfs\lib
copy ooxml.tcl csvview.vfs\lib\ooxml.tcl
copy ooxml-pkgIndex.tcl csvview.vfs\lib\pkgIndex.tcl
copy csvview.tcl csvview.vfs\main.tcl
sdxsh wrap csvview.exe -runtime tclkit-gui.exe
