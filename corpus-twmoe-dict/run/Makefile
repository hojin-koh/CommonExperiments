.NOTPARALLEL:

.ONESHELL:

NORMALIZER := dl/twmoe-variants.zst

ds/twmoe-dict-idioms-unnorm.zst:
	@ss/import-twmoe-idioms.zsh \
		in=craw/twmoe-dict-idioms.zip out=$@

ds/twmoe-dict-concised-unnorm.zst:
	@ss/import-twmoe-dict.zsh \
		in=craw/twmoe-dict-concised.zip out=$@

ds/twmoe-charfreq.zst: ds/twmoe-charfreq-unnorm.zst $(NORMALIZER)
	@sc/normalize-unicode-key.zsh \
		conv=dl/twmoe-variants.zst \
		in=$< out=$@

$(NORMALIZER): ds/twmoe-charfreq-unnorm.zst
	@ss/import-twmoe-variants.zsh \
		in=craw/twmoe-variants.txt confusable=craw/icu-confusable-20240412.txt \
		infreq=$< out=$@

ds/twmoe-charfreq-unnorm.zst:
	@ss/import-twmoe-charfreq.zsh \
		in=craw/twmoe-shrest2.zip out=$@

