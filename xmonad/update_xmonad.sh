for p in xmonad xmonad-contrib xmobar; do echo ${p}; git -C ${p} pull; done
