.DEFAULT_GOAL := all
.PHONY : all
.PHONY : clean
.PHONY : clean-sources

HEADER = Domain Name,Domain Type,Agency,City,State

data/source/guetezeichen-at-domains.csv:
	perl guetezeichen-scraper.pl | sort -d -f -t',' -k1,1 > $@

data/source/guetezeichen-at-urls.csv:
	perl guetezeichen-scraper.pl KEEP_URLS | sort -d -f -t',' -k1,1 > $@

data/domains.guetezeichen-at.csv: data/source/guetezeichen-domains.csv
	echo ${HEADER} > $@
	tail -q -n +1 $+ >> $@

data/domains.csv: data/source/guetezeichen-at-domains.csv
	echo ${HEADER} > $@
	tail -q -n +1 $+ >> $@

clean-sources:
	rm -f data/source/guetezeichen-at-domains.csv
	rm -f data/source/guetezeichen-at-urls.csv

clean: clean-sources
	rm -f data/domains*

all: data/domains.csv
