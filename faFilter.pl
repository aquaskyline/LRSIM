#!/usr/bin/perl

use strict;
use warnings;
my $columns = 70;

my $fa_file = shift;
my $len = shift;
$len = (defined $len) ? $len : 100;
die "perl $0 fa_file [length cut off]\n" unless $fa_file;

open IN, $fa_file or die $!;
$/=">"; $/=<IN>; $/="\n";
while (<IN>){
  chomp;
  my $id = $_;

  $/=">";
  my $seq=<IN>;
  chomp $seq;
  $seq=~s/\s+//g;
  $/="\n";

  my $length = length($seq);
  next if $length < $len;

  print ">$id\n";
  for(my $i = 0; $i < length($seq); $i += $columns)
  {
    print substr($seq, $i, $columns);
    print "\n";
  }
}
close IN;

