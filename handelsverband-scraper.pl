#!/usr/bin/perl 

use strict;
use warnings;

use utf8;
use feature qw(say);
use Data::Dumper;
use HTML::TreeBuilder::XPath;
use WWW::Mechanize;
use Getopt::Long;

my $url = 'https://www.handelsverband.at/mitglieder-partner/mitglieder/';
my $type = 'Handelsverband Österreich | Austrian Retail Association';
my $DEBUG = 0;

binmode(STDOUT, ":utf8");

my ($removewww, $removepath);
GetOptions ('remove-www' => \$removewww, 'remove-path' => \$removepath);

my ($sec,$min,$hour,$day,$month,$yr19,@rest) = localtime(time);
print "# Source: Handelsverband Österreich | Austrian Retail Association, answered on " . sprintf("%4.4d-%2.2d-%2.2d", ($yr19+1900), ++$month, $day) . ": $url,,\n";

my $tree= HTML::TreeBuilder::XPath->new;
my $mech=WWW::Mechanize->new(agent => 'handeslverband-scraper');
$mech->get($url);
$tree->parse($mech->content); 
my @td = $tree->findnodes('//div[@class="col-md-4 col-sm-6"]/a');	# company list entries
foreach my $a (@td) {	# iterate over company list
	my $href = '/' . $a->attr('href');	# find link to company details
	my $name = $a->findnodes('.//div/h2')->[0]->as_text();
	$name =~ s/\,/\;/gi;	# cleanup for csv export
	$mech->get($href);	# get details on company
	my $shoptree = HTML::TreeBuilder::XPath->new;
	$shoptree->parse($mech->content); 	#get details for company
	my $factboxes = $shoptree->findnodes('//div[@class="factbox"]');
	my $shopentry = $factboxes->[0]->findnodes('.//a[@target]')->[0];
	my $shopurl = '';
	if(defined $shopentry) {
		$shopurl = $shopentry->attr('href');
		if( $shopurl =~ /^https?:\/\/$/ ) {
			$shopurl .= $shopentry->attr('target');	# special case 'Conrad'
		}
	# sometime, the link is not a link
	} elsif ($factboxes->[0]->as_text() =~ /.*W ((https?:\/\/|www)\S+).*/i ) {
		$shopurl = $1;
	# and sometimes, there is not even a link, so we get the domain from the mail link ...
	} elsif ($factboxes->[0]->as_text() =~ /.*\@(\S+).*/i ) {
		$shopurl = $1;
	} else {
		warn "No URL found in factbox >>" . $factboxes->[0]->as_text() . "<<";
		next;
	}
	# cleanup
	$shopurl =~ s/^https?:\/\/(www\.)?//;
	my @words = split('/', $shopurl);
	$shopurl = $words[0];
	say "$shopurl,$type,$name,,";
}
