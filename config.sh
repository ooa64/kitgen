#set -x

args="$*"

verbose=0; case $1 in -v) verbose=1; shift ;; esac

root=`dirname $1`
base=`basename $1`
shift

case $root in .) root=8.6;; esac
path=$root/$base

if test ! -d $root
  then echo "error: directory '$root' does not exist"; exit 1; fi

for v in allenc allmsgs aqua b64 cli dyn gui ppc mk \
          gcov gprof sym thread tzdata univ x86 arm cust
  do eval $v=0; done

while test $# != 0
  do eval $1=1; shift; done

#for v in thread allenc allmsgs tzdata cli dyn gui aqua x86 ppc arm univ cust
#  do eval val=$`echo $v`; echo $v = "$val"; done

make=$path/Makefile
mach=`uname`
plat=unix
upx=`which upx`

echo "Configuring $make for $mach."
mkdir -p $path

case $cli-$dyn-$gui in 0-0-0) cli=1 dyn=1 gui=1 ;; esac

( echo "# Generated `date` for $mach:"
  echo "#   `basename $0` $args"
  echo

  case $mach in

    LegacyDarwin)
      case $aqua in
        1) echo "GUI_OPTS   = -framework Carbon -framework IOKit" ;;
        *) echo "GUI_OPTS   = -L/usr/X11R6/lib -lX11 -weak-lXss -lXext" ;;
      esac

      echo "LDFLAGS    = -framework CoreFoundation"
      echo "LDSTRIP    = -x"

      case $b64-$univ-$ppc-$x86 in
        0-0-0-0) ;;
        0-0-1-0) echo "CFLAGS    += -arch ppc" ;;
        0-0-0-1) echo "CFLAGS    += -arch x86" ;;
        0-?-?-?) echo "CFLAGS    += -arch ppc -arch i386" ;;
        1-0-1-0) echo "CFLAGS    += -arch ppc64" ;;
        1-0-0-1) echo "CFLAGS    += -arch x86_64" ;;
        1-?-?-?) echo "CFLAGS    += -arch ppc64 -arch x86_64" ;;
      esac
      echo "CFLAGS    += -isysroot /Developer/SDKs/MacOSX10.4u.sdk" \
                          "-mmacosx-version-min=10.4"

      case $aqua in 1)
        echo "TK_OPTS    = --enable-aqua"
        echo "TKDYN_OPTS = --enable-aqua" ;;
      esac
      ;;

    Darwin)

      echo "SO         = dylib"

      case $aqua in
        1) echo "GUI_OPTS   = -ObjC -framework Cocoa -framework Carbon -framework IOKit -framework QuartzCore -weak_framework UniformTypeIdentifiers" ;;
        *) echo "GUI_OPTS   = -L/usr/X11R6/lib -lX11 -weak-lXss -lXext" ;;
      esac

      echo "LDFLAGS    = -framework CoreFoundation"
      echo "LDFLAGS   += build/lib/*tclstub8*.a"
      echo "LDSTRIP    = -x"

      case $univ-$arm-$x86 in
        0-0-0) ;;
        0-1-0) echo "CFLAGS    += -arch arm64" ;;
        0-0-1) echo "CFLAGS    += -arch x86_64" ;;
        0-1-1) echo "CFLAGS    += -arch arm64 -arch x86_64" ;;
        1-?-?) echo "CFLAGS    += -arch arm64 -arch x86_64" ;;
      esac
      echo "CFLAGS    += -mmacosx-version-min=11"

      case $aqua in 1)
        echo "TK_OPTS    = --enable-aqua"
        echo "TKDYN_OPTS = --enable-aqua" ;;
      esac
      ;;

    Linux)
      echo "CC         = ${CC:=gcc}"
      echo "CXX        = ${CXX:=gcc}"
      echo "LDFLAGS    = -ldl -lm"
      echo 'LDFLAGS   += build/lib/*tclstub8*.a'
      echo "LDXXFLAGS  = -Wl,-Bstatic -lstdc++ -Wl,-Bdynamic"
      echo "GUI_OPTS   = -L/usr/X11R6/lib -lX11 -lXss"
      if [ $root != "8.4" ]; then
          echo "GUI_OPTS  += -lXft -lXext -lfontconfig"
      fi
      case $b64 in 1)
        echo "CFLAGS     += -m64" ;;
      esac
      [ -x "$upx" ] || upx=':'
      echo "UPX        = $upx"
      ;;

    *BSD)
      echo "CC         = ${CC:=gcc}"
      echo "CFLAGS    += -I/usr/X11R6/include"
      echo "LDFLAGS    = -lm"
      echo "GUI_OPTS   = -L/usr/X11R6/lib -lX11 -lXss"
      case $b64 in 1)
        echo "CFLAGS     += -m64" ;;
      esac
      ;;

    MINGW*)
      echo "CC         = ${CC:=gcc}"
      echo 'LDFLAGS    = build/lib/dde1*/*tcldde1*.a build/lib/reg1*/*tclreg1*.a'
      [ $root != "8.4" ]   && echo 'LDFLAGS   += -lws2_32'
      if [ ${root#8.} -ge 6 ]; then
          echo 'LDFLAGS   += -lnetapi32'
          echo 'LDFLAGS   += build/lib/*tclstub8*.a'
      fi
      echo 'GUI_OPTS   = -lgdi32 -lcomdlg32 -limm32 -lcomctl32 -lshell32'
      echo 'GUI_OPTS  += -lole32 -loleaut32 -luuid'
      echo 'GUI_OPTS  += build/tk/wish.res.o -mwindows'
      echo 'CLIOBJ     = $(OBJ) $(OUTDIR)/tclAppInit.o $(OUTDIR)/tclkitsh.res.o'
      echo 'DYNOBJ     = $(CLIOBJ) $(OUTDIR)/tkdyn/wish.res.o'
      echo 'GUIOBJ     = $(OBJ) $(OUTDIR)/winMain.o $(OUTDIR)/tclkit.res.o'
      echo 'PRIV       = install-headers install-private-headers'
      echo 'EXE        = .exe'
      [ -x $upx ] && echo "UPX        = $upx"
      plat=win
      ;;

    SunOS)
      echo "CC         = ${CC:=gcc}"
      echo "CXX        = ${CXX:=gcc}"
      echo "CFLAGS    += -I/usr/openwin/include"
      echo "LDFLAGS    = -ldl -lsocket -lnsl -lm"
      echo "LDXXFLAGS  = -Wl,-Bstatic -lstdc++ -Wl,-Bdynamic"
      echo "GUI_OPTS   = -L/usr/openwin/lib -lX11 -lXext"
      if [ $root != "8.4" ]; then
          echo "GUI_OPTS  += -L/usr/sfw/lib -lXft -lfreetype -lz -lfontconfig -lXrender"
      fi
      case $b64 in 1)
        echo "CFLAGS += -m64" ;;
      esac
      ;;

    *) echo "warning: no settings known for '$mach'" >&2 ;;
  esac

  echo "PLAT       = $plat"
  echo "KITFLAGS   ="
  case $plat in unix)
    echo "PRIV       = install-headers install-private-headers" ;;
  esac
  case $b64 in 1)
    echo "TCL_OPTS   += --enable-64bit"
    echo "TK_OPTS    += --enable-64bit"
    echo "VFS_OPTS   += --enable-64bit"
    echo "VLERQ_OPTS += --enable-64bit"
    echo "MK_OPTS    += --enable-64bit"
    echo "ITCL_OPTS  += --enable-64bit"
    ;;
  esac

  #case $verbose in 1) kitopts=" -d" ;; esac
  case $allenc  in 1) kitopts="$kitopts -e" ;; esac
  case $allmsgs in 1) kitopts="$kitopts -m" ;; esac
  case $tzdata  in 1) kitopts="$kitopts -z" ;; esac

  case $thread in
    1) case $mach in Linux|SunOS|*BSD)
          echo "LDFLAGS   += -lpthread" ;;
       esac
       echo "CFLAGS    += -DKIT_INCLUDES_THREADS"
       echo 'LDFLAGS   += build/lib/thread2*/*thread2*.a'
       echo "TCL_OPTS   = --enable-threads"
       echo "KIT_OPTS   = -T$kitopts" ;;
    0) echo "KIT_OPTS   =$kitopts" ;;
  esac

  case $plat in win) echo "TCL_OPTS  += --with-encoding=utf-8" ;; esac
  case $tzdata in 1) echo "TCL_OPTS  += --with-tzdata" ;; esac

  case $gprof in 1)
    echo "CFLAGS    += -pg"
    sym=1 ;;
  esac

  case $gcov in 1)
    echo "CFLAGS    += -fprofile-arcs -ftest-coverage -O0"
    echo "LDFLAGS   += -lgcov"
    sym=1 ;;
  esac

  case $sym in 1)
    echo "STRIP      = :"
    echo
    echo "TCL_OPTS       += --enable-symbols"
    echo "THREADDYN_OPTS += --enable-symbols"
    echo "THREAD_OPTS    += --enable-symbols"
    echo "TK_OPTS        += --enable-symbols"
    echo "TKDYN_OPTS     += --enable-symbols"
    echo "VFS_OPTS       += --enable-symbols"
    echo "VLERQ_OPTS     += --enable-symbols"
    echo "MK_OPTS        += --enable-symbols"
    echo "ITCL_OPTS      += --enable-symbols"
    echo ;;
  esac

  case $cust in 1)
    echo "CFLAGS    += -DKIT_INCLUDES_CUSTOM"
    echo "KIT_OPTS  += -c ../../setupvfs-custom.tcl"
    targets="$targets custom"
    echo ;;
  esac

  if [ $root=="8.6" ]
  then
    echo "TCL_PRIV  += install-tzdata install-msgs"
  fi

  case $cli in 1) targets="$targets tclkit-cli" ;; esac
  case $dyn in 1) targets="$targets tclkit-dyn" ;; esac
  case $gui in 1) targets="$targets tclkit-gui" ;; esac
  case $mk in
    1)  case $cli in 1) targets="$targets tclkitsh" ;; esac
        case $dyn in 1) targets="$targets tclkit" ;; esac
        case $gui in 1) targets="$targets tclkit" ;; esac
        ;;
  esac

  case $thread in
    1) echo "all: thread$targets" ;;
    0) echo "all:$targets" ;;
  esac

  case $mach in MINGW*)
    echo
    echo "tclkit-cli: tclkit-cli.exe"
    echo "tclkit-dyn: tclkit-dyn.exe"
    echo "tclkit-gui: tclkit-gui.exe"
    case $mk in 1) echo "tclkitsh: tclkitsh.exe"
                   echo "tclkit: tclkit.exe" ;;
    esac
  esac

  echo
  echo "include ../../makefile.include"

) >$make

case $verbose in 1)
  echo
  echo "Contents of $make:"
  echo "======================================================================="
  cat $make
  echo "======================================================================="
  echo
  echo "To build, run these commands:"
  echo "    cd $path"
  echo "    make"
  echo
  echo "This produces the following executable(s):"
  case $cli in 1) echo "    $path/tclkit-cli   (command-line)" ;; esac
  case $dyn in 1) echo "    $path/tclkit-dyn   (Tk as shared lib)" ;; esac
  case $gui in 1) echo "    $path/tclkit-gui   (Tk linked statically)" ;; esac
  case $mk in 1)
      case $cli in 1) echo "    $path/tclkitsh     (old-style command line)" ;; esac
      case $dyn in 1) echo "    $path/tclkit       (old-style with Tk)" ;; esac
      case $gui in 1) echo "    $path/tclkit       (old-style with Tk)" ;; esac
      ;;
  esac
  echo
  echo "To remove all intermediate builds, use 'make clean'."
  echo "To remove all executables as well, use 'make distclean'."
  echo
esac
