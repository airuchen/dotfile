import qualified Data.Map as M
import Control.Monad (liftM2)
import Control.Applicative
--import System.Process (readProcess) -- to get hostname

import XMonad hiding ( (|||) )
import XMonad.Prelude
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.EwmhDesktops -- Fullscreen event hook
import XMonad.Hooks.InsertPosition -- don't steal master when making new terminal
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.Rescreen
import qualified XMonad.StackSet as W
import XMonad.ManageHook

import Graphics.X11.ExtraTypes

import XMonad.Layout
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.ThreeColumns
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.Spacing
import XMonad.Layout.Grid
import XMonad.Layout.GridVariants as GV
import XMonad.Layout.Maximize -- Temporarily maximize window
import XMonad.Layout.Renamed -- Rename layouts (removes Maximeze prefix)
import XMonad.Layout.PerWorkspace -- layouts per fowkspace
import XMonad.Layout.Reflect -- flip master to the right
import XMonad.Layout.MultiToggle -- toggle reflect, etc
import XMonad.Layout.Tabbed
import XMonad.Layout.Master
import XMonad.Layout.WorkspaceDir

import XMonad.Actions.Submap
import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import XMonad.Actions.MostRecentlyUsed
import XMonad.Actions.GroupNavigation -- nextMatch/historyhook for alt-tab across workspaces
import XMonad.Actions.PhysicalScreens
import qualified XMonad.Actions.Navigation2D as N
import XMonad.Actions.EasyMotion (selectWindow, EasyMotionConfig(..), proportional, ChordKeys(..))

import XMonad.Util.Run
import XMonad.Util.WorkspaceCompare (getSortByXineramaPhysicalRule)
import XMonad.Util.NamedScratchpad
import XMonad.Util.EZConfig
import XMonad.Util.Hacks (fixSteamFlicker)
import XMonad.Util.XUtils (WindowConfig(..))

import XMonad.Prompt
import XMonad.Prompt.SaferPrompts
import XMonad.Prompt.Window
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.MyPass
import XMonad.Prompt.ConfirmPrompt
import XMonad.Prompt.OrgMode (orgPrompt, orgPromptPrimary)

import XMonad.CustomColors
import Helpers

main = do
  --hostName <- getEnv "HOSTNAME"
  mandb <- getAllManEntries
  let myBar = statusBarProp (myHome ++ "/.local/bin/xmobar-custom") myPP
  let resultConfig = addAfterRescreenHook myAfterRescreenHook . withEasySB myBar toggleStrutsKey . N.withNavigation2DConfig def . configureMRU . ewmh $ myConfig mandb
  xmonad resultConfig

myCol :: CustomColors
myCol = myTheme

sbBrackets :: String -> String
sbBrackets = wrap "❲" "❳"

-- Since this only really works for single-screen setups the colour here should be ok
indicateCopies :: WorkspaceId -> String
indicateCopies = xmobarColor (xmbHidden myCol) "" . wrap ("<box type=Bottom width=3 color=" ++ (xmbActiveScreen myCol) ++ ">") "</box>" . sbBrackets

myScreenOrder :: ScreenComparator
myScreenOrder = horizontalScreenOrderer

-- Status bar options
myPP :: X PP
myPP = copiesPP indicateCopies $ xmobarPP { ppCurrent = xmobarColor (xmbActiveScreen myCol) "" . wrap ("<box type=Bottom width=3 color=" ++ (xmbActiveScreen myCol) ++ ">❲") "❳</box>"
                , ppVisible = xmobarColor (xmbVisScreen myCol) "" . sbBrackets
                , ppHidden = xmobarColor (xmbHidden myCol) "" . sbBrackets
                , ppLayout = xmobarColor (xmbLayout myCol) ""
                , ppSep = xmoSep myCol
                , ppWsSep = ""
                , ppTitle = xmobarColor (xmbTitle myCol) "" . shorten 180
                , ppSort = getSortByXineramaPhysicalRule myScreenOrder
                }

