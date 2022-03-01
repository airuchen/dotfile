module XMonad.CustomColors
  (
    CustomColors (..),
    solarizedish,
    gruvboxish
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
                                 }

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
                          }
