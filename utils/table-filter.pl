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

# Perform table arithmetic based on an user expression from $ARGV[0]

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my $filt = $ARGV[0];
my $filtFile = $ARGV[1];

my %mFilter;
open(my $FP, "<", $filtFile) || die "Can't open $filtFile: $!";
while (<$FP>) {
    chomp;
    my ($key, $label) = split(/\t/, $_, 2);
    $mFilter{$key} = $label
}

while (<STDIN>) {
    chomp;
    my ($key, $value) = split(/\t/, $_, 2);
    my $F = $mFilter{$key};

    if (eval($filt)) {
      print "$key\t$value\n";
    }
}