myTrayEventHook :: Event -> X All
myTrayEventHook (PropertyEvent { ev_window = w }) = do
    whenX (runQuery checkDock w <&&> (runQuery panelQuery w)) (
      withDisplay $ \d -> withWindowAttributes d w $ \wa -> do
        let pixelPad = (fromIntegral $ wa_width wa)
        xmonadPropLog' "_XMONAD_PAD" ("<hspace=" ++ show pixelPad ++ "/>")
      )
    return (All True)

myTrayEventHook (UnmapEvent { ev_window = w }) = do
    whenX (runQuery checkDock w <&&> (runQuery panelQuery w)) (
      withDisplay $ \d -> withWindowAttributes d w $ \wa -> do
        xmonadPropLog' "_XMONAD_PAD" "<hspace=0/>"
      )
    return (All True)

myTrayEventHook _ = return (All True)

panelQuery :: Query Bool
panelQuery = className =? "stalonetray"

-- Reset wallpapers after screen config changes
myAfterRescreenHook :: X ()
myAfterRescreenHook = spawn "~/config/scripts/set_multi_wallpapers.sh"

-- Key binding to toggle the gap for the bar
toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

-- Create new windows below current window (default is above). This prevents master being stolen
-- Problem is that floating popups are placed under other windows...
insertHook :: ManageHook
--insertHook = insertPosition Below Newer
insertHook = insertPosition Above Newer

-- I don't know what the return type actually is...
-- myConfig :: String -> String -> XConfig l
myConfig mandb = def { terminal           = myTerminal
                     , modMask            = myModMask
                     , borderWidth        = myBorderWidth
                     , workspaces         = myWorkspaces
                     , keys               = \c -> mkKeymap c $ myKeys mandb c
                               -- Compose from right to left
                     , manageHook         = insertHook <+> manageDocks <+> namedScratchpadManageHook scratchpads <+> myManageHook <+> manageHook def
                     , focusedBorderColor = borderFocused myCol
                     , normalBorderColor  = borderNormal myCol
                     , layoutHook         = myLayout
                               --, logHook            = historyHook
                               -- Versions with transparency
                     , logHook            = fadeWindowsLogHook myFadeHook <+> historyHook
                     , handleEventHook    = fadeWindowsEventHook <+> myTrayEventHook <+> swallowEventHook swallowParents windowsToSwallow <+> fixSteamFlicker
                     , startupHook        = spawn "~/.xmonad/startup-hook"
                     }

hasColemak :: Bool
hasColemak = elem myHostname ["ikarus"]

isHomePc :: Bool
isHomePc = elem myHostname ["ikarus", "nines"]

gapsOnByDefault :: Bool
gapsOnByDefault = not $ elem myHostname ["2b"]

myTerminal :: String
myTerminal = "st"

lightWeightTerm :: String
lightWeightTerm = "st"

myEditor :: String
myEditor = "nvim"

myModMask :: KeyMask
myModMask = mod4Mask -- Win key

altMask :: KeyMask
altMask = mod1Mask

myBorderWidth :: Dimension
myBorderWidth = case myHostname of
  "nines" -> 2 -- high dpi
  _ -> 1

myWorkspaces :: [String]
myWorkspaces = if isHomePc
                  then map show [1..4] ++ ["dev", "www", "mail", "steam", "full", "NSP"]
                  else map show [1..4] ++ ["dev", "www", "mail", "com", "full", "NSP"]

centeredFloating :: ManageHook
centeredFloating = customFloating $ W.RationalRect (1/6) (1/6) (4/6) (4/6)

smallFloating :: ManageHook
smallFloating = customFloating $ W.RationalRect (1/4) (1/4) (2/4) (2/4)

