import Xmobar
import Xmobar.MyMonitors
import Helpers

main :: IO ()
main = xmobar $ hostConfig myHostname
