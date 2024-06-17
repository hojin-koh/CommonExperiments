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

# Use atan to limit a feature inside the range of [0,1]

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

use constant PI => 4 * atan2(1, 1);
my $k = $ARGV[0];
my $fix = 0;
if ($k < 0) {
  $fix = 1;
  $k = -$k;
}

while (<STDIN>) {
    chomp;
    my ($key, $values) = split(/\t/, $_, 2);
    my @aOutput = map { $fix + 2*atan2($_, $k)/PI } split(/\s+/, $values);
    print "$key\t" . join("\t", @aOutput) . "\n";
}
