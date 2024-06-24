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

# Filter moedict wordlist

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

while (<STDIN>) {
  chomp;
  my ($w, $tag) = split(/\t/, $_, 2);

  # Remove punctuation
  $w =~ s/\p{P}//g;

  next if length($w) < 2;

  # Blacklist
  next if $w =~ /兒/;

  # Post-processing some weird words
  if (length($w) == 8) {
    print substr($w, 0, 4) . "\t$tag\n";
    print substr($w, 4) . "\t$tag\n";
  } elsif (length($w) == 10) {
    print substr($w, 0, 5) . "\t$tag\n";
    print substr($w, 5) . "\t$tag\n";
  }

  print "$w\t$tag\n";
}
