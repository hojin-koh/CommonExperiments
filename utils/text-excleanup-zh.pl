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

# Extreme cleanup of the mainly-Chinese segmented text, getting rid of English and Math

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my $arith = $ARGV[0];
while (<STDIN>) {
    chomp;
    my ($key, $text) = split(/\t/, $_, 2);
    my @aWords = split(/\s+/, $text);

    for (@aWords) {
      if (/^[-\/a-zA-Z.'",!?()]*[a-zA-Z]+[-\/a-zA-Z.'",!?()]*$/) {
        $_ = "<eng>";
      } elsif (/^[-0-9lxo.^_+eE~]*[0-9]+[-0-9lxo.^_+eE~]*$/) {
        $_ = "<num>";
      } elsif (/^[^\p{CJK}\p{Bopomofo}\p{Hiragana}\p{Katakana}]+$/) {
        $_ = "<sym>";
      }
    }
    $text = join(' ', @aWords);
    $text =~ s/<([^>]+)>( <\1>)+/<$1>/g;

    print "$key\t$text\n";
}
