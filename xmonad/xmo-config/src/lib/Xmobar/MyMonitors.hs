module Xmobar.MyMonitors where

import XMonad.CustomColors
import Xmobar
import Helpers

baseConfig :: CustomColors -> Int -> Config
baseConfig c fontsize =
  defaultConfig
    { font = "DejaVu Sans Bold " ++ show fontsize
    , additionalFonts =
        [ "DejaVu Sans Mono Bold " ++ show fontsize
        , "Symbola Bold " ++ show (fontsize + 1)
        , "DejaVuSansMono Nerd Font Bold " ++ show fontsize
        ]
    , iconRoot     = myHome ++ "/config/xmonad/icons"
    , bgColor      = xmbBg c
    , fgColor      = xmbFg c
    , alpha        = 220
    , border       = NoBorder
    , borderColor  = xmbBg c
    , position     = TopH 25
    , allDesktops  = False -- show on all desktops
    , pickBroadest = True
    , persistent   = False -- enable/disable hiding (True = disabled
    -- , lowerOnStart      = False   -- send to bottom of window stack on start
    -- , hideOnStart       = False   -- start with window unmapped (hidden)
    -- , overrideRedirect  = True    -- set the Override Redirect flag (Xlib)
    -- , sepChar           = "%"
    -- , alignSep          = "}{"
    }

sep :: String
sep = xmoSep

colArgs :: CustomColors -> [String]
colArgs c =
  ["--low", monitorLow c, "--normal", monitorNormal c, "--high", monitorHigh c]

colArgs' :: CustomColors -> [String]
colArgs' c =
  ["--low", monitorHigh c, "--normal", monitorNormal c, "--high", monitorLow c]

buildArgs :: [String] -> [String] -> CustomColors -> [String]
buildArgs args extra col = args ++ (colArgs col) ++ ["--"] ++ extra

buildArgs' :: [String] -> [String] -> CustomColors -> [String]
buildArgs' args extra col = args ++ (colArgs' col) ++ ["--"] ++ extra

commonNetOpts :: CustomColors -> [String]
commonNetOpts c =
  buildArgs
    [ "--template" , "<action=`nm-connection-editor`>Net: <fn=1><tx></fn>↑ <fn=1><rx></fn>↓kB/s</action>" ++ sep
    , "--Low" , "10240" -- units: B/s
    , "--High" , "55120" -- units: B/s
    , "--minwidth" , "5"
    , "--ddigits" , "0"
    , "--padchars" , " "
    , "--align" , "l"
    ]
    []
    c

myNetwork :: String -> CustomColors -> Int -> Monitors
myNetwork device c rate = Network device (commonNetOpts c) rate

myDynNetwork :: CustomColors -> Int -> Monitors
myDynNetwork c rate = DynNetwork (commonNetOpts c) rate

myCpu :: CustomColors -> Int -> Monitors
myCpu c rate =
  Cpu
    (buildArgs
       [ "--template" , "Cpu: <fn=1><total></fn>%"
       , "--Low" , "50" -- units: %
       , "--High" , "85" -- units: %
       , "--ppad" , "3"
       ]
       []
       c)
    rate

myCpuFreq :: CustomColors -> Int -> Int -> Int -> Monitors
myCpuFreq c low high rate =
  CpuFreq
    (buildArgs
       [ "-t" , "<fn=1><cpu0>GHz</fn>"
       , "-d" , "2"
       , "-L" , show low
       , "-H" , show high
       , "-w" , "4"
       ]
       []
       c)
    rate

myAmdTemp :: CustomColors -> Int -> Monitors
myAmdTemp c rate =
  K10Temp
    "0000:00:18.3"
    (buildArgs
       [ "-t" , "<fn=1><Tdie></fn>°C"
       , "--Low" , "50" -- units: C
       , "--High" , "60" -- units: C
       ]
       []
       c)
    rate

myIntelTemp :: CustomColors -> Int -> Int -> Monitors
myIntelTemp c zone rate =
  ThermalZone
    zone
    (buildArgs
       [ "--template" , "<fn=1><temp></fn>°C"
       , "--Low" , "50" -- units: C
       , "--High" , "60" -- units: C
       ]
       []
       c)
    rate

