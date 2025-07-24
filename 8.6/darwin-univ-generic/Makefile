# Generated Thu Jul 24 14:55:15 EEST 2025 for Darwin:
#   config.sh -v 8.6/darwin-ix86-generic allenc allmsgs aqua cli gui arm x86 verbose

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
TCL_PRIV  += install-tzdata install-msgs
all: tclkit-cli tclkit-gui

include ../../makefile.include
