OPENSCAD=openscad

all: dpad.stl button.stl bottom.stl top.stl

%.stl: nrfgamecase.scad
	$(OPENSCAD) -o $@ -D part='"$*"' $<
