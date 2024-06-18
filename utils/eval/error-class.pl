#!/usr/bin/env perl
# Copyright 2020-2024, Hojin Koh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Check a predicted table for error, first argument is label file

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my $fileLabel = $ARGV[0];

my %mWeight;
if (@ARGV > 1) {
  my $fileWeight = $ARGV[1];
  open(my $FP, "<", $fileWeight) || die "Can't open $fileWeight: $!";
  while (<$FP>) {
      chomp;
      my ($key, $weight) = split(/\t/, $_, 2);
      $mWeight{$key} = $weight;
  }
  close($FP);
}

my %mLabel;
open(my $FP, "<", $fileLabel) || die "Can't open $fileLabel: $!";
while (<$FP>) {
    chomp;
    my ($key, $labels) = split(/\t/, $_, 2);
    @{$mLabel{$key}} = split(/\s+/, $labels);
    if (!exists $mWeight{$key}) {
      $mWeight{$key} = 1.0;
    }
}
close($FP);

while (<STDIN>) {
    chomp;
    my ($key, $pred) = split(/\t/, $_, 2);
    for my $l (@{$mLabel{$key}}) {
      if ($pred eq $l) {
        print "$key\t0\t$mWeight{$key}\n";
        next;
      }
    }
    print "$key\t100\t$mWeight{$key}\n";
}
