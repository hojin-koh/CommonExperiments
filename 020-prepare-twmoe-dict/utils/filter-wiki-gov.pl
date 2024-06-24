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

# Filter geography proper nouns from wikipedia

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

sub doOutput {
  my ($w, $tag) = @_;

  print "$w\t$tag\n";
  $w =~ s/里/裡/g;
  print "$w\t$tag\n";
}

while (<STDIN>) {
  chomp;
  my ($w, $tag) = split(/\t/, $_, 2);

  # Blacklist
  next if $w =~ /特別|廣域/;
  next if $w =~ /\p{Hiragana}|\p{Katakana}/;

  # Remove content within brackets and after certain characters
  $w =~ s/\[.*|\（.*|\(.*|-.*|－.*|：.*|:.*|，.*|、.*//g;

  # Remove suffixes
  $w =~ s/(市|縣|特區|區|鄉|鎮|府)$//g;

  # Special treatment for people's names
  if (index($w, '·') != -1) {
    for my $subp (split /·/, $w) {
      $subp =~ s/\p{P}//g;
      next if length($subp) < 2 || length($subp) > 9 || $subp =~ /[A-Za-z0-9]/;
      doOutput($subp, $tag);
    }
    next;
  }

  # Remove punctuation
  $w =~ s/\p{P}//g;

  next if length($w) < 2 || length($w) > 9 || $w =~ /[A-Za-z0-9]/;

  # If begin with a country name
  if ($w =~ /^[美韓英法德]國|印度/) {
    doOutput($w, $tag);
    $w =~ s/^[美韓英法德]國|印度//;
    next if length($w) < 2;
  }

  # If end with something company
  if ($w =~ /(控股|工業|科技|國際|保險|金融)*(股份有限公司|有限公司|公司|集團|株式會社)?$/) {
    doOutput($w, $tag);
    $w =~ s/(控股|工業|科技|國際|保險|金融)*(股份有限公司|有限公司|公司|集團|株式會社)?$//;
    next if length($w) < 2;
  }

  doOutput($w, $tag);
}
