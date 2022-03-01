import Xmobar
import Xmobar.MyMonitors
import XMonad.CustomColors
import Helpers

main :: IO ()
main = xmobar $ hostConfig myHostname gruvboxish
