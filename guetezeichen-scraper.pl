#!/usr/bin/perl 

use strict;
use warnings;
use utf8;
use feature qw(say);
use Data::Dumper;
use HTML::TreeBuilder::XPath;
use WWW::Mechanize;

my $url = 'https://www.guetezeichen.at/zertifizierte-shops/guetezeichen';
my $DEBUG = 0;
my $type = 'Österreichisches E-Commerce-Gütezeichen';

binmode(STDOUT, ":utf8");

my ($sec,$min,$hour,$day,$month,$yr19,@rest) =   localtime(time);#####
print "Source: Verein zur Förderung der kundenfreundlichen Nutzung des Internet c/o ÖIAT, answered on " . sprintf("%4.4d-%2.2d-%2.2d", ($yr19+1900), ++$month, $day) . ": $url\n";

my $tree= HTML::TreeBuilder::XPath->new;
my $mech=WWW::Mechanize->new(agent => 'guetezeichen-scraper');
$mech->get($url);
$tree->parse($mech->content); 
my @td = $tree->findnodes( '//tr');
foreach my $row (@td) {
	my $tdclass = $row->attr('class');
	next if ( defined ($tdclass) and lc($tdclass) eq 'error');
	my $oname = $row->findnodes('.//td[@class="col1"]');
	my $name  = $oname->[0];
	my $tdurl = $row->findnodes('.//td[@class="col3"]');
	my $shopurl   = $tdurl->[0]->findnodes('a')->[0];
	if(defined $name and defined $shopurl) {
		my $desc = $name->as_text();
		$desc =~ s/\,/\;/gi;	# cleanup for csv export
		my $href = $shopurl->attr('href');
		$href =~ s/^https?:\/\///;
		if(defined $ARGV[0]) { # strip www hostname unless explicitly forbidden
			$href =~ s/^(www\.)//;
		}
		if(not defined $ARGV[1]) { # strip URL path unless explicitly told to keep
			my @words = split('/', $href);
			$href = $words[0];
		}
		print "$href,$type,$desc,,\n";
	}
}