myMem :: CustomColors -> Int -> Monitors
myMem c rate =
  Memory
    (buildArgs
       [ "--template" , "Mem: <fn=1><usedratio></fn>%"
       , "--Low" , "20" -- units: %
       , "--High" , "70" -- units: %
       , "--ppad" , "2"
       ]
       []
       c)
    rate

--   (%F = y-m-d date, %a = day of week, %T = h:m:s time)
myDate :: Date
myDate = Date "%d.%m. (%a, W%V) %T" "date" 10

myMPD :: Monitors
myMPD =
  MPD
    [ "-t"
    , "<action=`xdotool key super+shift+control+n`><artist> [<date> - <album>] <track> - <title></action> <action=`mpc toggle`><statei> <ipat></action>"
    --, "--bback" , "□"
    --, "--bfore" , "■" -- ▣
    , "--"
    , "--lapsed-icon-pattern", "<icon=prog%%.xpm/>"
    , "-P" , "<icon=play.xpm/>"
    , "-S" , "<icon=stop.xpm/>"
    , "-Z" , "<icon=pause.xpm/>"
    ]
    50


-- 📁 📂 🗀

myDiskU :: CustomColors -> Monitors
myDiskU c = DiskU [("/", "<fn=1>📂</fn> <fn=1><free></fn> <fn=1><usedp></fn>%")]
                  (buildArgs
                  [ "-f", "⚪◔◑◕●" -- TODO use icons?
                  , "-W", "0"
                  ]
                  []
                  c)
                  1000

myDiskIO :: CustomColors -> Monitors
myDiskIO c = DiskIO [("/", "<fn=1><read></fn>↑ <fn=1><write></fn>↓")]
                (buildArgs
                  [ "--Low" ,  (show $ 1024 * 1024 * 1) -- units: B/s
                  , "--High" , (show $ 1024 * 1024 * 20) -- units: B/s
                  , "--minwidth" , "5"
                  , "--ddigits" , "0"
                  , "--padchars" , " "
                  , "--align" , "l"
                  ]
                  []
                  c)
                  100

commonBatSettings :: CustomColors -> String -> [String]
commonBatSettings c template =
  buildArgs'
    [ "--template" , template
    , "--Low" , "15" -- units: %
    , "--High" , "60" -- units: %
    ]
    [ "-o" , "<fn=1><left></fn>% (<fn=1><timeleft></fn>)" -- discharge status
    -- AC "on" status
    , "-O" , "<fn=1><left></fn>% (<fn=2>🔌</fn> <fn=1><timeleft></fn>)"
    -- charged status
    , "-i" , "<fn=1><left></fn>%"
    ]
    c

myBat1 :: CustomColors -> String -> Monitors
myBat1 c dev =
  BatteryN [dev] (commonBatSettings c "Bat: <acstatus>") 300 "bat1"

myBat2 :: CustomColors -> String -> Monitors
myBat2 c dev = BatteryN [dev] (commonBatSettings c ", <acstatus>") 300 "bat2"

-- technically Alsa is the nicer option, but it doesn't seem to handle device switches nicely
myPulse :: CustomColors -> Int -> Monitors
myPulse c rate =
  Volume
    "pulse"
    "Master"
    [ "-t" , "<status><fn=1><volume></fn>%"
    , "--ppad" , "3"
    , "--"
    , "--on" , "<fn=2>🔊</fn>"
    , "--off" , "<fn=2>🔇</fn>"
    , "--onc" , monitorLow c
    , "--offc" , monitorHigh c
    ]
    rate

myIntelBl :: Int -> Monitors
myIntelBl rate =
  Brightness
    ["--template", " <fn=1><percent></fn>%", "--", "-D", "intel_backlight"]
    rate

myAMDBl :: Int -> Monitors
myAMDBl rate =
  Brightness
    ["--template", " <fn=1><percent></fn>%", "--", "-D", "amdgpu_bl0"]
    rate

volPart :: String
volPart = "<action=`xdotool key XF86AudioMute`>%pulse:Master%</action>"