-- Scratchpad with st and title
myNS :: String -> String -> String -> String -> [String] -> ManageHook -> NamedScratchpad
myNS name term termTitle app args layout = NS name termCmd (title =? termTitle) layout
  where
    termCmd = term ++ " -t \"" ++ termTitle ++ "\" -e " ++ app ++ argsExpanded args
    argsExpanded [] = ""
    argsExpanded a = " " ++ unwords a

scratchpads :: [NamedScratchpad]
scratchpads = [ myNS "htop"    lightWeightTerm "htop" "htop" [] centeredFloating
              , myNS "ncmpcpp" lightWeightTerm "\986296 ncmpcpp" "ncmpcpp" [] centeredFloating
              , myNS "ghci"    myTerminal      "\59255 GHCi" "stack" ["--silent", "ghci", "--no-load"] smallFloating
              , myNS "bpython" myTerminal      "\59196 Python" "bpython" [] smallFloating
              ]

-- Match strings prefixed with space
spacePrefixed :: String -> Bool
spacePrefixed (' ':_) = True
spacePrefixed _ = False

hideSpacePrefixed :: [String] -> [String]
hideSpacePrefixed = filter (not . spacePrefixed)

tabBarTheme ::XMonad.Layout.Tabbed.Theme
tabBarTheme = def { activeBorderColor = borderFocused myCol
                  , inactiveBorderColor = borderDarker myCol
                  , activeColor = borderFocused myCol
                  , inactiveColor = borderNormal myCol
                  , urgentColor = urgent myCol
                  , urgentBorderColor = urgentBorder myCol
                  , fontName = myFont 10
                  , activeTextColor = focusedText myCol
                  , inactiveTextColor = unfocusedText myCol
                  , urgentTextColor = focusedText myCol
                  }

-- add colemak specific quick keys
withColemakKeys :: EasyMotionConfig -> EasyMotionConfig
withColemakKeys conf = if not hasColemak then conf
        else conf { sKeys = AnyKeys [xK_n, xK_e, xK_i, xK_r, xK_s, xK_t] }

myFont :: Int -> String
myFont sz = "xft:DejaVu Sans Mono:size=" ++ show sz ++ ":medium:antialias=true"

emConfig :: EasyMotionConfig
emConfig = withColemakKeys def { emFont = myFont 100
                               , cancelKey = xK_Escape
                               , borderPx = 8
                               , overlayF = proportional (0.5 :: Double)
                               , txtCol = promptFG myCol
                               , bgCol = promptBG myCol
                               , borderCol = promptBorder myCol
                               }


-- Prompt config
myXPConfig :: XPConfig
myXPConfig  = def { position = CenteredAt 0.1 0.9
                  , font = myFont 13
                  , height = 40
                  , promptBorderWidth = 1
                  , borderColor = promptBorder myCol
                  , bgColor = promptBG myCol
                  , fgColor = promptFG myCol
                  , fgHLight = promptHLFG myCol
                  , bgHLight = promptHLBG myCol
                  , historyFilter = hideSpacePrefixed . deleteConsecutive
                  , maxComplRows = Just 50
                  }

-- Password prompt config
passXPConfig :: XPConfig
passXPConfig = myXPConfig { position = CenteredAt 0.3 0.2
                          , promptBorderWidth = 10
                          , height = 50
                          , borderColor = promptBorder2 myCol
                          , showCompletionOnTab = True
                          , historySize = 0
                          , searchPredicate = fuzzyMatch
                          }

passXPWorkConfig :: XPConfig
passXPWorkConfig = passXPConfig { borderColor = "#5ae2d4"
                                , defaultText = "work/"
                                }

orgRoot :: String
orgRoot = myHome ++ "/Documents/org/"

-- Refile location
orgRefileFile :: String
orgRefileFile = orgRoot ++ "0_refile.org"

