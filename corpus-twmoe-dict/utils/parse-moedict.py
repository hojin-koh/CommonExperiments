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

# Parse idioms from moedict

import re
import sys
import unicodedata

from bs4 import BeautifulSoup

def main():
    mode = sys.argv[1]
    maxChar = int(sys.argv[2])

    objSoup = BeautifulSoup(sys.stdin.read(), 'html.parser')
    div = objSoup.find_all('div', id='result')[0]
    for link in div.find_all('a'):
        w = link.get_text(strip=True)
        w = "".join(c for c in w if not unicodedata.category(c).startswith("P"))
        if not w or len(w) < 2 or len(w) > maxChar: continue

        if re.search("兒", w): continue

        # Post-processing some weird words
        if mode == "idioms":
            if len(w) == 8:
                print(w[:4])
                print(w[4:])
            if len(w) == 10:
                print(w[:5])
                print(w[5:])

        print(w)

if __name__ == '__main__':
    main()
