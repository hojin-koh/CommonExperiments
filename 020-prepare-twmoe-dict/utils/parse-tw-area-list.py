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

# Parse Taiwan's major area names, from https://gist.github.com/vinta/079cb8d4da486f471365c31388ed1b85

import sys

def main():
    exec(sys.stdin.read(), globals())
    sNames = set()
    for p in tuple(area_data.keys())+tuple(p for ps in area_data.values() for p in ps):
        p = p.removesuffix('市').removesuffix('縣').removesuffix('區').removesuffix('鄉').removesuffix('鎮')
        if len(p) <= 1: continue
        sNames.add(p)
    for p in sorted(sNames):
        print(p)

    # Many custom old names
    for p in ("雞籠", "雞籠山", "打狗", "滬尾", "彭佳嶼", "八斗子", "八尺門", "社寮", "大稻埕", "大直", "中崙", "朱厝崙", "艋舺", "五分埔", "月眉", "銅鑼", "銅鑼灣", "笨港", "赤崁", "牡丹社", "多納", "瑪雅", "大湖", "凱達格蘭", "茄苳腳", "茄苳", "諸羅", "焦吧哖", "彌濃", "卑南", "媽宮"):
        print(p)

if __name__ == '__main__':
    main()
