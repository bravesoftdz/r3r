UNIT_DIRS = .. ../../utils/* ../../bindings/*
UNITS = rsettings_routines rsettings_strings rsettings

include ../../../scripts/common.make

all:
	cd .. && $(MAKE) info.pas
	$(MAKE) units

units: $(addsuffix $(PPUEXT),$(UNITS))
