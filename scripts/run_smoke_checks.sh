#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

run_test() {
  local dir="$1"
  echo "==> $dir"
  (cd "$dir" && flutter test test/smoke_test.dart)
}

run_test "$ROOT/packages/globe_poc_core"
run_test "$ROOT/apps/candidate_a_three_js"
run_test "$ROOT/apps/candidate_b_three_dart"
run_test "$ROOT/apps/candidate_c_low_level"
