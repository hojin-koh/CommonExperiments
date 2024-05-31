#!/usr/bin/env python3
# -*- coding: utf-8 -*-
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

# Convert csv table from stdin to data feeding to chart.js, with first row/col being headers
# Opinionated: js indent at 2 spaces

import csv
import sys

def main():
    fp = csv.reader(sys.stdin)

    rowFirst = next(fp)
    rowFirst.pop(0)
    print("labels: [{}],".format(', '.join(F"'{t}'" for t in rowFirst)))
    print("datasets: [")
    for row in fp:
        print("  {")
        print("    label: '{}',".format(row[0]))
        print("    data: [{}],".format(', '.join(d for d in row[1:])))
        print("  },")
    print("],")

if __name__ == "__main__":
    main()

