# vi:filetype=make

SHELL = /bin/sh

ifndef OS_TARGET
ifneq ($(findstring ;,$(PATH)),)
ifdef ComSpec
inDOS=1
ifdef OS
inWindows=1
endif #OS
else
inOtherOS=1
endif #COMSPEC
else
inUnix=1
endif #inUnix
endif #OS_TARGET

ifdef OS_TARGET
ifeq ($(OS_TARGET),linux)
forUnix=1
else
ifneq ($(findstring bsd,$(OS_TARGET)),)
forUnix=1
else
ifeq ($(OS_TARGET),solaris)
forUnix=1
else
ifneq ($(findstring go,$(OS_TARGET)),)
forDOS=1
else
ifeq ($(OS_TARGET),emx)
forDOS=1
forOS2=1
else
ifneq ($(findstring win,$(OS_TARGET)),)
forDOS=1
forWindows=1
endif #inWindows
endif #inOS2
endif #inDOS
endif #Solaris
endif #*BSD
endif #Linux
endif #OS_TARGET

# Now what programs
CUT ?= $(call programpath,cut)
DELTREE ?= $(call programpath,rm) -fr
MOVE ?= mv -f
PWD ?= $(call programpath,pwd)
RM ?= $(call programpath,rm) -f
RMDIR ?= $(call programpath,rmdir)
SED ?= $(call programpath,sed)
TOUCH ?= $(call programpath,touch)

LN ?= $(call programpath,ln) -sf

GIT ?= $(call programpath,git)

ifndef inDOS
COPY ?= $(call programpath,cp)
ECHO ?= $(call programpath,echo)
INSTALLPROG ?= $(call programpath,install)
else
COPY ?= copy
ECHO ?= $(call programpath,gecho)
INSTALLPROG ?= $(call programpath,ginstall)
endif

INSTALL=$(INSTALLPROG) -m 644
INSTALLEXE=$(INSTALLPROG) -m 755
MKDIR=$(INSTALLPROG) -d -m 755

CP=$(COPY)
DEL=$(RM)
MV=$(MOVE)

# General prefixes and suffixes
GPDEXT ?= *.gpd # GNU Pascal
OEXT ?= .o # .obj in Delphi
PPUEXT ?= .ppu
STATICLIBEXT = .a

# OS-dependent prefixes and suffixes
ifdef inUnix
EXEEXT=
SHAREDLIBEXT=.so
SHAREDLIBPREFIX=lib
else
ifdef inDOS
EXEEXT=.exe
SHAREDLIBEXT=.dll
SHAREDLIBPREFIX=
endif #inDOS
endif #inUnix

ifdef forDOS
TARGETEXEEXT=.exe
TARGETSHAREDLIBEXT=.dll
TARGETSHAREDLIBPREFIX=
else
TARGETEXEEXT=
TARGETSHAREDLIBEXT=.so
TARGETSHAREDLIBPREFIX=lib
endif

TARGETEXEEXT ?= $(EXEEXT)
TARGETSHAREDLIBEXT ?= $(SHAREDLIBEXT)
TARGETSHAREDLIBPREFIX ?= $(SHAREDLIBPREFIX)

ifdef inDOS
SEARCHPATH=$(subst ;, ,$(subst \,/,$(PATH)))
else
SEARCHPATH=$(subst :, ,$(PATH))
endif

# Misc functions
programpath = $(firstword $(strip $(wildcard $(addsuffix /$(1)$(EXEEXT),$(SEARCHPATH)))))