-- Capture command for neovim
-- We set a custom title for a center-hook, and increase the size a bit with the geometry
orgNvimCapture :: [String]
orgNvimCapture = ["-t", "org-capture", "-g", "120x40", "-e", "nvim", "-c", "cd " ++ orgRoot, "-c", "lua require('orgmode').capture:prompt()"]
orgRoamNvimCapture :: [String]
orgRoamNvimCapture = ["-t", "org-capture", "-g", "120x40", "-e", "nvim", "-c", "cd " ++ orgRoot, "-c", "lua require('org-roam').api.capture_node()"]

-- Opens nvim in org folder
orgNvimOpen :: [String]
orgNvimOpen = ["-e", "nvim", "-c", "cd " ++ orgRoot, orgRoot]

-- Opens refile file
orgNvimRefile :: [String]
orgNvimRefile = ["-e", "nvim", "-c", "cd " ++ orgRoot, orgRefileFile]

-- Orgmode prompts
orgXPConfig :: XPConfig
orgXPConfig = myXPConfig { position = CenteredAt 0.1 0.95
                         , promptBorderWidth = 5
                         , borderColor = promptBorder2 myCol
                         }

-- Red for confirmations
confiXPConfig = passXPConfig { position = CenteredAt 0.3 0.3
                             , borderColor = monitorHigh myCol
                             }

-- Prompt config with fuzzy matching
fuzzyXPConfig :: XPConfig
fuzzyXPConfig = myXPConfig { searchPredicate = fuzzyMatch
                           , autoComplete = Just 500000 -- trigger action if there's just one completion left after this many milliseconds
                           , changeModeKey = xK_Alt_L
                           , historyFilter = const []
                           }


getWorkspace :: Int -> String
getWorkspace d = myWorkspaces !! (d - 1)

toggleFloat w = windows (\s -> if M.member w (W.floating s)
                               then W.sink w s
                               else W.float w (W.RationalRect (1/8) (1/8) (6/8) (6/8)) s)

submapHintCfg :: WindowConfig
submapHintCfg = def
  {
    winFont = myFont 30
  , winBg = promptBG myCol
  , winFg = promptFG myCol
  }

captureMappings :: [(String, X ())]
captureMappings = [("M-o", visualSubmap submapHintCfg $ M.fromList $ map (\(k, s, a) -> (k, (s, a)))
    [ ((0, xK_n), "Roam Note", safeSpawn lightWeightTerm orgRoamNvimCapture)
    , ((0, xK_c), "Capture", safeSpawn lightWeightTerm orgNvimCapture)
    , ((0, xK_o), "Quick Note", orgPrompt orgXPConfig "NOTE" orgRefileFile)
    , ((shiftMask, xK_o), "Note + PS", orgPromptPrimary orgXPConfig "NOTE" orgRefileFile)
    , ((0, xK_t), "Quick Task", orgPrompt orgXPConfig "TODO" orgRefileFile)
    , ((shiftMask, xK_t), "Task + PS", orgPromptPrimary orgXPConfig "TODO" orgRefileFile)
    , ((0, xK_r), "Refile", safeSpawn lightWeightTerm orgNvimRefile)
    ])]

