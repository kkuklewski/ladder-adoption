#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/../_fixtures/lib.sh"
git_init
printf '{ "name": "nl", "scripts": { "start": "node index.js" } }\n' > package.json
git_commit_remote init nl
