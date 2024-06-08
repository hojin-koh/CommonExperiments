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
import unicodedata

from bs4 import BeautifulSoup

def main():
    limit = int(sys.argv[1])
    reFirstRow = re.compile(sys.argv[2])
    aFields = tuple((int(i) for i in sys.argv[3:]))
    objSoup = BeautifulSoup(sys.stdin.read(), 'html.parser')
    for div in objSoup.find_all('div'):
        if any(cls.startswith('NavFrame') for cls in div.get('class', [])):
            div.extract()

    sNames = set()
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

        if not reFirstRow.search(table.get_text(strip=True)): continue

        for row in table.find_all('tr'):
            aCells = row.find_all('td')
            for i in aFields:
                if limit > 0 and len(sNames) >= limit: break

                if i > len(aCells)-1: continue
                p = aCells[i].get_text(strip=True)
                p = re.sub(R"\[.*|（.*|\(.*|-.*|－.*|：.*|:.*|，.*|、.*", "", p)
                if re.search("特別|廣域", p): continue
                p = p.removesuffix("市").removesuffix("縣").removesuffix("特區").removesuffix("區").removesuffix("鄉").removesuffix("鎮")

                # Special treatment for people's name
                if p.find('·') != -1:
                    for subp in p.split('·'):
                        subp = "".join(c for c in subp if not unicodedata.category(c).startswith('P'))
                        if len(subp) > 1 and len(subp) < 9 and not re.search(R"[A-Za-z0-9]", subp):
                            sNames.add(subp)
                    continue

                # Delete punctuations
                p = "".join(c for c in p if not unicodedata.category(c).startswith('P'))
                if len(p) > 1 and len(p) < 9 and not re.search(R"[A-Za-z0-9]", p):
                    sNames.add(p)

    for p in sorted(sNames):
        print(p)

if __name__ == '__main__':
    main()
