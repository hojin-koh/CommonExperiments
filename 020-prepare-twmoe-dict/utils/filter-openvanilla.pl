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

# Filter openvanilla wordlist

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
  next if $w =~ /[一二三四五六七八九十零黨了呢嗎嘛們人的是於最很較]|戰爭|革命|中央|中國|團|大會|..時代/;
  next if $w =~ /^(不|小)/;
  next if length($w) >= 3 && $w =~ /(市|縣|省|區|鄉|鎮)$/;

  print "$w\t$tag\n";
}
