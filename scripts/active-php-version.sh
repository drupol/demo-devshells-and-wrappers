#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash cacert curl jq cowsay
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/ace24a96b5c7932a4955b151aa8b37e4cb154496.tar.gz

curl -L -s https://www.php.net/releases/active.php \
  | jq -r '[.[][] | .version] | last' \
  | cowsay
