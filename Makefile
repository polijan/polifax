.PHONY: all kbitx ttf clean

all: kbitx ttf

kbitx: build/polifax-ascii.kbitx build/polifax-full.kbitx

ttf: build/polifax.ttf build/polifax-ascii.ttf build/polifax-full.ttf

clean:
	rm -f build/*


build/polifax-ascii.kbitx: polifax.kbitx
	@printf '\n\033[1;32mGenerating %s:\033[m\n' $@
	@mkdir -p $(@D)
	{ awk  '{ sub("Polifax", "Polifax-ascii"); print } \
	        /^<g u="126"/ { exit }                     \
	       ' $<                                      ; \
	  grep '^<g n=".notdef"' $<                      ; \
	  echo '</kbits>'                                ; \
	} > $@

build/polifax-full.kbitx: polifax.kbitx
	@printf '\n\033[1;32mGenerating %s:\033[m\n' $@
	@mkdir -p $(@D)
	#FIXME: sed -i is GNU-ism, isn't POSIX, and works differently in BSD-land
	python bin/polifax-merge.py
	sed -i 's/Polifax/Polifax-full/' $@

build/polifax.ttf: polifax.kbitx
	@printf '\n\033[1;32mGenerating font %s:\033[m\n' $@
	@mkdir -p $(@D)
	rm -f $@ 2>/dev/null; \
	bitsnpicas convertbitmap -t ttf -o $@ $<

build/polifax-ascii.ttf: build/polifax-ascii.kbitx
	@printf '\n\033[1;32mGenerating font %s:\033[m\n' $@
	@mkdir -p $(@D)
	rm -f $@ 2>/dev/null; \
	bitsnpicas convertbitmap -t ttf -o $@ $<

build/polifax-full.ttf: build/polifax-full.kbitx
	@printf '\n\033[1;32mGenerating %s:\033[m\n' $@
	@mkdir -p $(@D)
	rm -f $@ 2>/dev/null; \
	bitsnpicas convertbitmap -t ttf -o $@ $<