-- M is Mod
-- M1 is Alt
myKeys :: [ManEntry] -> XConfig Layout -> [(String, X())]
myKeys mandb conf@XConfig {XMonad.modMask = modMask} =
    -- launching and killing programs
    [ ("M-S-<Return>", safeSpawnProg $ XMonad.terminal conf) -- %! Launch terminal
    , ("M1-S-<Return>", safeSpawnProg lightWeightTerm)
    , ("M1-<Space>", safeSpawn "dmenu_run_history" ["-p", "Run"]) -- ["-c", "-l", "40"]) -- %! dmenu with history
    , ("M-S-c", kill1) -- %! Removes a copy of the focused window or closes it if it's the last one.
    , ("M-f", safeSpawnProg "firefox") -- %! Launch firefox
    , ("M-S-f", safeSpawnProg "thunar") -- %! Launch thunar
    , ("M-S-b", safeSpawn lightWeightTerm ["-t", "Newsboat", "-e", "sh", "-c", "newsboat"])
    , ("M-v", safeSpawn lightWeightTerm ["-e", myEditor]) -- %! Launch vim
    , ("M-S-v", safeSpawn lightWeightTerm orgNvimOpen) -- %! Open orgmode directory in nvim
    , ("M-s", saferSshPrompt (myHome ++ "/.ssh/config") myXPConfig) -- %! SSH prompt
    , ("M-S-s", saferSftpPrompt (myHome ++ "/.ssh/config") myXPConfig) -- %! SFTP prompt
    , ("M-S-m", saferManPrompt mandb myXPConfig) -- %! man prompt
    , ("M-g", windowMultiPrompt fuzzyXPConfig [(Goto, allWindows), (Goto, wsWindows)])
    , ("M-M1-g", windowMultiPrompt fuzzyXPConfig [(Goto, wsWindows), (Goto, allWindows)])
    , ("M-S-g", windowPrompt fuzzyXPConfig Bring allWindows)
    , ("M-S-p p", passPrompt passXPConfig)
    , ("M-S-p u", passUserPrompt passXPConfig)
    , ("M-S-p o", passOpenUrlPrompt passXPConfig)
    , ("M-M1-p p", passPrompt passXPWorkConfig)
    , ("M-M1-p u", passUserPrompt passXPWorkConfig)
    , ("M-M1-p o", passOpenUrlPrompt passXPWorkConfig)
    , ("M-c", changeDir myXPConfig)

    -- Scratchpads
    , ("M-S-t"       , namedScratchpadAction scratchpads "htop")
    , ("M-a"         , namedScratchpadAction scratchpads "ghci")
    , ("M-p"         , namedScratchpadAction scratchpads "bpython")

    , ("M-S-C-n"     , namedScratchpadAction scratchpads "ncmpcpp") -- for xdotool
    , ("M-n n"       , namedScratchpadAction scratchpads "ncmpcpp")
    , ("M-n M-n"     , namedScratchpadAction scratchpads "ncmpcpp")

    -- MPD control
    , ("M-n <Space>" , safeSpawn "mpc" ["toggle"])
    , ("M-n ."       , safeSpawn "mpc" ["next"])
    , ("M-n ,"       , safeSpawn "mpc" ["prev"])
    , ("M-n r"       , safeSpawn "mpdrandom" ["-l", "-b", "Music/what"])
    , ("M-n a"       , safeSpawn "bash" [myHome ++ "/config/scripts/art.sh"])
    ]
    ++
    [ ("M-n " ++ [key], safeSpawn "mpc" ["volume", show (10 * v)]) | (key, v) <- zip "1234567890" [1..] ]
    -- colemak
    ++
    [ ("M-n " ++ [key], safeSpawn "mpc" ["volume", show (10 * v)]) | (key, v) <- zip "qwfpbjluy;" [1..] ]
    ++

    -- Layouts
    [ ("M-S-<Space>"  , sendMessage NextLayout) -- %! Rotate through the available layout algorithms
    , ("M-M1-<Space>" , setLayout $ XMonad.layoutHook conf) -- %! Reset the layouts on the current workspace to default
    , ("M-z"          , withFocused (sendMessage . maximizeRestore)) -- %! Temporarily toggle fullscreen for selected window
    , ("M-S-z"        , sendMessage $ JumpToLayout "Full") -- %! Switch to the actual fullscreen layout
    , ("M-x"          , sendMessage (Toggle REFLECTX) <+> sendMessage (Toggle REFLECTY)) -- toggle horizontal mirroring
    , ("M-S-n"        , refresh) -- %! Resize viewed windows to the correct size
    , ("M-\\"         , sendMessage (ModifyWindowBorderEnabled not) <+> sendMessage (ModifyScreenBorderEnabled not)) -- %! Toggle gaps

    -- move focus up or down the window stack
    , ("M-<Tab>"   , toggleWS' ["NSP"]  ) -- %! Previous ws in history
    , ("M-S-<Tab>" , moveTo Next $ hiddenWS :&: Not emptyWS :&: ignoringWSs ["NSP"]) -- %! Cycle through all open, not visible workspaces
    , ("M1-<Tab>"  , mostRecentlyUsed [xK_Alt_L, xK_Alt_R] xK_Tab)
    , ("M-m"       , windows W.focusMaster) -- %! Move focus to the master window
    , ("M-j"       , windows W.focusDown  ) -- %! Move focus to the next window
    , ("M-k"       , windows W.focusUp    ) -- %! Move focus to the previous window
    , ("M-<Space>" , selectWindow emConfig >>= (`whenJust` windows . W.focusWindow)) -- %! Rotate through the available layout algorithms

    -- modifying the window order
    , ("M-<Return>" , windows W.swapMaster) -- %! Swap the focused window and the master window
    , ("M-S-j"      , windows W.swapDown  ) -- %! Swap the focused window with the next window
    , ("M-S-k"      , windows W.swapUp    ) -- %! Swap the focused window with the previous window

    -- resizing the master/slave ratio
    , ("M-S-h", sendMessage Shrink) -- %! Shrink the master area
    , ("M-S-l", sendMessage Expand) -- %! Expand the master area

    -- Navigation2D
    , ("M-l"         , N.windowGo N.R False)
    , ("M-h"         , N.windowGo N.L False)
    , ("M-C-k"       , N.windowGo N.U False)
    , ("M-C-j"       , N.windowGo N.D False)
    , ("M-C-<Space>" , N.switchLayer)
    , ("M-C-l"       , N.windowSwap N.R False)
    , ("M-C-h"       , N.windowSwap N.L False)

    -- increase or decrease number of windows in the master area
    , ("M-,",   sendMessage (IncMasterN 1))       -- %! Increment the number of windows in the master area
    , ("M-.",   sendMessage (IncMasterN (-1)))    -- %! Decrement the number of windows in the master area
    , ("M-S-.", sendMessage (IncMasterRows 1))    -- %! Increment the master grid rows in the splitgrid layout
    , ("M-S-,", sendMessage (IncMasterRows (-1))) -- %! Decrement the master grid rows in the splitgrid layout
    , ("M-C-.", sendMessage (IncMasterCols 1))    -- %! Increment the master grid cols in the splitgrid layout
    , ("M-C-,", sendMessage (IncMasterCols (-1))) -- %! Decrement the master grid cols in the splitgrid layout

    -- floating layer support
    , ("M-t", withFocused toggleFloat) -- %! Toggle floating state of window

    -- quit, or restart
    , ("M-q", safeSpawn "xfce4-session-logout" [])
    , ("M-S-q" , confirmPrompt confiXPConfig "recompile and restart?" $
        spawn "if type ~/.xmonad/build.sh; then ~/.xmonad/build.sh && killall xmobar-custom && ~/.xmonad/xmonad-x86_64-linux --restart; else xmessage build script not found; fi") -- %! Restart xmonad
    , ("M1-C-<Delete>" , safeSpawnProg "xflock4") -- %! lock screen

    -- multimedia keys
    -- User has to be in `video` group
    , ("<XF86MonBrightnessUp>"   , safeSpawn "light" ["-A", "10"])
    , ("<XF86MonBrightnessDown>" , safeSpawn "light" ["-U", "10"])
    -- Pulse/amixer
    -- , ("<XF86AudioRaiseVolume>"  , safeSpawn "amixer" ["set", "-D", "pulse", "Master", "1%+"])
    -- , ("<XF86AudioLowerVolume>"  , safeSpawn "amixer" ["set", "-D", "pulse", "Master", "1%-"])
    -- , ("<XF86AudioMicMute>"      , safeSpawn "pactl" ["set-source-mute", "@DEFAULT_SOURCE@", "toggle"])
    -- , ("<XF86AudioMute>"         , safeSpawn "pactl" ["set-sink-mute", "@DEFAULT_SINK@", "toggle"])
    -- Pipewire
    , ("<XF86AudioRaiseVolume>"  , safeSpawn "wpctl" ["set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", "1%+"])
    , ("<XF86AudioLowerVolume>"  , safeSpawn "wpctl" ["set-volume", "@DEFAULT_AUDIO_SINK@", "1%-"])
    , ("<XF86AudioMicMute>"      , safeSpawn "wpctl" ["set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"])
    , ("<XF86AudioMute>"         , safeSpawn "wpctl" ["set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
    , ("<XF86AudioPlay>"         , safeSpawn "mpc" ["toggle"])
    , ("<XF86AudioStop>"         , safeSpawn "mpc" ["stop"])
    , ("<XF86AudioNext>"         , safeSpawn "mpc" ["next"])
    , ("<XF86AudioPrev>"         , safeSpawn "mpc" ["prev"])

    -- taking screenshots with scrot
    , ("<Print>"    , safeSpawn "scrot" [myHome ++ "/Pictures/screenshots/%Y-%m-%dT%H-%M-%S.png"]) -- Whole screen
    , ("S-<Print>"  , safeSpawn "scrot" ["-u", myHome ++ "/Pictures/screenshots/%Y-%m-%dT%H-%M-%S.png"]) -- Current window
    , ("M1-<Print>" , safeSpawn "scrot" ["-s", myHome ++ "/Pictures/screenshots/%Y-%m-%dT%H-%M-%S.png"]) -- Interactive select

    , ("M-d", safeSpawnProg "xfce4-display-settings")
    ]
    ++
      captureMappings
    ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    -- mod-ctrl-[1..9] %! Copy client to workspace N
    [(m ++ [k], windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) "1234567890"
      , (f, m) <- [(W.greedyView, "M-"), (W.shift, "M-S-"), (copy, "M-C-")]
    ]
    ++
    -- mod-{w,e,r} %! Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r} %! Move client to screen 1, 2, or 3
    [(m ++ [key], f sc)
      | (key, sc) <- zip "wer" [0..]
      , (f, m) <- [(viewScreen myScreenOrder, "M-"), (sendToScreen myScreenOrder, "M-S-")]
    ]

-- The CutWordsLeft removes the "Spacing Maximize" prefix
-- TODO remove gaps from tabbed layout
myLayout = smartBorders $ renamed [CutWordsLeft 2] $ spacings $ maximizeWithPadding 0 $ onWorkspace "4" rvizlayout $ onWorkspace "dev" devlayout $ onWorkspaces ["steam", "com"] steamlayout $ onWorkspace "full" full regularlayout
  where
    spacings = spacingRaw True (Border gapw gapw gapw gapw) gapsOnByDefault (Border gapw gapw gapw gapw) gapsOnByDefault
    gapw = 5

    squaregrid = renamed [Replace "SquareGrid"] $ GridRatio (16/13)
    splitgrid = mkToggle (single REFLECTX) $ renamed [Replace "Grid"] $ GV.SplitGrid GV.L 2 3 (2/3) (16/9) (3/100)
    -- big top window, grid below, use ctrl win ,. to inc/dec cols
    wide' = mkToggle (single REFLECTY) $ renamed [Replace "TopGrid"] $ GV.SplitGrid GV.T 1 1 (2/5) (16/9) (3/100)
    -- Main window on one half, stack of windows half
    tiled n = mkToggle (single REFLECTX) $ Tall 1 (3/100) n
    evenTiled = tiled (1/2)
    -- Main window at the top and a row of small windows below it
    wide = mkToggle (single REFLECTY) $ renamed [Replace "Wide"] $ Mirror $ Tall 1 (3/100) (4/5)
    full = workspaceDir myHome $ noBorders Full
    threecol = mkToggle (single REFLECTX) $ renamed [Replace "Three"] $ ThreeCol 1 (3/100) (5/12)
    devscreen n = mkToggle (single REFLECTX) $ renamed [Replace n] $ Tall 1 (3/100) 0.7
    goldenspiral = spiral (6/7)
    myTabs = renamed [Replace "Tabbed"] $ tabbedBottomAlways shrinkText tabBarTheme

    --regularlayout = threecol ||| evenTiled ||| wide ||| full ||| goldenspiral
    regularlayout = workspaceDir myHome $ splitgrid ||| threecol ||| tiled (3/5) ||| wide' ||| myTabs ||| full
    rvizlayout = workspaceDir (myHome ++ "/git") $ wide ||| squaregrid ||| full ||| evenTiled ||| splitgrid
    devlayout = workspaceDir (myHome ++ "/git") (devscreen "Dev") ||| threecol ||| splitgrid ||| full
    steamlayout = workspaceDir myHome $ devscreen "Soc" ||| full ||| evenTiled ||| wide

myManageHook = composeAll . concat $
  [ [ className =? c --> doCenterFloat | c <- classCenter       ]
  , [ className =? c --> doFloat       | c <- classFloat        ]
  , [ title     =? "org-capture" --> doCenterFloat              ]
  , [ title     =? t --> doFloat       | t <- titleFloats       ]
  , [ title     =? t --> doFullFloat   | t <- titleFullscreen   ]
  , [ className =? c --> doFullFloat   | c <- classFullscreen   ]
  , [ className =? "firefox" --> viewShift (getWs 6)     ]
  , [ className =? "Thunderbird" --> viewShift (getWs 7) ]
  , [ className =? "QtCreator" --> viewShift (getWs 5)   ]
  , [ title     =? "Newsboat" --> viewShift (getWs 2)   ]
  , [ className =? s --> doShift (getWs 8) | s <- classSocial ]
  , [ className =? c --> doShift (getWs 4) | c <- ["rviz", "rviz2"] ]
  , [ className =? c --> hasBorder False | c <-classNoBorder ]
  , [ className =? c --> doIgnore | c <-classIgnore ]
  , [ title     =? t --> doIgnore | t <-titleIgnore ]
  , [ isDialog       --> doCenterFloat ]
  ]
  where
    classCenter     = ["Xfce4-appfinder", "Xmessage", "Pavucontrol"]
    classFloat      = ["feh_cover"]
    titleFloats     = ["File Operation Progress", "xvkbd - Virtual Keyboard", "florence", "Steam Settings"]
    classFullscreen = ["Ristretto", "feh", "Sxiv", "Nsxiv", "mpv", "pathofexile_x64steam.exe", "ns2.exe", "GRIS.exe"]
    titleFullscreen = ["Path of Exile", "Natural Selection 2", "Spark Engine"]
    classNoBorder   = ["firefox", "mpv", "pathofexile_x64steam.exe", "ns2.exe", "GRIS.exe"]
    classIgnore     = ["Life is Strange Before the Storm", "Hyper Light Drifter"]
    titleIgnore     = []
    classSocial     = ["steam", "Steam", "Slack"]
    viewShift       = doF . liftM2 (.) W.greedyView W.shift
    getWs           = getWorkspace

-- Window fading
myFadeHook = composeAll . concat $
  [ [ opaque ]
  , [ isUnfocused <&&> className =? c --> transparency 0.03 | c <- fadeInactive ]
  , [ className =? c --> transparency 0.03 | c <- alwaysFade ]
  , [ className =? c --> opaque | c <- alwaysVisible ]
  , [ className =? "stalonetray" --> transparency ( 220 / 255) ]
  ]
  where
    alwaysVisible = ["firefox", "Thunderbird", "mpv", "rviz"]
    alwaysFade = []
    fadeInactive = ["URxvt", "st-256color", "Alacritty", "Thunar", "neovide"]

-- windows to swallow
windowsToSwallow :: Query Bool
windowsToSwallow = return False

swallowParents :: Query Bool
swallowParents = className =? "st-256color"
