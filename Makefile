.PHONY: all clean

all: build/polifax.html build/polifax-full.html build/polifax-ascii.html

clean:
	rm -f build/*

#-------------------------------------------------------------------------------
# polifax
#-------------------------------------------------------------------------------

build/polifax.ttf: polifax.kbitx
	@printf '\n\033[1;32mGenerating font %s:\033[m\n' $@
	@mkdir -p $(@D)
	rm -f $@ 2>/dev/null; \
	bitsnpicas convertbitmap -t ttf -o $@ $<

build/polifax.html: polifax.kbitx build/polifax.ttf
	@printf '\n\033[1;32mGenerating html test file %s:\033[m\n' $@
	@mkdir -p $(@D)
	generate-html $^ > $@

#-------------------------------------------------------------------------------
# polifax-full
#-------------------------------------------------------------------------------

build/polifax-full.kbitx: polifax.kbitx
	@printf '\n\033[1;32mGenerating %s:\033[m\n' $@
	@mkdir -p $(@D)
	#FIXME: sed -i is GNU-ism, isn't POSIX, and works differently in BSD-land
	python bin/polifax-merge.py
	sed -i 's/Polifax/Polifax-full/' $@

build/polifax-full.ttf: build/polifax-full.kbitx
	@printf '\n\033[1;32mGenerating %s:\033[m\n' $@
	@mkdir -p $(@D)
	rm -f $@ 2>/dev/null; \
	bitsnpicas convertbitmap -t ttf -o $@ $<

build/polifax-full.html: build/polifax-full.kbitx build/polifax-full.ttf
	@printf '\n\033[1;32mGenerating html test file %s:\033[m\n' $@
	@mkdir -p $(@D)
	generate-html $^ > $@

#-------------------------------------------------------------------------------
# polifax-ascii
#-------------------------------------------------------------------------------

build/polifax-ascii.kbitx: polifax.kbitx
	@printf '\n\033[1;32mGenerating %s:\033[m\n' $@
	@mkdir -p $(@D)
	{ awk  '{ sub("Polifax", "Polifax-ascii"); print } \
	        /^<g u="126"/ { exit }                     \
	       ' $<                                      ; \
	  grep '^<g n=".notdef"' $<                      ; \
	  echo '</kbits>'                                ; \
	} > $@

build/polifax-ascii.ttf: build/polifax-ascii.kbitx
	@printf '\n\033[1;32mGenerating font %s:\033[m\n' $@
	@mkdir -p $(@D)
	rm -f $@ 2>/dev/null; \
	bitsnpicas convertbitmap -t ttf -o $@ $<

build/polifax-ascii.html: build/polifax-ascii.kbitx build/polifax-ascii.ttf
	@printf '\n\033[1;32mGenerating html test file %s:\033[m\n' $@
	@mkdir -p $(@D)
	generate-html $^ > $@
