#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o verbose

/usr/local/go/bin/go version
/usr/bin/dropbox status
/usr/bin/firefox --version
/usr/bin/google-chrome --version
/usr/bin/keybase --version
