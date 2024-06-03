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

# Parse world's capital names, from https://zh.wikipedia.org/zh-tw/%E5%90%84%E5%9B%BD%E9%A6%96%E9%83%BD%E5%88%97%E8%A1%A8

import re
import sys

from bs4 import BeautifulSoup

def main():
    objSoup = BeautifulSoup(sys.stdin.read(), 'html.parser')
    sNames = set()
    for table in objSoup.find_all('table'):
        if table.get('id') == 'toc': continue
        if 'metadata' in table.get('class', []): continue
        if any(cls.startswith('navbox') for cls in table.get('class', [])): continue

        for row in table.find_all('tr'):
            for td in row.find_all('td'):
                tagB = td.find('b')
                if not tagB: continue
                tagA = tagB.find('a')
                if not tagA: continue
                p = tagA.get_text(strip=True)

                p = re.sub(R'\[.*|（.*|\(.*', '', p)
                p = p.removesuffix('市').removesuffix('縣').removesuffix('特區').removesuffix('區')

                if p == "NA": continue

                if len(p) > 1:
                    sNames.add(p)

    for p in sorted(sNames):
        print(p)

if __name__ == '__main__':
    main()
