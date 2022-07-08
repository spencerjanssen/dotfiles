import XMonad hiding (Tall(..))
import qualified XMonad.StackSet as W
import XMonad.Actions.CopyWindow
import XMonad.Layout.Tabbed
import XMonad.Layout.HintedTile
import XMonad.Layout.NoBorders
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.EwmhDesktops
import XMonad.Prompt
import XMonad.Actions.SpawnOn
import XMonad.Util.SpawnOnce

import XMonad.Layout.LayoutScreens
import XMonad.Layout.TwoPane

import Data.List (isPrefixOf)

import qualified Data.Map as M
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioRaiseVolume, xF86XK_AudioMute)

main = xmonad . docks . ewmh $ defaultConfig
    { terminal = "gnome-terminal"
    , workspaces = ["irc", "web"] ++ map show [3 .. 8 :: Int] ++ ["tv"]
    , mouseBindings = \(XConfig {modMask = modm}) -> M.fromList $
            [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w))
            , ((modm, button2), (\w -> focus w >> windows W.swapMaster))
            , ((modm.|. shiftMask, button1), (\w -> focus w >> mouseResizeWindow w)) ]
    , keys = \c -> mykeys c `M.union` keys defaultConfig c
    , layoutHook = modifiers layouts
    , manageHook = manageHook defaultConfig
                <+> manageSpawn
                <+> (isFullscreen --> doFullFloat)
                <+> (className =? "Kodi" --> doShift "tv")
                -- float chrome extension windows, mainly for hangouts popups
                <+> (isPrefixOf "crx_" <$> appName --> doFloat)
    }
 where
    tiled     = HintedTile 1 0.03 0.5 TopLeft
    layouts   = (tiled Tall ||| (tiled Wide ||| Full)) ||| tabbed shrinkText myTheme
    modifiers = avoidStruts . smartBorders

    mykeys (XConfig {modMask = modm}) = M.fromList $
        [((modm,               xK_p     ), shellPromptHere myPromptConfig)
        ,((modm .|. shiftMask, xK_Return), spawnHere =<< asks (terminal . config))
        ,((modm .|. shiftMask, xK_c     ), kill1)
        ,((modm .|. shiftMask .|. controlMask, xK_c     ), kill)
        ,((modm .|. shiftMask, xK_0     ), windows $ copyToAll)
        ,((modm,               xK_z     ), layoutScreens 2 $ TwoPane 0.5 0.5)
        ,((modm .|. shiftMask, xK_z     ), rescreen)
        ,((modm,               xK_b     ), sendMessage ToggleStruts)
        ,((modm .|. shiftMask, xK_l     ), spawn "systemctl suspend")
        ,((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game -5%")
        ,((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game +5%")
        ,((0, xF86XK_AudioMute), spawn "pactl set-sink-mute alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game toggle")
        ]

    myFont = "xft:Bitstream Vera Sans Mono:pixelsize=10"
    myTheme = def { fontName = myFont }
    myPromptConfig = def
                        { position = Top
                        , font = myFont
                        , showCompletionOnTab = True
                        , historyFilter = deleteConsecutive
                        , promptBorderWidth = 0 }
