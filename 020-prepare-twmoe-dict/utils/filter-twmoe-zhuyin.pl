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

# Post-process zhuyin combinations from twmoe concised dictionary

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

while (<STDIN>) {
  chomp;
  my ($plist, $tag) = split(/\t/, $_, 2);

  next if length($plist) < 2;

  # Replace full-width space with half-width space
  $plist =~ s/　/ /g;

  # Some tone marks don't have space following it
  $plist =~ s/([ˊˇˋ])(\S)/$1 $2/g;

  for my $w (split /\s+/, $plist) {
    $w =~ s/^\s+|\s+$//g;  # trim
    $w =~ s/^˙//;
    $w =~ s/ㄦ$//;

    if (length($w) >= 2) {
      print "$w\t$tag\n";
    }

    $w =~ s/[ˊˇˋ]$//;  # remove tone marks at the end

    if (length($w) >= 2) {
      print "$w\t$tag\n";
    }
  } # end for each pronounciation

}
