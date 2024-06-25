#!/usr/bin/env zsh
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
description="Import zh wikipedia dump data"
dependencies=( "us/parse-zhwiki.py" )

setupArgs() {
  opt -r out '' "Output text"
  optType out output text

  opt -r in '' "Original Data Archive"
  opt -r ver '' "Version of wiki data with syntax YYYYMMDD"
}

main() {
  # May need to manually apply patch from https://github.com/attardi/wikiextractor/pull/313/commits/ab8988ebfa9e4557411f3d4c0f4ccda139e18875 for python > 3.10
  if [[ -n "${VIRTUAL_ENV-}" ]]; then
    if ! wikiextractor --version >/dev/null 2>&1; then
      info "Applying patch to wikiextractor ..."
      local dirTempPatch
      putTemp dirTempPatch
      curl -L -o "$dirTempPatch/wikiextractor.patch" https://github.com/attardi/wikiextractor/commit/ab8988ebfa9e4557411f3d4c0f4ccda139e18875.patch
      local pathPatchAbs="$(readlink -f "$dirTempPatch/wikiextractor.patch")"
      ( cd $VIRTUAL_ENV/lib/python*/site-packages; patch -Np1 -i "$pathPatchAbs" )
    fi
  fi

  if [[ ! -f "$in" ]]; then
    info "Downloading the data from wikipedia ..."
    curl -L -o "$in" "https://dumps.wikimedia.org/zhwiki/$ver/zhwiki-$ver-pages-articles.xml.bz2"
  elif [[ $(stat -c'%s' "$in") -lt 2900000000 ]]; then
    info "Downloading the data from wikipedia (continue) ..."
    curl -L -o "$in" -C - "https://dumps.wikimedia.org/zhwiki/$ver/zhwiki-$ver-pages-articles.xml.bz2"
  fi

  if ! out::isReal; then
    err "Unreal text output not supported" 15
  fi

  local dirTemp
  putTemp dirTemp
  wikiextractor --no-templates --processes $nj -o "$dirTemp" "$in"

  info "Converting wikipedia extract into text ..."
  local outAbs="${out:A}"
  (cd "$dirTemp"; cat **/wiki_*) \
  | us/parse-zhwiki.py "$ver" \
  | out::save
}

source Mordio/mordio
