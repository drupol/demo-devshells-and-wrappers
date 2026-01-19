#!/usr/bin/env bash

curl -L -s https://www.php.net/releases/active.php \
  | jq -r '[.[][] | .version] | last' \
  | cowsay
