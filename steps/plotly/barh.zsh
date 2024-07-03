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
description="Generate plotly.js horizontal barcharts"
dependencies=()
importantconfig=(tag reg)

setupArgs() {
  opt -r out '' "Output js file"
  optType out output report
  opt -r in '()' "Input tables"
  optType in input table

  opt tag '(main)' "Tags for grouping"
  opt reg '(.*)' "Regular expression to extract tag (in group 1) for the plot"
}

main() {
  computeMIMOStride in tag

  local params=()
  local i
  for (( i=1; i<=$#in; i++ )); do
    computeMIMOIndex $i in tag

    if [[ $INDEX_tag -gt $#params ]]; then
      params[$INDEX_tag]=""
    fi
    params[$INDEX_tag]+="$(in::getLoader $i) ; "
  done

  for (( i=1; i<=$#tag; i++ )); do
    printf "{\n  type: 'bar',\n  orientation: 'h',\n  name: '%s',\n" "${tag[$i]}"
    printf "  y: ["
      eval "${params[$i]}" | tac | perl -CSAD -ane '$F[0] =~ s/'"$reg"'/$1/; print "\"$F[0]\", "'
    printf "],\n"
    printf "  x: ["
      eval "${params[$i]}" | tac | perl -CSAD -ane 'print "$F[1], "'
    printf "],\n"
    printf "  error_x: {\n    symmetric: false,\n"
      printf "    arrayminus: ["
        eval "${params[$i]}" | tac | perl -CSAD -ane 'print "".($F[1]-$F[2]).", "'
      printf "],\n"
      printf "    array: ["
        eval "${params[$i]}" | tac | perl -CSAD -ane 'print "".($F[3]-$F[1]).", "'
      printf "],\n"
    printf "  },\n"

    if [[ $#tag -le 1 ]]; then
      printf "  marker: {\n"
      printf "    color: ['#17becf', '#bcbd22', '#7f7f7f', '#e377c2', '#8c564b', '#9467bd', '#d62728', '#2ca02c', '#ff7f0e', '#1f77b4'],\n"
      printf "  },\n"
    fi
    printf "},\n"
  done \
  | tee /dev/stderr | out::save

  if [[ $? != 0 ]]; then return 1; fi
}

source Mordio/mordio