presPart :: String
presPart = "<action=`" ++ togglePresModeCmd ++ "`><fn=3>%pmode%</fn></action>"

cpuPart :: String -> String
cpuPart temptag = "<action=`xdotool key super+shift+t`>%cpu% %cpufreq% %" ++
  temptag ++
  "%</action>" ++ sep ++ "%memory%"

templateTail :: String -> String -> String
templateTail nwtag temptag =
  "%" ++
  nwtag ++
  "%" ++
  cpuPart temptag ++ sep ++ "%disku% %diskio%" ++ sep ++ volPart ++ sep ++ gammaStep ++ sep ++ presPart ++ sep ++ "%date%" ++ sep ++ "%_XMONAD_PAD%"

commonMonitors rate cpulow cpuhigh =
  [ Run XMonadLog
  , Run $ myCpu gruvboxish rate
                      -- memory usage monitor
  , Run $ myMem gruvboxish rate
                      -- time and date indicator
  , Run myDate
  , Run $ myCpuFreq gruvboxish cpulow cpuhigh rate
  , Run $ myPulse gruvboxish 50
  , Run $ myDiskU gruvboxish
  , Run $ myDiskIO gruvboxish
  , Run $ Com (myHome ++ "/config/scripts/pres_mode") [] "pmode" 100
  , Run $ XPropertyLog "_XMONAD_PAD"
  , Run $ PipeReader "?:${HOME}/.local/state/gammastep" "gammastep"
  ]

ikarusTemplate = "%XMonadLog% }{ %mpd%" ++ sep ++ templateTail "enp5s0" "k10temp"

ikarusMonitors =
  commonMonitors 20 3 4 ++
  [ Run myMPD
  , Run $ myNetwork "enp5s0" gruvboxish 20
                 -- CPU temp ryzen
  , Run $ myAmdTemp gruvboxish 20
  ]

ninesTemplate = "%XMonadLog% }{ %dynnetwork%<action=`xfce4-power-manager-settings`>%bat1%</action>" ++ sep ++ cpuPart "thermal0" ++ sep ++ "%disku% %diskio%" ++ sep ++ volPart ++ sep ++ presBright ++ sep ++ "%date%" ++ sep ++ "%_XMONAD_PAD%"
ninesMonitors =
  commonMonitors 100 2 3 ++
  [ Run $ myDynNetwork gruvboxish 30
  , Run $ myIntelTemp gruvboxish 0 50
  , Run $ myBat1 gruvboxish "BAT0"
  , Run $ myAMDBl 50
  ]

togglePresModeCmd :: String
togglePresModeCmd = "xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -T"

gammaStep :: String
gammaStep = "<action=`pkill -USR1 '^gammastep$'`><fn=3>%gammastep%</fn></action>"

presBright :: String
presBright = gammaStep ++ sep ++ "<action=`" ++ togglePresModeCmd ++ "`><fn=3>%pmode%</fn>%bright%</action>"

vaioTemplate =
  " %XMonadLog% }{ %dynnetwork%%bat1%%bat2%" ++ sep ++ cpuPart "thermal0" ++ sep ++ volPart ++ sep ++ presBright ++ sep ++ "%date% %_XMONAD_PAD%"

vaioMonitors =
  commonMonitors 100 1 3 ++
  [ Run $ myDynNetwork gruvboxish 100
  , Run $ myIntelTemp gruvboxish 0 100
  , Run $ myBat1 gruvboxish "BAT0"
  , Run $ myBat2 gruvboxish "BAT1"
  , Run $ myIntelBl 30
  ]

-- Note: font size is affected by DPI setting and will grow the bar

hostConfig :: String -> CustomColors -> Config
hostConfig "ikarus" c =
  (baseConfig gruvboxish 11)
    { template = ikarusTemplate
    , commands = ikarusMonitors
    }
hostConfig "nines" c =
  (baseConfig gruvboxish 17)
    { template = ninesTemplate
    , commands = ninesMonitors
    }
hostConfig "vaio" c =
  (baseConfig gruvboxish 9)
    { template = vaioTemplate
    , commands = vaioMonitors
    }
