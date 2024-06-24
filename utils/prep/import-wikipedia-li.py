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

# Parse word lists from wikipedia table

import re
import sys

from bs4 import BeautifulSoup

def main():
    limit = int(sys.argv[1])
    reMatch = re.compile(sys.argv[2])
    objSoup = BeautifulSoup(sys.stdin.read(), 'html.parser')
    for div in objSoup.find_all('div'):
        if any(cls.startswith('NavFrame') for cls in div.get('class', [])):
            div.extract()

    for table in objSoup.find_all('table'):
        if table.get('id') == 'toc':
            table.extract()
            continue
        if 'metadata' in table.get('class', []):
            table.extract()
            continue
        if any(cls.startswith('navbox') for cls in table.get('class', [])):
            table.extract()
            continue
        if any(cls.startswith('infobox') for cls in table.get('class', [])):
            table.extract()
            continue

    sNames = set()
    for tag in (t for tagname in ('li', 'dt') for t in objSoup.find_all(tagname)):
        if limit > 0 and len(sNames) >= limit: break

        p = tag.get_text(strip=True)
        if len(p) < 1: continue
        if not reMatch.match(p): continue

        sNames.add(p)

    for p in sorted(sNames):
        print(p)

if __name__ == '__main__':
    main()
