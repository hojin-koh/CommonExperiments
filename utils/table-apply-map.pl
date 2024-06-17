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

# Apply a mapping to a table

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use List::Util qw(reduce any all none notall first reductions max maxstr min minstr product sum sum0);

my $merger = $ARGV[0];
my $inputFile = $ARGV[1];

my %mValue;
open(my $FP, "<", $inputFile) || die "Can't open $inputFile: $!";
while (<$FP>) {
    chomp;
    my ($key, $value) = split(/\t/, $_, 2);
    $mValue{$key} = $value;
}
close($FP);

while (<STDIN>) {
    chomp;
    my ($key, $targets) = split(/\t/, $_, 2);
    my @F = map { $mValue{$_} } split(/\s+/, $targets);
    my $rslt = eval($merger);

    print "$key\t$rslt\n";
}
