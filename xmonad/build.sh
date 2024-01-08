#!/bin/sh

set -e

cd ~/.xmonad || exit 1
./configure_hostname.sh
stack -j12 build && stack install xmonad xmo-config || (xmessage -default okay "Dependency compilation failed!" && exit 1)
stack --stack-yaml stack.yaml ghc -- -Wwarn=unused-imports --make xmonad.hs -threaded -fforce-recomp -main-is main -v0 -o xmonad-x86_64-linux || (xmessage -default okay "Compilation failed!" && exit 1)
