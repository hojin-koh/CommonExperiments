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

# Filter twmoe concised dictionary entries

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
  next if $w =~ /縣$/ && $w ne "知縣";
  next if length($w) > 6 && $w =~ /多一事不如少一事|建設|戰機|打狗|系統|地址|號誌/;
  next if length($w) > 6 && $w =~ /指數$|獎$|制度$|政策$|中心$/;
  next if (length($w) == 3 && $w =~ /的$/) || $w =~ /端的$/;

  # Post-processing some weird words
  if (length($w) == 7) {
    if ($w eq '醉翁之意不在酒' || $w =~ /又折兵$/) {
      print substr($w, 0, 4) . "\t$tag\n";
    }
  } elsif (length($w) == 8) {
    print substr($w, 0, 4) . "\t$tag\n";
    print substr($w, 4) . "\t$tag\n";
  }

  next if length($w) > 7;

  # Additional: number words
  if ($w =~ /^([一二三四五六七八九]{3})[^一二三四五六七八九十]/) {
    print "$1\t$tag\n";
  }

  # Additional: special words
  if ($w =~ /天安門/) {
    print "天安門\t$tag\n";
    print "六四\t$tag\n";
  }

  if ($w =~ /奧林匹克/) {
    print "奧林匹克\t$tag\n";
    print "奧林匹亞\t$tag\n";
  }

  if ($w =~ /奧斯卡/) {
    print "奧斯卡\t$tag\n";
  }

  # Translation conventions
  if ($w =~ /[巴柏]金/) {
    print "$w\t$tag\n";
    $w =~ s/[巴柏]金/帕金/;
    next if length($w) < 2;
  }

  # If end with something disease-related
  if ($w =~ /氏病$/) {
    print "$w\t$tag\n";
    $w =~ s/氏病/氏症/;
    next if length($w) < 2;
  }
  if ($w =~ /氏?[病症]$/) {
    print "$w\t$tag\n";
    $w =~ s/氏?[病症]$//;
    next if length($w) < 2;
  }

  print "$w\t$tag\n";
}
