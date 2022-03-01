module Xmobar.MyMonitors where

import XMonad.CustomColors
import Xmobar
import Helpers

baseConfig :: CustomColors -> Int -> Config
baseConfig c fontsize =
  defaultConfig
    { font = "xft:DejaVu Sans:size=" ++ show fontsize ++ ":bold:antialias=true"
    , additionalFonts =
        [ "xft:DejaVu Sans Mono:size=" ++
          show fontsize ++ ":bold:antialias=true"
        , "xft:Symbola-" ++ show (fontsize + 1) ++ ":bold:antialias=true"
        ]
    , iconRoot = myHome ++ "/config/xmonad/icons"
    , bgColor = xmbBg c
    , fgColor = xmbFg c
    , alpha = 220
    , border = BottomB
    , borderColor = xmbBg c
    , position = OnScreen 0 $ TopH 25
    , allDesktops = False -- show on all desktops
    , persistent = True -- enable/disable hiding (True = disabled
                                      --, lowerOnStart      = False   -- send to bottom of window stack on start
                                      --, hideOnStart       = False   -- start with window unmapped (hidden)
                                      --, overrideRedirect  = True    -- set the Override Redirect flag (Xlib)
                                      --, sepChar           = "%"
                                      --, alignSep          = "}{"
    }

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
    [ "--template" , "Net: <fn=1><tx></fn>↑ <fn=1><rx></fn>↓kB/s"
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
myDate = Date "%y-%m-%d (%a, W%V) %T" "date" 10

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
    10

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
presPart = "<action=`" ++ togglePresModeCmd ++ "`><fn=2>%pmode%</fn></action>"
cpuPart :: String -> String
cpuPart temptag = "<action=`xdotool key super+shift+t`>%cpu% %cpufreq% %" ++
  temptag ++
  "%</action> | %memory%"

templateTail :: String -> String -> String
templateTail nwtag temptag =
  "%" ++
  nwtag ++
  "%" ++
  " | " ++ cpuPart temptag ++ " | " ++ volPart ++ " | " ++ presPart ++ " | %date% %_XMONAD_PAD%"

commonMonitors rate cpulow cpuhigh =
  [ Run StdinReader
  , Run $ myCpu gruvboxish rate
                      -- memory usage monitor
  , Run $ myMem gruvboxish rate
                      -- time and date indicator
  , Run myDate
  , Run $ myCpuFreq gruvboxish cpulow cpuhigh rate
  , Run $ myPulse gruvboxish 50
  , Run $ Com (myHome ++ "/config/scripts/pres_mode") [] "pmode" 100
  , Run $ XPropertyLog "_XMONAD_PAD"
  ]

ikarusTemplate = "%StdinReader% }{ %mpd% | " ++ templateTail "enp5s0" "k10temp"

ikarusMonitors =
  commonMonitors 10 3 4 ++
  [ Run myMPD
  , Run $ myNetwork "enp5s0" gruvboxish 10
                 -- CPU temp ryzen
  , Run $ myAmdTemp gruvboxish 10
  ]

phobosTemplate = "%StdinReader% }{ " ++ templateTail "dynnetwork" "k10temp"

phobosMonitors =
  commonMonitors 10 3 4 ++
  [ Run $ myDynNetwork gruvboxish 10
                                          -- CPU temp ryzen
  , Run $ myAmdTemp gruvboxish 10
  ]

devolaTemplate = "%StdinReader% }{ %dynnetwork% | %bat1% | " ++ cpuPart "thermal0" ++ " | " ++ volPart ++ " | " ++ presBright ++ " | %date% %_XMONAD_PAD%"
devolaMonitors =
  commonMonitors 50 1 4 ++
  [ Run $ myDynNetwork gruvboxish 10
  , Run $ myIntelTemp gruvboxish 0 50
  , Run $ myBat1 gruvboxish "BAT0"
  , Run $ myIntelBl 50
  ]

ninesTemplate = "%StdinReader% }{ <action=`nm-connection-editor`>%dynnetwork%</action> | <action=`xfce4-power-manager-settings`>%bat1%</action> | " ++ cpuPart "thermal0" ++ " | " ++ volPart ++ " | " ++ presBright ++ " | %date% %_XMONAD_PAD%"
ninesMonitors =
  commonMonitors 100 2 3 ++
  [ Run $ myDynNetwork gruvboxish 30
  , Run $ myIntelTemp gruvboxish 0 50
  , Run $ myBat1 gruvboxish "BAT0"
  , Run $ myAMDBl 50
  ]

togglePresModeCmd = "xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -T"
presBright = "<action=`" ++ togglePresModeCmd ++ "`><fn=2>%pmode%</fn>%bright%</action>"

vaioTemplate =
  " %StdinReader% }{ %dynnetwork% | %bat1%%bat2% | " ++ cpuPart "thermal0" ++ " | " ++ volPart ++ " | " ++ presBright ++ " | %date% %_XMONAD_PAD%"

vaioMonitors =
  commonMonitors 100 1 3 ++
  [ Run $ myDynNetwork gruvboxish 100
  , Run $ myIntelTemp gruvboxish 0 100
  , Run $ myBat1 gruvboxish "BAT0"
  , Run $ myBat2 gruvboxish "BAT1"
  , Run $ myIntelBl 30
  ]

sbTemplate =
  " %StdinReader% }{ %dynnetwork% | %bat1%%bat2% | " ++ cpuPart "thermal9" ++ " | " ++ volPart ++ " | " ++ presBright ++ " | %date% %_XMONAD_PAD%"

sbMonitors =
  commonMonitors 50 1 4 ++
  [ Run $ myDynNetwork gruvboxish 50
  , Run $ myIntelTemp gruvboxish 9 50
  , Run $ myBat1 gruvboxish "BAT1"
  , Run $ myBat2 gruvboxish "BAT2"
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
  (baseConfig gruvboxish 11)
    { template = ninesTemplate
    , commands = ninesMonitors
    }
hostConfig "vaio" c =
  (baseConfig gruvboxish 9)
    { template = vaioTemplate
    , commands = vaioMonitors
    }
hostConfig "phobos" c =
  (baseConfig gruvboxish 11)
    { template = phobosTemplate
    , commands = phobosMonitors
    }
hostConfig "sb" c =
  (baseConfig gruvboxish 9)
    { template = sbTemplate
    , commands = sbMonitors
    }
hostConfig "devola" c =
  (baseConfig gruvboxish 9)
    { template = devolaTemplate
    , commands = devolaMonitors
    }
