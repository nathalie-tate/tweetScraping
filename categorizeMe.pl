#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use v5.26;

use Term::ReadKey;

my $trainNum = qx{ls -l tweets/train/pos | wc -l} + qx{ls -l tweets/train/neg | wc -l} - 2;
my $testNum = qx{ls -l tweets/test | wc -l} -1;

my $termSize;
($termSize, @_) = GetTerminalSize();

my @list = qx{ls tweets/test};
@list = map trim($_), @list;

my $input;
my $id;

while ($testNum > $trainNum)
{
  $id = pop @list;

  print "\033[2J";
  print "\033[0;0H";

  unless($id)
  {
    next;
  }

  my $tmp = "tweets/test/$id";
  open TWEET,"<", $tmp or next;
  my $tweet = <TWEET>;

  say $tweet;
  say "";
  say '-' x $termSize;
  say "";
  say "(P)ositive, (N)egative?                      [$trainNum  Categorized]";
  
  ReadMode 3;
  $input = 1;
  until ($input eq "" || (lc $input) eq "p" || (lc $input) eq "n")
  {
    $input = ReadKey 0;
  }
  ReadMode 0;

  if($input eq "p")
  { 
    qx{mv tweets/test/$id tweets/train/pos/$id};
  }
  elsif($input eq "n")
  {
    qx{mv tweets/test/$id tweets/train/neg/$id};
  }
  else
  {
    exit; 
  }
  $trainNum = qx{ls -l tweets/train/pos | wc -l} + qx{ls -l tweets/train/neg | wc -l} - 2;
}

sub trim
{
  my $tmp = shift;
  $tmp =~ s/^\s+|\s+$//g;  
  return $tmp;
} 
