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

# Parse China's major area names, from https://github.com/small-dream/China_Province_City

import json
import re
import sys

from opencc import OpenCC
objOpenCC = OpenCC('s2tw.json')

def putName(setStore, name):
    p = objOpenCC.convert(name)
    if p.endswith('地區'): return
    if re.search(R'族.*族', p): return
    p = re.sub(R'(.族|蒙古|維吾爾)?(特別|自治).*', '', p)
    p = p.removesuffix('市').removesuffix('縣').removesuffix('省').removesuffix('區').removesuffix('鄉').removesuffix('鎮')
    if p == '臺灣': return
    if len(p) > 1:
        setStore.add(p)

def main():
    data = json.loads(sys.stdin.read())
    sNames = set()
    for mState in data:
        putName(sNames, mState['name'])
        if 'cityList' not in mState: continue
        for mCity in mState['cityList']:
            putName(sNames, mCity['name'])

    for p in sorted(sNames):
        print(p)

    # Many custom old names
    for p in ("匈奴", "突厥", "朝鮮", "契丹", "夷狄", "百越", "南蠻", "西戎", "群貊", "鮮卑", "烏桓", "吐蕃", "可汗", "回紇", "沙陀", "擺夷", "女真", "党項", "東胡", "西夏"):
        print(p)


if __name__ == '__main__':
    main()
