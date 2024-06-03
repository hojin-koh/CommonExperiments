.NOTPARALLEL:

.NOTINTERMEDIATE:

.ONESHELL:

.DEFAULT_GOAL := all

CPSDICTCNFREQ = craw/download-dict/china-wordfreq.xls
CPSDICTCHINA = craw/download-dict/china-city-id.json
CPSDICTJP2 = craw/download-dict/wiki-japan2.html
CPSDICTJP1 = craw/download-dict/wiki-japan1.html
CPSDICTCITY2 = craw/download-dict/wiki-city2.html
CPSDICTCITY1 = craw/download-dict/wiki-city1.html
CPSDICTCAPITAL = craw/download-dict/wiki-capital.html
CPSDICTCOUNTRY = craw/download-dict/wiki-country.html
CPSDICTTWAREA = craw/download-dict/tw-area-list.py
CPSDICTID = craw/download-dict/twmoe-dict-idioms.zip
CPSDICTCON = craw/download-dict/twmoe-dict-concised.zip

DICTOUT = dl/dict-tw-general.zst
DICTCOMB = ds/dict-tw-general-unnorm.zst
DICTIN = ds/dict-twmoe-concised-unnorm.zst ds/dict-twmoe-idioms-unnorm.zst ds/dict-twmoe-zhuyin-unnorm.zst \
	  ds/dict-tw-area-unnorm.zst ds/dict-world-country-unnorm.zst ds/dict-world-capital-unnorm.zst \
	  ds/dict-world-city-unnorm.zst ds/dict-japan-area-unnorm.zst ds/dict-china-city-unnorm.zst \
	  ds/dict-china-general-freqword.zst
DICTALL = $(DICTOUT) $(DICTCOMB) $(DICTIN)

CPSVARIANT = craw/download-dict/twmoe-variants.txt
CPSCONFUSABLE = craw/download-dict/icu-confusable-20240412.txt
CPSGOOGLENGRAM = craw/download-dict/google-ngram-zh-2020.gz
CPSTWMOEFREQ = craw/download-dict/twmoe-shrest2.zip

FREQOUT = dl/charfreq-tw.zst
FREQCOMB = ds/charfreq-tw-unnorm.zst
FREQIN = ds/charfreq-twmoe-unnorm.zst ds/charfreq-google-unnorm.zst
FREQALL = $(FREQOUT) $(FREQCOMB) $(FREQIN)

NORMOUT = dl/variants-twmoe.zst
NORMALL = $(NORMOUT)


# Get the basic, unnormalized frequency list

$(word 1,$(FREQIN)):
	@ss/import-twmoe-charfreq.zsh \
		in=$(CPSTWMOEFREQ) out=$@

$(word 2,$(FREQIN)):
	@ss/import-google-charfreq.zsh \
		in=$(CPSGOOGLENGRAM) out=$@

$(FREQCOMB): $(FREQIN)
	@sc/merge-table.zsh --normalize \
		w=0.9 in=$(word 1,$(FREQIN)) \
		w=0.1 in=$(word 2,$(FREQIN)) \
		out=$@


# Get normalizer and final frequency list

$(NORMOUT): $(FREQCOMB)
	@ss/import-twmoe-variants.zsh \
		in=$(CPSVARIANT) confusable=$(CPSCONFUSABLE) \
		infreq=$< out=$@

$(FREQOUT): $(FREQCOMB) $(NORMOUT)
	@sc/normalize-unicode-key.zsh \
		conv=$(word 2,$^) \
		in=$< out=$@


# Make dictionaries

$(word 1,$(DICTIN)):
	@ss/import-twmoe-dict.zsh \
		in=$(CPSDICTCON) out=$@

$(word 2,$(DICTIN)):
	@ss/import-twmoe-idioms.zsh \
		in=$(CPSDICTID) out=$@

$(word 3,$(DICTIN)):
	@ss/import-twmoe-zhuyin.zsh \
		in=$(CPSDICTCON) out=$@

$(word 4,$(DICTIN)):
	@ss/import-tw-area-list.zsh \
		in=$(CPSDICTTWAREA) out=$@

$(word 5,$(DICTIN)):
	@ss/import-world-country-list.zsh \
		in=$(CPSDICTCOUNTRY) out=$@

$(word 6,$(DICTIN)):
	@ss/import-world-capital-list.zsh \
		in=$(CPSDICTCAPITAL) out=$@

$(word 7,$(DICTIN)):
	@ss/import-world-important-city-list.zsh \
		in1=$(CPSDICTCITY1) in2=$(CPSDICTCITY2) out=$@

$(word 8,$(DICTIN)):
	@ss/import-japan-area-list.zsh \
		in1=$(CPSDICTJP1) in2=$(CPSDICTJP2) out=$@

$(word 9,$(DICTIN)):
	@ss/import-china-city-list.zsh \
		in=$(CPSDICTCHINA) out=$@

$(word 10,$(DICTIN)):
	@ss/import-china-freqword.zsh \
		in=$(CPSDICTCNFREQ) out=$@

$(DICTCOMB): $(DICTIN)
	@sc/merge-table.zsh \
		$(foreach i,$(DICTIN),in=$(i)) \
		out=$@

$(DICTOUT): $(DICTCOMB) $(NORMOUT)
	@sc/normalize-unicode-key.zsh \
		conv=$(word 2,$^) \
		in=$< out=$@



all: $(DICTOUT) $(FREQOUT) $(NORMOUT)

EVERYTHING = $(DICTALL) $(FREQALL) $(NORMALL)

clean:
	@rm -fv $(EVERYTHING)
	@rm -fv $(foreach f,$(EVERYTHING),$(f).meta)
