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

# Parse world's country names, from https://zh.wikipedia.org/zh-tw/%E4%B8%96%E7%95%8C%E6%94%BF%E5%8D%80%E7%B4%A2%E5%BC%95

import re
import sys

from bs4 import BeautifulSoup

def main():
    objSoup = BeautifulSoup(sys.stdin.read(), 'html.parser')
    sNames = set()
    for div in objSoup.find_all('div'):
        if any(cls.startswith('NavFrame') for cls in div.get('class', [])):
            div.extract()

    for table in objSoup.find_all('table'):
        if table.get('id') == 'toc': continue
        if 'metadata' in table.get('class', []): continue
        if any(cls.startswith('navbox') for cls in table.get('class', [])): continue
        if any(cls.startswith('infobox') for cls in table.get('class', [])): continue

        for row in table.find_all('tr'):
            aCells = row.find_all('td')
            if len(aCells) < 2: continue
            for i in (0, 1):
                p = aCells[i].get_text(strip=True)
                p = re.sub(R'\[.*|（.*|\(.*', '', p)
                p = p.removesuffix('市').removesuffix('縣').removesuffix('特區').removesuffix('區')
                if len(p) > 1 and len(p) < 10 and not re.search(R'[A-Za-z0-9]', p):
                    sNames.add(p)
    for p in sorted(sNames):
        print(p)

if __name__ == '__main__':
    main()
