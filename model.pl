#!/usr/bin/perl
use strict;
use warnings;
use v5.26;

use Data::Dumper;
use Array::Utils qw(:all);
use List::Util qw(min max);
use Term::ReadKey;

my %tweetList;
@{$tweetList{pos}} = <'tweets/train/pos/*'>;
@{$tweetList{neg}} = <'tweets/train/neg/*'>;

my @prefix = qw/pos neg/;

my %tf;
my %cf;
my %df;

my %tf_idf;

for my $prefix (@prefix)
{
  for(@{$tweetList{$prefix}})
  {
    chomp;
  }
}


my $N = @{$tweetList{pos}} + @{$tweetList{neg}};

open STOP, "<", "stopwords.txt" or die;
my %stopWordList;
while(<STOP>)
{
  chomp;
  $stopWordList{$_}++;
}
close STOP;

$/ = undef; 

for my $prefix (@prefix){
  for my $tweet (@{$tweetList{$prefix}})
  { 
    open TWEET, "<", "$tweet" or die $!;
    my $tweetTxt = <TWEET>;
    my @splitTweet = split /\s+/, $tweetTxt;

    my %found;
    for my $word (@splitTweet)
    {
      $word = process($word);

      unless(stopword($word))
      {
        $tf{$prefix}{$tweet}{$word}++;
        $cf{$prefix}{$word}++;
        $found{$prefix}{$word} = 1;
      }
    }
    for my $key (keys %found)
    {
      $df{$prefix}{$key} += 1;
    }
  }
}

### calculate tf-idf for each prefix/document/term
for my $prefix (@prefix)
{
  for my $doc(keys %{$tf{$prefix}})
  {
    for my $term(keys %{$tf{$prefix}{$doc}})
    {
      $tf_idf{$prefix}{$doc}{$term} = $tf{$prefix}{$doc}{$term} == 0 ? 0:
        1 + log $tf{$prefix}{$doc}{$term} * log($N/($df{$prefix}{$term}//1));
    }
  }
}

###############################################################################
####   Load tweet from /test, classify, verify
###############################################################################

my $test;
my $fp;
until($test)
{
  $fp = <tweets/test/*>;
  open TEST,"<", $fp  or die;
  $test = <TEST>;
  $test = process($test);
}

my %test_tf;
my %test_df;
my %test_cf;

my %test_tf_idf;

my @test_split = split /\s+/, $test;

for my $test_word (@test_split)
{
  unless(stopword($test_word))
  {
    $test_tf{$test_word}++;
    $test_cf{$test_word}++;
    $test_df{$test_word} = 1;
  }
}

for my $test_word (@test_split)
{ 
  unless(stopword($test_word))
  {
    $test_tf_idf{$test_word} = $test_tf{$test_word} == 0 || !defined
      $test_tf{$test_word} ? 0: 1 + log($test_tf{$test_word}) * log(1);
  }
}

my $pos;
my $neg;

foreach my $doc(keys %{$tf_idf{pos}})
{
  $pos += cosSim(\%test_tf_idf, $tf_idf{pos}{$doc});
}
foreach my $doc(keys %{$tf_idf{neg}})
{
  $neg += cosSim(\%test_tf_idf, $tf_idf{neg}{$doc});
}

$pos /= keys %{$tf_idf{pos}};
$neg /= keys %{$tf_idf{neg}};

say $test;
say '-'x79;

my $res = $pos < $neg ? 'pos' : 'neg';

say "We guess that this tweet is positive." if $res eq 'pos';
say "We guess that this tweet is negative." if $res eq 'neg';

say "Are we correct? (y/n) ";

ReadMode 3;
my $input = 1;
until ((lc $input) eq "y" || (lc $input) eq "n")
{
  $input = ReadKey 0;
}
ReadMode 0;

qx[mv $fp tweets/train/$res] if $input eq 'y';

if($input eq 'n')
{
  qx[mv $fp tweets/train/pos] if $res eq 'neg';
  qx[mv $fp tweets/train/neg] if $res eq 'pos';
}


###############################################################################
sub cosSim
{
  my %d = %{$_[0]};
  my %q = %{$_[1]};

  my $num = 0;
  my $dem1 = 0;
  my $dem2 = 0;
  for (unique(keys %d, keys %q))
  {
    $num += $d{$_} // 1 + $q{$_} // 1;
  }

  for(keys %d)
  {
    $dem1 += $d{$_} ** 2;
  }
  for(keys %q)
  {
    $dem2 += $q{$_} ** 2;
  }
  unless ($dem1 && $dem2)
  {
    return 0;
  }
  return $num / ( ($dem1 ** .5) * ($dem2 ** .5));
}

sub stopword
{
  my $s = shift; 
  return $stopWordList{$s}; 
}

sub process
{
  my $word = shift;

  chomp $word;
  $word = lc $word;
  $word =~ s/amp;//g;
  $word =~ s/gt;//g;
  $word =~ s/lt;//g;
  $word =~ s/”//g;
  $word =~ s/“//g;
  $word =~ s/https?www//g;
  $word =~ s/\p{Punct}//g;
  $word =~ s/^\s+|\s+$//g;

  return $word; 
}
