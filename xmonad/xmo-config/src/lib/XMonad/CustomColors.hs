module XMonad.CustomColors
  (
    CustomColors (..),
    solarizedish,
    gruvboxish,
    tokyonight,
    myTheme
  ) where

data CustomColors = CustomColors { xmbActiveScreen :: String
                                 , xmbVisScreen    :: String
                                 , xmbHidden       :: String
                                 , xmbLayout       :: String
                                 , xmbTitle        :: String
                                 , xmbBg           :: String
                                 , xmbFg           :: String
                                 , borderFocused   :: String
                                 , borderNormal    :: String
                                 , borderDarker    :: String
                                 , promptBorder    :: String
                                 , promptBorder2   :: String
                                 , promptBG        :: String
                                 , promptFG        :: String
                                 , promptHLFG      :: String
                                 , promptHLBG      :: String
                                 , urgent          :: String
                                 , urgentBorder    :: String
                                 , focusedText     :: String
                                 , unfocusedText   :: String
                                 , monitorHigh     :: String
                                 , monitorLow      :: String
                                 , monitorNormal   :: String
                                 , xmoSep          :: String
                                 }


-- Golbal theme
myTheme :: CustomColors
myTheme = gruvboxish


-- TODO if i ever use this again, update the colors that are used for tabbing
solarizedish = CustomColors { xmbActiveScreen = "#2aa198"
                            , xmbVisScreen = "red"
                            , xmbHidden = "red"
                            , xmbLayout = "red"
                            , xmbTitle = "#646464"
                            , xmbBg = "black"
                            , xmbFg = "red"
                            , borderFocused = "#2aa198"
                            , borderNormal = "#004400"
                            , borderDarker = "#002200"
                            , promptBorder = "orange"
                            , promptBorder2 = "orange"
                            , promptBG = "grey22"
                            , promptFG = "grey80"
                            , promptHLFG = "black"
                            , promptHLBG = "grey"
                            , urgent = "red"
                            , urgentBorder = "red"
                            , focusedText = "red"
                            , unfocusedText = "red"
                            , monitorHigh = "red"
                            , monitorLow = "green"
                            , monitorNormal = "orange"
                            , xmoSep = " <fc=" ++ "red" ++ ">⠶</fc> " -- :: ⠛ ⣿
                            }

-- gruvbox colors
dark0_hard     = "#1D2021"
dark0          = "#282828"
dark0_soft     = "#32302F"
dark1          = "#3c3836"
dark2          = "#504945"
dark3          = "#665c54"
dark4          = "#7C6F64"

gray_245       = "#928374"
gray_244       = "#928374"

light0_hard    = "#FB4934"
light0         = "#FBF1C7"
light0_soft    = "#F2E5BC"
light1         = "#EBDBB2"
light2         = "#D5C4A1"
light3         = "#BDAE93"
light4         = "#A89984"

bright_red     = "#FB4934"
bright_green   = "#B8BB26"
bright_yellow  = "#FABD2F"
bright_blue    = "#83A598"
bright_purple  = "#D3869B"
bright_aqua    = "#8EC07C"
bright_orange  = "#FE8019"

neutral_red    = "#CC241D"
neutral_green  = "#98971A"
neutral_yellow = "#D79921"
neutral_blue   = "#458588"
neutral_purple = "#B16286"
neutral_aqua   = "#689D6A"
neutral_orange = "#D65D0E"

faded_red      = "#9D0006"
faded_green    = "#79740E"
faded_yellow   = "#B57614"
faded_blue     = "#076678"
faded_purple   = "#8F3F71"
faded_aqua     = "#427B58"
faded_orange   = "#AF3A03"

gruvboxish = CustomColors { xmbActiveScreen = bright_aqua
                          , xmbVisScreen = faded_aqua
                          , xmbHidden = dark3
                          , xmbLayout = neutral_blue
                          , xmbTitle = neutral_green
                          , xmbBg = "black"
                          , xmbFg = dark3
                          , borderFocused = "#803809"
                          , borderNormal  = dark1
                          , borderDarker = dark0
                          , promptBorder = neutral_orange
                          , promptBorder2 = faded_aqua
                          , promptBG = dark1
                          , promptFG = light1
                          , promptHLFG = dark1
                          , promptHLBG = bright_yellow
                          , urgent = neutral_blue
                          , urgentBorder = neutral_green
                          , focusedText = light1
                          , unfocusedText = light4
                          , monitorHigh = faded_red
                          , monitorLow = faded_green
                          , monitorNormal = faded_yellow
                          , xmoSep = " <fc=" ++ faded_purple ++ ">⠶</fc> " -- :: ⠛ ⣿
                          }

tn_bg = "#1a1b26"
tn_bg_dark = "#16161e"
tn_bg_float = "#16161e"
tn_bg_highlight = "#292e42"
tn_bg_popup = "#16161e"
tn_bg_search = "#3d59a1"
tn_bg_sidebar = "#16161e"
tn_bg_statusline = "#16161e"
tn_bg_visual = "#33467c"
tn_black = "#15161e"
tn_blue = "#7aa2f7"
tn_blue0 = "#3d59a1"
tn_blue1 = "#2ac3de"
tn_blue2 = "#0db9d7"
tn_blue5 = "#89ddff"
tn_blue6 = "#b4f9f8"
tn_blue7 = "#394b70"
tn_border = "#15161e"
tn_border_highlight = "#27a1b9"
tn_comment = "#565f89"
tn_cyan = "#7dcfff"
tn_dark3 = "#545c7e"
tn_dark5 = "#737aa2"
tn_error = "#db4b4b"
tn_fg = "#c0caf5"
tn_fg_dark = "#a9b1d6"
tn_fg_float = "#c0caf5"
tn_fg_gutter = "#3b4261"
tn_fg_sidebar = "#a9b1d6"
tn_green = "#9ece6a"
tn_green1 = "#73daca"
tn_green2 = "#41a6b5"
tn_hint = "#1abc9c"
tn_info = "#0db9d7"
tn_magenta = "#bb9af7"
tn_magenta2 = "#ff007c"
tn_none = "NONE"
tn_orange = "#ff9e64"
tn_purple = "#9d7cd8"
tn_red = "#f7768e"
tn_red1 = "#db4b4b"
tn_teal = "#1abc9c"
tn_terminal_black = "#414868"
tn_warning = "#e0af68"
tn_yellow = "#e0af68"

tokyonight = CustomColors { xmbActiveScreen = tn_green1
                          , xmbVisScreen = tn_green2
                          , xmbHidden = tn_comment
                          , xmbLayout = tn_info
                          , xmbTitle = tn_hint
                          , xmbBg = tn_bg
                          , xmbFg = tn_comment
                          , borderFocused = tn_border_highlight
                          , borderNormal  = tn_border
                          , borderDarker = tn_black
                          , promptBorder = tn_magenta
                          , promptBorder2 = tn_magenta2
                          , promptBG = tn_bg_float
                          , promptFG = tn_fg_float
                          , promptHLFG = tn_bg_float
                          , promptHLBG = tn_bg_visual
                          , urgent = tn_info
                          , urgentBorder = tn_info
                          , focusedText = tn_black
                          , unfocusedText = tn_cyan
                          , monitorHigh = tn_red
                          , monitorLow = tn_green
                          , monitorNormal = tn_warning
                          , xmoSep = " <fc=" ++ tn_purple ++ ">⠶</fc> " -- :: ⠛ ⣿
                          }
