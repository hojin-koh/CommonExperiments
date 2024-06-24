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

# Reverse the mapping relationships in a table
# doc1 -> cls1 cls2
# doc2 -> cls2
# Will become
# cls1 -> doc1 doc2
# cls2 -> doc1

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my %mValue;

# Read the input
while (<STDIN>) {
  chomp;
  my ($key, $value) = split(/\t/, $_, 2);
  my @aValues = split(/\s+/, $value);

  # Store document names under their corresponding value
  for my $v (@aValues) {
    push @{$mValue{$v}}, $key; 
  }
}

# Output the transposed data
for my $value (sort keys %mValue) {
  print "$value\t@{$mValue{$value}}\n";
}
