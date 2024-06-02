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
description="Import twmoe variants table from https://github.com/kcwu/moedict-variants"
# Backup: https://web.archive.org/web/20240602054933/https://raw.githubusercontent.com/kcwu/moedict-variants/master/list.txt

setupArgs() {
  opt -r in '' "Original Data File"
  opt -r confusable '' "ICU's confusable table"
  opt -r infreq '' "Input character frequency table"
  optType infreq input table
  opt -r out '' "Output table"
  optType out output table
}

main() {
  if [[ ! -f "$in" ]]; then
    info "Downloading the variants data from github.com ..."
    curl -L -o "$in" 'https://raw.githubusercontent.com/kcwu/moedict-variants/master/list.txt'
  fi

  if [[ ! -f "$confusable" ]]; then
    info "Downloading the ICU confusable data 2024-04-12 from github.com ..."
    curl -L -o "$confusable" 'https://raw.githubusercontent.com/unicode-org/icu/ba1ecef7de5b4bbaa35e7dc56f8f36ddd6dff2bb/icu4c/source/data/unidata/confusables.txt'
  fi

  us/parse-variants-confusables.py "$confusable" <(infreq::load) < "$in" \
  | out::save
  return $?
}

source Mordio/mordio
