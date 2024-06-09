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

import re
import sys

def processDocument(ver, idArticle, text):
    print('zhwiki-{}-A{:08d}.txt\t{}'.format(ver, idArticle, text))

def main():
    ver = sys.argv[1]
    aLines = []
    idThis = None
    nArticle = 0
    for line in sys.stdin:
        line = line.strip()
        if len(line) < 2: continue
        if line.startswith("<doc "):
            match = re.match(R'<doc id="([^"]+)"', line)
            idThis = int(match.group(1))
            continue
        if line.startswith("</doc>"):
            if len(aLines) > 1 and idThis is not None:
                processDocument(ver, idThis, "\\n".join(aLines))
                nArticle += 1
            idThis = None
            aLines = []
            continue

        # If we're indeed inside a document
        if idThis is not None:
            aLines.append(line)
    print("Imported {:d} articles from zh-wiki".format(nArticle), file=sys.stderr)

if __name__ == '__main__':
    main()
