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
description="Import Taiwan area list from https://gist.github.com/vinta/079cb8d4da486f471365c31388ed1b85"

setupArgs() {
  opt -r in '' "Original python file"
  opt -r out '' "Output table"
  optType out output table
}

main() {
  if [[ ! -f "$in" ]]; then
    info "Downloading the data from github.com ..."
    curl -L -o "$in" 'https://gist.githubusercontent.com/vinta/079cb8d4da486f471365c31388ed1b85/raw/c8dc91acc476aea98f5a6f1db59df966e4e3d4c1/%25E5%258F%25B0%25E7%2581%25A3%25E5%2590%2584%25E8%25A1%258C%25E6%2594%25BF%25E5%258D%2580%25E5%2588%2597%25E8%25A1%25A8.py'
  fi

  us/parse-tw-area-list.py < "$in" \
  | out::save
  return $?
}

source Mordio/mordio