ifneq ($(call programpath,$(notdir $(SHELL))),)
checklib=$(shell $(ECHO) "Checking for -l$(1)... "; $(ECHO) 'program Check; {$$linklib $(1)} begin end.' > check.pas; $(PC) $(PCFLAGS) check.pas > /dev/null 2>&1; if test $$? -eq 0; then ($(ECHO) "yes"; if test ! -f status.sh; then $(ECHO) "ok=1; export ok" > status.sh; fi); else ($(ECHO) "no"; $(ECHO) "ok=0; export ok" > status.sh); fi;)
checkprog=$(shell $(ECHO) "Checking for $(1)\'s path... "; if test -z $(shell $(ECHO) $(call programpath,$(1))); then ($(ECHO) "not found"; $(ECHO) "ok=0; export ok" > status.sh); else $(ECHO) $(call programpath,$(1)); fi;)
checkunit=$(shell $(ECHO) "Checking for unit $(1)... "; $(ECHO) "program Check; uses $(1); begin end." > check.pas; $(PC) $(PCFLAGS) check.pas > /dev/null 2>&1; if test $$? -eq 0; then ($(ECHO) "yes"; if test ! -f status.sh; then $(ECHO) "ok=1; export ok" > status.sh; fi); else ($(ECHO) "no"; $(ECHO) "ok=0; export ok" > status.sh); fi;)
success=$(shell source ./status.sh; if test $$ok -eq 1; then $(ECHO) "You can safely build now"; else $(ECHO) "You\'re missing some requirements\; can\'t build"; fi; $(RM) status.sh)
else
checklib=$(shell $(ECHO) "Testing -l$(1)..."; $(ECHO) "program Check; {$$linklib} begin end." > check.pas" > check.pas; $(PC) $(PCFLAGS) check.pas)
checkprog=$($shell $(ECHO) "Checking for $(1)'s path; $(ECHO) $(call programpath,$(1)))
checkunit=$(shell $(ECHO) "Testing unit $(1)..."; $(ECHO) "program Check"; uses $(1); begin end." > check.pas" > check.pas; $(PC) $(PCFLAGS) check.pas)
success=$(shell $(ECHO) Consult the messages above to ascertain whether you can successfully compile)
endif

# OK, the actual start of the Makefile
VERSION = $(shell $(GIT) describe --always --tag)

SRCDIR ?= .
top_srcdir ?= $(SRCDIR)
srcdir ?= $(top_srcdir)

BUILDDIR ?= .
top_builddir ?= $(BUILDDIR)
builddir ?= $(top_builddir)

export SRCDIR BUILDDIR

EXEOUT ?= $(builddir)

sinclude config.make

PREFIX ?= $(DESTDIR)

ifeq ($(PREFIX),)
ifdef inUnix
PREFIX = /usr/local
else
ifdef OS
PREFIX = /
else
PREFIX = /usr/local
endif # OS
endif # inUnix
endif # PREFIX

prefix = $(PREFIX)

appdir = $(datadir)/applications
bindir = $(prefix)/bin
datadir = $(prefix)/share
docdir = $(datadir)/doc/r3r
icondir = $(datadir)/icons
incdir = $(prefix)/include
libdir = $(prefix)/lib
localedir = $(datadir)/locale
rdatadir = $(datadir)/r3r
skindir = $(rdatadir)/skins

uis = html tui wx

PCFLAGS += $(DEFS) $(PCFLAGS_BASE) $(PCFLAGS_DEBUG) $(PCFLAGS_EXTRA) \
	$(UNITDIRS)

# Defines, for enabling different features/dialect syntax
DEFS = $(foreach opt, $(DEFS_EXTRA) $(DEFS_SETTINGS) $(DEFS_SOCKETS), $(DEFFLAG)$(opt))

UNITDIRS=$(sort $(foreach d,$(wildcard $(addsuffix /*,$(UNIT_DIRS))),$(DIRFLAG)$(dir $(d))))
override COMPILER_OPTIONS += $(PCFLAGS)

USE_EXPAT ?= 1
USE_ICONV ?= 1
USE_IDN ?= 1
USE_NLS ?= 1
USE_PCRE ?= 1

ifdef forUnix
EXPAT_VERSION ?= 2.0
else
EXPAT_VERSION ?= 1.1
endif

ifndef USE_GPC
USE_READLINE ?= 1
else
USE_READLINE = 0
endif

NO_NCURSES ?= 0

USE_LIBEDIT ?= 0
USE_LIBICONV ?= 0
USE_SSL ?= 0

ifneq ($(USE_NLS),0)
override DEFS_EXTRA+=USE_NLS
endif

ifneq ($(USE_IDN),0)
override DEFS_EXTRA+=USE_IDN
endif

ifneq ($(USE_ICONV),0)
override DEFS_EXTRA+=USE_ICONV
endif

ifneq ($(USE_EXPAT),0)
override DEFS_EXTRA+=USE_EXPAT
ifneq ($(EXPAT_VERSION),)
override DEFS_EXTRA+=EXPAT_$(shell $(ECHO) $(EXPAT_VERSION) | $(SED) -e 's/\./_/g')
endif
endif

ifneq ($(NO_NCURSES),0)
override DEFS_EXTRA+=NO_NCURSES
endif

ifneq ($(USE_LIBICONV),0)
override DEFS_EXTRA+=USE_LIBICONV
endif

ifneq ($(USE_PCRE),0)
override DEFS_EXTRA+=USE_PCRE
endif

ifneq ($(USE_READLINE),0)
override DEFS_EXTRA+=USE_READLINE
endif

ifneq ($(USE_LIBEDIT),0)
override DEFS_EXTRA+=USE_LIBEDIT
endif

ifneq ($(USE_SSL),0)
override DEFS_EXTRA+=USE_SSL
endif

ifneq ($(or $(USE_GPC),$(USE_FPC)),)
COMPILER_OVERRIDE=1
endif

R3R_UI ?= tui

ifdef COMPILER_OVERRIDE
ifdef USE_FPC
PC=$(call programpath,fpc)
else
ifdef USE_GPC
PC=$(call programpath,gp)
CC=$(call programpath,gpc)
endif # USE_GPC
endif # USE_FPC
else
PC=$(call programpath,fpc)
ifeq ($(findstring fpc,$(PC)),fpc)
USE_FPC=1
else
PC=$(call programpath,gp)
CC=$(call programpath,gpc)
ifeq ($(findstring gp,$(PC)),gp)
USE_GPC=1
else
$(error No Pascal compiler detected)
endif # USE_GPC
endif # USE_FPC
endif # COMPILER_OVERRIDE

ifdef USE_FPC
override COMPILER=FPC $(shell $(PC) -iW)
PLATFORM=$(shell $(PC) -iTP)-$(shell $(PC) -iTO)

DEFFLAG=-d
PCFLAGS_BASE=-Mclass -Mclassicprocvars -Sh -FE$(EXEOUT) -FU$(builddir) -Fu$(builddir)

ifdef forWindows
override PCFLAGS_BASE+=-WR
endif

DIRFLAG=-Fu
ifdef DEBUG
PCFLAGS_DEBUG=-Ci -Co -Cr -gh -gl

ifneq ($(R3R_UI),wx)
PCFLAGS_DEBUG += -Ct
endif # R3R_UI
else
PCFLAGS_DEBUG=-CX -Xs -XX
endif # DEBUG

DEFS_SOCKETS ?= SOCKETS_SYNAPSE

ifdef forWindows
DEFS_SETTINGS ?= SETTINGS_REG
else
DEFS_SETTINGS ?= SETTINGS_INI
endif # inWindows

ifdef CPU_TARGET
override PCFLAGS_BASE+=-P$(CPU_TARGET)
endif

ifdef OS_TARGET
override PCFLAGS_BASE+=-T$(OS_TARGET)
endif

BUILD_SHARED ?= 1
export USE_FPC
else
ifdef USE_GPC
GPC=$(call programpath,gpc)
ifneq ($(HOST),)
override GPC := $(subst gpc,$(HOST)-gpc,$(GPC))
endif
override COMPILER=GPC $(shell $(GPC) -dumpversion)
PLATFORM=$(shell $(GPC) -dumpmachine)

PCFLAGS_BASE=--cstrings-as-strings --no-write-clip-strings \
						 --extended-syntax \
						 --unit-destination-path=$(builddir)\
						 -DFree=Destroy -DPtrUInt=PtrWord \
						 -DWideChar=Chr -DTrimRight=wTrimRight\
						 -DNO_SUPPORTS_UNICODE $(LDFLAGS)
DEFFLAG=-D
DEFS_SETTINGS ?= SETTINGS_LIBINI
DEFS_SOCKETS ?= SOCKETS_LIBCURL
DIRFLAG=--unit-path=
PPUEXT=.gpi

ifdef DEBUG
PCFLAGS_DEBUG=--pointer-checking --progress-messages \
	--stack-checking -ggdb3
else
PCFLAGS_DEBUG=--no-io-checking --no-pointer-checking \
							--no-range-checking --no-stack-checking \
							--no-warning
endif # DEBUG

# Let's get the proper LDFLAGS
ifeq ($(DEFS_SOCKETS),SOCKETS_LIBCURL)
override LDFLAGS+=-lcurl
endif

ifneq ($(SETTINGS_LIBINI),0)
override LDFLAGS+=-lini
endif

ifneq ($(USE_EXPAT),0)
ifeq ($(ExpatLib),)
override LDFLAGS+=-lexpat
else
override LDFLAGS+=-l$(ExpatLib)
endif
endif

# glibc's implementation of iconv seems to not work well in GPC
ifneq ($(USE_ICONV),0)
$(warning Using libiconv. You may need to define USE_ICONV=0 or install libiconv.)
override DEFS_EXTRA+=USE_LIBICONV
ifndef forDOS
override LDFLAGS+=-liconv
else
override LDFLAGS+=-llibiconv
endif
endif

ifneq ($(USE_IDN),0)
override LDFLAGS+=-lidn
endif

ifneq ($(USE_NLS),0)
override LDFLAGS+=-lintl
endif

ifneq ($(USE_PCRE),0)
ifeq ($(PcreLib),)
override LDFLAGS+=-lpcre
else
override LDFLAGS+=-l$(PcreLib)
endif
endif

export USE_GPC
endif # USE_GPC
endif # USE_FPC

# Let's try to figure out what OS we're using
HOST ?= $(PLATFORM)
ifneq ($(HOST),)
CPU_TARGET ?= $(shell $(ECHO) $(HOST) | $(CUT) -d '-' -f 1)
OS_TARGET ?= $(shell $(ECHO) $(HOST) | $(CUT) -d '-' -f 3)
ifeq ($(OS_TARGET),)
override OS_TARGET = $(shell $(ECHO) $(HOST) | $(CUT) -d '-' -f 2)
endif
endif

ARCH ?= $(CPU_TARGET)
PKGRELEASE ?=1

export CC DEFS DEFS_SOCKETS DESTDIR R3R_UI VERSION \
	OS_TARGET CPU_TARGET \
	bindir datadir prefix rootdir

default: all

_all:
ifeq ($(wildcard $(builddir)),)
	@$(MKDIR) $(builddir)
endif

all: _all

_clean:
	$(DEL) $(wildcard *$(GPDEXT))
	$(DEL) $(wildcard *$(OEXT))
	$(DEL) $(wildcard *$(PPUEXT))
	$(DEL) $(wildcard *$(STATICLIBEXT))
	$(DEL) $(wildcard *.mo) $(wildcard *.po~)

cleanbuild:
ifneq ($(BUILDDIR),$(SRCDIR))
	cd $(BUILDDIR) && $(MAKE) _clean
endif

clean: _clean cleanbuild

distclean: clean

%$(PPUEXT): %.pas
	$(PC) $(PCFLAGS) $<

# Gettext

.SUFFIXES:
.SUFFIXES: .mo .po .pot

po_files = $(wildcard *.po)
LINGUAS ?= $(subst .po,,$(po_files))
ifneq ($(LINGUAS),)
mo_files = $(addsuffix .mo,$(LINGUAS))
else
mo_files = $(subst .po,.mo,$(po_files))
override LINGUAS := $(subst .mo,,$(mo_files))
endif

MSGFMT ?= $(call programpath,msgfmt)
MSGMERGE ?= $(call programpath,msgmerge)
XGETTEXT ?= $(call programpath,xgettext)

MSGFMTFLAGS ?= -c --statistics
