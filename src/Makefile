
SUBDIRS = $(wildcard */.)
LINKS = $(foreach i,kenlm mitlm,../bin/$(i))

all: $(SUBDIRS) $(LINKS)

$(SUBDIRS):
	$(MAKE) -C $@

../bin/kenlm:
	ln -nsfv /opt/kenlm/bin ../bin/kenlm
	@if [[ ! -x ../bin/kenlm/lmplz ]]; then echo "NOTE: You have to manually link KenLM's bin/ folder to bc/kenlm" >&2; fi

../bin/mitlm:
	ln -nsfv /usr/bin ../bin/mitlm
	@if [[ ! -x ../bin/mitlm/estimate-ngram ]]; then echo "NOTE: You have to manually link MITLM bin/ folder to bc/mitlm" >&2; fi

.PHONY: all $(SUBDIRS)
