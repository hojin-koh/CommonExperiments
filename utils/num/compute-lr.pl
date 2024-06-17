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

# Compute likelihood ratio (in log) inside a table

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

use List::Util qw(reduce);

my $mode = $ARGV[0];

sub logadd {
  my ($a, $b) = @_;

  # Handle cases where one or both inputs are unusable
  return $a if $b == -Inf;
  return $b if $a == -Inf;

  # Ensure a is the larger of the two (without loss of generality)
  ($a, $b) = ($b, $a) if $a < $b;

  return $a + log(1 + exp($b - $a));
}

while (<STDIN>) {
    chomp;
    my ($key, $values) = split(/\t/, $_, 2);
    my @aAll = split(/\s+/, $values);
    my @aOutput;

    if ($mode eq "all") {
      for my $i (0 .. $#aAll) {
        push @aOutput, $aAll[$i] - (reduce { logadd $a, $b } -Inf, @aAll);
      }
    } else {
      # TODO
    }

    print "$key\t" . join("\t", @aOutput) . "\n";
}
