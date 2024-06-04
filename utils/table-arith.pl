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

my $arith = $ARGV[0];
while (<STDIN>) {
    chomp;
    my @F = split(/\t/);
    my $key = $F[0];
    my $rslt = eval($arith);

    print "$key\t$rslt\n";
}
