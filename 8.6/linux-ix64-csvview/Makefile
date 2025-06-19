# Generated Sun Apr  6 11:28:36 EEST 2025 for Linux:
#   config.sh -v 8.6/linux-custom-ix86 allenc allmsgs b64 cli gui thread tzdata x86 cust verbose

CC         = gcc
CXX        = gcc
LDFLAGS    = -ldl -lm
LDFLAGS   += build/lib/*tclstub8*.a
LDXXFLAGS  = -Wl,-Bstatic -lstdc++ -Wl,-Bdynamic
GUI_OPTS   = -L/usr/X11R6/lib -lX11 -lXss
GUI_OPTS  += -lXft -lXext -lfontconfig
CFLAGS     += -m64
UPX        = :
PLAT       = unix
KITFLAGS   =
PRIV       = install-headers install-private-headers
TCL_OPTS   += --enable-64bit
TK_OPTS    += --enable-64bit
VFS_OPTS   += --enable-64bit
VLERQ_OPTS += --enable-64bit
MK_OPTS    += --enable-64bit
ITCL_OPTS  += --enable-64bit
LDFLAGS   += -lpthread
CFLAGS    += -DKIT_INCLUDES_THREADS
LDFLAGS   += build/lib/thread2*/*thread2*.a
TCL_OPTS   = --enable-threads
KIT_OPTS   = -T -e -m -z
TCL_OPTS  += --with-tzdata
CFLAGS    += -DKIT_INCLUDES_CUSTOM
KIT_OPTS  += -c ../../setupvfs-custom.tcl

TCL_PRIV  += install-tzdata install-msgs
all: custom tclkit-gui

include ../../makefile.include
