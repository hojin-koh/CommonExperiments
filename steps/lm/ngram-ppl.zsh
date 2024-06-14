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
description="Compute perplexity score on LMs"

setupArgs() {
  opt -r in '' "Input evaluation text"
  optType in input text
  opt -r out '' "Output perplexity table"
  optType out output table

  opt -r lm '()' "Input LMs"
  optType lm input arpa

  opt order 3 "n-gram order"
}

main() {
  local dirTemp
  putTemp dirTemp

  # Extract all sub-files into temp dir
  in::load \
    | gawk -vdirOut="$dirTemp" -F$'\t' '{fOut = dirOut "/" $1; print $2 > (fOut); close(fOut)}'
  local listFile
  listFile="$(find "$dirTemp" -type f | gawk '{printf("%s,", $0);}' | sed -r 's/,$//')"

  local i
  local fd
  local fds=()
  local paramPaste
  for (( i=1; i<="${#lm[@]}"; i++ )); do
    info "Evaluating ${lm[$i]} ..."
    evaluate-ngram -verbose 0 -o $order -lm =(lm::load $i) -ep "$listFile" 2>&1 \
    | tail -n +2 \
    | cut -d$'\t' -f3- \
    | sed -r "s@^$dirTemp/@@" \
    > "$dirTemp/perp-$i"

    if [[ "$i" == "1" ]]; then
      paramPaste="$dirTemp/perp-$i"
    else
      exec {fd}< <(cut -d$'\t' -f2- <"$dirTemp/perp-$i")
      paramPaste+=" /dev/fd/$fd"
      fds+=( $fd )
    fi
  done

  paste -d$'\t' "${(z)paramPaste}" \
  | out::save
  local rslt=$?

  for fd in "${fds[@]}"; do
    exec {fd}<&-
  done

  return $rslt
}

source Mordio/mordio
