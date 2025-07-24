make CUSTOM="tdom tclcsv tcldbf xlsreader" 2>&1 | tee $0.log

test -d csvview.vfs && rm -fr csvview.vfs
mkdir csvview.vfs
mkdir csvview.vfs/lib
cp ../win32-ix64-csvview/ooxml.tcl csvview.vfs/lib/ooxml.tcl
cp ../win32-ix64-csvview/ooxml-pkgIndex.tcl csvview.vfs/lib/pkgIndex.tcl
cp ../win32-ix64-csvview/csvview.tcl csvview.vfs/main.tcl
sdxsh wrap csvview -runtime tclkit-gui

test -d Csvview.app && rm -fr Csvview.app
mkdir -p Csvview.app/Contents/MacOS
mkdir -p Csvview.app/Contents/Resources
sed -e 's/Wish/Csvview/g' build/tk/Wish-Info.plist > Csvview.app/Contents/Info.plist
cp ../tk/macosx/Wish.sdef Csvview.app/Contents/Resources/Csvview.sdef
cp ../tk/macosx/Tk.icns Csvview.app/Contents/Resources/Csvview.icns
cp csvview Csvview.app/Contents/MacOS/Csvview
codesign --force --deep -s - Csvview.app/Contents/MacOS/Csvview
