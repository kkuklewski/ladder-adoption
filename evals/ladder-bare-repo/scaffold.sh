#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/../_fixtures/lib.sh"
git_init
printf '{ "name": "bare", "scripts": { "start": "node index.js" } }\n' > package.json
echo 'console.log(1)' > index.js
git_commit_remote init bare
