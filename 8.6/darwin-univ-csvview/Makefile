# Generated сб 19 лип 2025 12:07:05 EEST for Darwin:
#   config.sh -v 8.6/darwin-ix86-csvview allenc allmsgs aqua gui arm x86 cust verbose

SO         = dylib
GUI_OPTS   = -ObjC -framework Cocoa -framework Carbon -framework IOKit -framework QuartzCore -weak_framework UniformTypeIdentifiers
LDFLAGS    = -framework CoreFoundation
LDFLAGS   += build/lib/*tclstub8*.a
LDSTRIP    = -x
CFLAGS    += -arch arm64 -arch x86_64
CFLAGS    += -mmacosx-version-min=11
TK_OPTS    = --enable-aqua
TKDYN_OPTS = --enable-aqua
PLAT       = unix
KITFLAGS   =
PRIV       = install-headers install-private-headers
KIT_OPTS   = -e -m
CFLAGS    += -DKIT_INCLUDES_CUSTOM
KIT_OPTS  += -c ../../setupvfs-custom.tcl

TCL_PRIV  += install-tzdata install-msgs
all: custom tclkit-gui

include ../../makefile.include
