#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2023 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
set -e
set -o pipefail

start=$(date +%s)

jobs=${TARGET}/jobs/clone-jobs.txt
rm -rf "${jobs}"
mkdir -p "$(dirname "${jobs}")"
touch "${jobs}"

total=$(wc -l < "${TARGET}/repositories.csv" | xargs)

declare -i repo=0
while IFS=',' read -r r tag; do
    repo=$((repo+1))
    if [ -z "${tag}" ]; then tag='.'; fi
    if [ -e "${TARGET}/github/${r}" ]; then
        echo "${r}: Git repo is already here"
    else
        echo "$(dirname "$0")/clone-repo.sh" "${r}" "${tag}" "${repo}" "${total}" >> "${jobs}"
    fi
done < "${TARGET}/repositories.csv"

uniq "${jobs}" | xargs -I {} -P "$(echo "$(nproc) * 8" | bc)" "${SHELL}" -c "{}"
wait

echo "Cloned ${total} repositories in $(nproc) threads in $(echo "$(date +%s) - ${start}" | bc)s"
