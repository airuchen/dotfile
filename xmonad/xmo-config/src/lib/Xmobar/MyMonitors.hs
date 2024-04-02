-- https://codeberg.org/xmobar/xmobar/src/branch/master/doc/plugins.org
-- nerdfonts: \int(whatever)

module Xmobar.MyMonitors where

import XMonad.CustomColors
import Xmobar
import Helpers

baseConfig :: Int -> XPosition -> Config
baseConfig fontsize pos =
  defaultConfig
    { font = "DejaVu Sans Bold " ++ show fontsize
    , additionalFonts =
        [ "DejaVu Sans Mono Bold " ++ show fontsize
        , "Symbola Bold " ++ show (fontsize + 1)
        , "DejaVuSansMono Nerd Font Bold " ++ show (fontsize + 2)
        ]
    , iconRoot     = myHome ++ "/config/xmonad/icons"
    , bgColor      = xmbBg myTheme
    , fgColor      = xmbFg myTheme
    , alpha        = 220
    , border       = NoBorder
    , borderColor  = xmbBg myTheme
    , position     = pos
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
sep = xmoSep myTheme

colArgs :: [String]
colArgs =
  ["--low", monitorLow myTheme, "--normal", monitorNormal myTheme, "--high", monitorHigh myTheme]

colArgs' :: [String]
colArgs' =
  ["--low", monitorHigh myTheme, "--normal", monitorNormal myTheme, "--high", monitorLow myTheme]

buildArgs :: [String] -> [String] -> [String]
buildArgs args extra = args ++ colArgs ++ ["--"] ++ extra

buildArgs' :: [String] -> [String] -> [String]
buildArgs' args extra = args ++ colArgs' ++ ["--"] ++ extra

commonNetOpts :: [String]
commonNetOpts =
  buildArgs
    [ "--template" , "<action=`nm-connection-editor`><fn=3>\983831</fn><fn=1><tx></fn>↑ <fn=1><rx></fn>↓kB/s</action>" ++ sep
    , "--Low" , "10240" -- units: B/s
    , "--High" , "55120" -- units: B/s
    , "--minwidth" , "5"
    , "--ddigits" , "0"
    , "--padchars" , " "
    , "--align" , "l"
    ]
    []

myNetwork :: String -> Int -> Monitors
myNetwork device rate = Network device commonNetOpts rate

myDynNetwork :: Int -> Monitors
myDynNetwork rate = DynNetwork commonNetOpts rate

myCpu :: Int -> Monitors
myCpu rate =
  Cpu
    (buildArgs
       [ "--template" , "<icon=cpu_flat.xpm/><fn=1><total></fn>%"
       , "--Low" , "50" -- units: %
       , "--High" , "85" -- units: %
       , "--ppad" , "3"
       ]
       [])
    rate

myCpuFreq :: Int -> Int -> Int -> Monitors
myCpuFreq low high rate =
  CpuFreq
    (buildArgs
       [ "-t" , "<fn=1><cpu0>GHz</fn>"
       , "-d" , "2"
       , "-L" , show low
       , "-H" , show high
       , "-w" , "4"
       ]
       [])
    rate

myAmdTemp :: Int -> Monitors
myAmdTemp rate =
  K10Temp
    "0000:00:18.3"
    (buildArgs
       [ "-t" , "<fn=1><Tdie></fn>°C"
       , "--Low" , "50" -- units: C
       , "--High" , "60" -- units: C
       ]
       [])
    rate

myIntelTemp :: Int -> Int -> Monitors
myIntelTemp zone rate =
  ThermalZone
    zone
    (buildArgs
       [ "--template" , "<fn=1><temp></fn>°C"
       , "--Low" , "50" -- units: C
       , "--High" , "60" -- units: C
       ]
       [])
    rate

myMem :: Int -> Monitors
myMem rate =
  Memory
    (buildArgs
       [ "--template" , "<icon=mem_flat.xpm/> <fn=1><usedratio></fn>%"
       , "--Low" , "20" -- units: %
       , "--High" , "70" -- units: %
       , "--ppad" , "2"
       ]
       [])
    rate

--   (%F = y-m-d date, %a = day of week, %T = h:m:s time)
myDate :: Date
myDate = Date "%d.%m. (%a, W%V) %T" "date" 10

-- Actual pattern
mpdFormat :: String
mpdFormat = "<artist> [<date> - <album>] <track> - <title> <statei> <ipat>"

myMPD :: Monitors
myMPD =
  MPD
    [ "-t"
    , "<action=`xdotool key super+shift+control+n` button=2><action=`mpc toggle` button=1><action=`mpc next` button=5><action=`mpc prev` button=4>" ++ mpdFormat ++ "</action></action></action></action>"
    --, "--bback" , "□"
    --, "--bfore" , "■" -- ▣
    , "--"
    , "--lapsed-icon-pattern", "<icon=prog%%.xpm/>"
    , "-P" , "<icon=play.xpm/>"
    , "-S" , "<icon=stop.xpm/>"
    , "-Z" , "<icon=pause.xpm/>"
    ]
    50


-- 📁 📂 🗀 󰋊 
-- 🗁

-- "⚪◔◑◕●" -- TODO use icons?
--  
-- empty to full
circleBar = "\62634\985758\985759\985760\985761\985762\985763\985764\985765"
-- full to empty
circleBarRev = "\985765\985764\985763\985762\985761\985760\985759\985758\62634"

myDiskU :: Monitors
myDiskU = DiskU [("/", "<fn=3>\61600 <freebar>  </fn><fn=1><free></fn> ")]
                  (buildArgs'
                  [ "-f", circleBarRev
                  , "-W", "0"
                  ]
                  [])
                  1000

myDiskIO :: Monitors
myDiskIO = DiskIO [("/", "<fn=1><read></fn>↑ <fn=1><write></fn>↓")]
                (buildArgs
                  [ "--Low" ,  (show $ 1024 * 1024 * 1) -- units: B/s
                  , "--High" , (show $ 1024 * 1024 * 20) -- units: B/s
                  , "--minwidth" , "5"
                  , "--ddigits" , "0"
                  , "--padchars" , " "
                  , "--align" , "l"
                  ]
                  [])
                  100

chargingProgress = "\985247\985244\983174\983175\983176\985245\983177\985246\983178\983179\983173"

dischargingProgress = "\983182\983162\983163\983164\983165\983166\983167\983168\983169\983170\983161"

commonBatSettings :: String -> [String]
commonBatSettings template =
  buildArgs'
    [ "--template" , template
    , "--Low" , "15" -- units: %
    , "--High" , "60" -- units: %
    , "-f", dischargingProgress
    , "-W", "0"
    ]
    -- AC off
    [ "-o" , "<fn=3><leftbar></fn> <fn=1><left></fn>% <fn=1><timeleft></fn>" -- discharge status
    -- AC "on" status
    , "-O" , "<fn=3><leftbar>\988171</fn> <fn=1><left></fn>% <fn=1><timeleft></fn>"
    -- charged status (AC idle)
    , "-i" , "<fn=3>\60205</fn> <fn=1><left></fn>%"
    ]

myBat1 :: String -> Monitors
myBat1 dev =
  BatteryN [dev] (commonBatSettings "<acstatus>") 300 "bat1"

myBat2 :: String -> Monitors
myBat2 dev = BatteryN [dev] (commonBatSettings ", <acstatus>") 300 "bat2"

-- myPulse :: Int -> Monitors
-- myPulse rate =
--   Volume
--     "default"
--     "Master"
--     [ "-t" , "<fn=3><status></fn><fn=1><volume></fn>%"
--     , "--ppad" , "3"
--     , "--"
--     , "--on"  , "\984446"
--     , "--off" , "\984449"
--     , "--onc" , monitorLow myTheme
--     , "--offc" , monitorHigh myTheme
--     ]
--     rate

myAlsa =
  Alsa
    "default"
    "Master"
    [ "-t" , "<fn=3><status></fn><fn=1><volume></fn>%"
    , "--ppad" , "3"
    , "--"
    , "--on"  , "\984446"
    , "--off" , "\984449"
    , "--onc" , monitorLow myTheme
    , "--offc", monitorHigh myTheme
    , "--alsactl=/usr/sbin/alsactl"
    ]

-- Can show if mic is muted or not, but can't see if anyone is actually using a recording stream
-- alsaMic =
--   Alsa
--     "default"
--     "Capture"
--     [ "-t" , "<status>"
--     , "--"
--     , "--on" , "<fn=2>⏺</fn>"
--     , "--off" , "<fn=2> </fn>"
--     , "--onc" , monitorLow myTheme
--     , "--offc" , monitorHigh myTheme
--     ]

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

myPodman = Com (myHome ++ "/config/scripts/container_count.sh") [] "pods" 100

volPart :: String
volPart = "<action=`xdotool key XF86AudioMute` button=1><action=`killall pavucontrol || pavucontrol` button=23>%alsa:default:Master%</action></action>"

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
  cpuPart temptag ++ sep ++ "<fn=3>\985192 </fn><fn=1>%pods%</fn>" ++ sep ++ "%disku% %diskio%" ++ sep ++ volPart ++ sep ++ gammaStep ++ sep ++ presPart ++ sep ++ "%date%" ++ sep ++ "%_XMONAD_PAD%"
--  🐋🦭

commonMonitors rate cpulow cpuhigh =
  [ Run XMonadLog
  , Run $ myCpu rate
                      -- memory usage monitor
  , Run $ myMem rate
                      -- time and date indicator
  , Run myDate
  , Run $ myCpuFreq cpulow cpuhigh rate
  , Run $ myAlsa
  , Run $ myDiskU
  , Run $ myDiskIO
  , Run $ PipeReader "?:${HOME}/.local/state/presmode" "pmode"
  , Run $ XPropertyLog "_XMONAD_PAD"
  , Run $ PipeReader "?:${HOME}/.local/state/gammastep" "gammastep"
  , Run myPodman
  ]

ikarusTemplate = "%XMonadLog% }{ %mpd%" ++ sep ++ templateTail "dynnetwork" "k10temp"

ikarusMonitors =
  commonMonitors 20 3 4 ++
  [ Run myMPD
  , Run $ myDynNetwork 20
   -- CPU temp ryzen
  , Run $ myAmdTemp 20
  ]

ninesTemplate = "%XMonadLog% }{ %dynnetwork%<action=`xfce4-power-manager-settings`>%bat1%</action>" ++ sep ++ cpuPart "thermal0" ++ sep ++ "%disku% %diskio%" ++ sep ++ volPart ++ sep ++ presBright ++ sep ++ "%date%" ++ sep ++ "%_XMONAD_PAD%"
ninesMonitors =
  commonMonitors 100 2 3 ++
  [ Run $ myDynNetwork 30
  , Run $ myIntelTemp 0 50
  , Run $ myBat1 "BAT0"
  , Run $ myAMDBl 50
  ]

togglePresModeCmd :: String
togglePresModeCmd = myHome ++ "/config/scripts/pres_mode toggle"

gammaStep :: String
gammaStep = "<action=`pkill -USR1 '^gammastep$'`><fn=3>%gammastep%</fn></action>"

presBright :: String
presBright = gammaStep ++ sep ++ "<action=`" ++ togglePresModeCmd ++ "`><fn=3>%pmode%</fn>%bright%</action>"

vaioTemplate =
  " %XMonadLog% }{ %dynnetwork%%bat1%%bat2%" ++ sep ++ cpuPart "thermal0" ++ sep ++ volPart ++ sep ++ presBright ++ sep ++ "%date% %_XMONAD_PAD%"

vaioMonitors =
  commonMonitors 100 1 3 ++
  [ Run $ myDynNetwork 100
  , Run $ myIntelTemp 0 100
  , Run $ myBat1 "BAT0"
  , Run $ myBat2 "BAT1"
  , Run $ myIntelBl 30
  ]

-- Note: font size is affected by DPI setting and will grow the bar
middleScreen :: XPosition
middleScreen = Static { xpos = 3840 , ypos = 0, width = 3840, height = 25 }

defaultPos :: XPosition
defaultPos = TopH 25

ninesPos :: XPosition
ninesPos = TopH 37

hostConfig :: String -> Config
hostConfig "ikarus" =
  (baseConfig 11 middleScreen)
    { template = ikarusTemplate
    , commands = ikarusMonitors
    }
hostConfig "nines" =
  (baseConfig 17 ninesPos)
    { template = ninesTemplate
    , commands = ninesMonitors
    }
hostConfig "vaio" =
  (baseConfig 9 defaultPos)
    { template = vaioTemplate
    , commands = vaioMonitors
    }
