#!/bin/bash

# Get commandline arguments to pass to executable
args="$@"

# Exit on error
set -e

# cd into script directory
cd "$(dirname "$(readlink -f "$0")")"

echo '===== BUILD ====='
jai build.jai
echo '====== RUN ======'
./bin/at-notes $args
echo '================='
