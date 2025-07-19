make CUSTOM="tdom tclcsv tcldbf xlsreader" 2>&1 | tee $0.log

rm -fr csvview.vfs 2> /dev/null
mkdir csvview.vfs
mkdir csvview.vfs/lib
cp ../win32-ix64-csvview/ooxml.tcl csvview.vfs/lib/ooxml.tcl
cp ../win32-ix64-csvview/ooxml-pkgIndex.tcl csvview.vfs/lib/pkgIndex.tcl
cp ../win32-ix64-csvview/csvview.tcl csvview.vfs/main.tcl
sdxsh wrap csvview -runtime tclkit-gui