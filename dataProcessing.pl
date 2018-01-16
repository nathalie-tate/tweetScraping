#!/usr/bin/perl

# Note: writing to disk to save RAM. Would be faster to use an @rray instead

use warnings;
use strict;
use utf8;

use LWP::Simple;

open INFILE,"<","twitterData.old" or die;
open OUTFILE,">","twitterData.new" or die;
open URLFILE,">","twitterData.urls" or die;

my @tweetID;

### remove ReTweets, put remaining Tweets into new file
### store tweet urls
while(<INFILE>)
{
  if($_ =~ /^(\d{18})\s+\S{3}\s+\d\d\s+\d\d\:\d\d\s+\@(\S+)\s+(\S+.*)/)
  {
    if($3 !~ /^RT\s*.*/)
    {
      print OUTFILE $_;
      print URLFILE qq{https://twitter.com/$2/status/$1\n};
    }
  }
}

### Download full Tweets
open URLFILE,"<","twitterData.urls" or die;
my $url;
while (<URLFILE>)
{
  $url = $_;
  ### get ID, open FH
  my ($id) = $url =~ /https:\/\/twitter.com\/\w+\/status\/(\d+)/;
  open TMPFH,">:utf8","tweets/$id" or die;

  ### get HTML

  ### skip 404s (deleted tweets, accs)
  my $html;
  unless ($html = get($url))
  {
    next;
  }
  my @html = split /\n/,$html;
  #my @html = get($url);
  for my $tweet (@html)
  {
    if($tweet =~ /<meta  property="og:description" content=([^>]+)>/)
    {
      my $tmp = $1;
      $tmp = trim($tmp);
      $tmp && print TMPFH $tmp;
      last; 
    }
  } 
}

sub trim
{
  my $s = shift;

  ### remove quotes
  $s =~ s/^..(.+)..$/$1/;
  ### remove linefeeds
  $s =~ s/&#10;/ /g;

  $s =~ s/&#\d+;/ /g;
  $s =~ s/&\w+;/ /g;

  #remove links
  $s =~ s/https:\/\/t.co\/\S+/ /g;

  #remove common punctuation
  $s =~ s/\./ /g;
  $s =~ s/\,/ /g;
  $s =~ s/\?/ /g;
  $s =~ s/\!/ /g;
  $s =~ s/\#/ /g;

  $s =~ s/^\s+|\s+$//g;  

  return $s;
}
