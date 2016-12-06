.DEFAULT_GOAL := all
.PHONY : all
.PHONY : clean
.PHONY : clean-sources

HEADER = Domain Name,Domain Type,Agency,City,State

data/source/guetezeichen-at-domains.csv:
	perl guetezeichen-scraper.pl -remove-www -remove-path > $@

data/source/guetezeichen-at-urls.csv:
	perl guetezeichen-scraper.pl > $@

data/domains-guetezeichen-at.csv: data/source/guetezeichen-at-domains.csv
	echo ${HEADER} > $@
	tail -q -n +2 $+ >> $@

data/urls-guetezeichen.csv: data/source/guetezeichen-at-urls.csv
	echo ${HEADER} > $@
	tail -q -n +2 $+ >> $@

data/source/handelsverband-domains.csv:
	perl handelsverband-scraper.pl > $@

data/domains-handelsverband.csv: data/source/handelsverband-domains.csv
	echo ${HEADER} > $@
	tail -q -n +2 $+ >> $@

data/domains.csv: data/source/guetezeichen-at-domains.csv data/source/handelsverband-domains.csv
	echo ${HEADER} > $@
	tail -q -n +2 $+ | sort >> $@

clean-sources:
	rm -f data/source/guetezeichen-at-domains.csv
	rm -f data/source/guetezeichen-at-urls.csv
	rm -f data/source/handelsverband-domains.csv

clean: clean-sources
	rm -f data/domains*

all: data/domains.csv 
