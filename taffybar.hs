{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-deprecations #-}

import Control.Monad.IO.Class (liftIO)
import System.Taffybar
import System.Taffybar.SimpleConfig

import System.Taffybar.Widget

import System.Taffybar.Widget.Generic.PollingBar
import System.Taffybar.Widget.Generic.PollingGraph
import System.Taffybar.Widget.SNITray

import System.Taffybar.Information.CPU
import System.Posix.Process (forkProcess)

cpuCallback = do
  (userLoad, systemLoad, totalLoad) <- cpuLoad
  return [totalLoad, systemLoad]


main = do
    let cpuCfg = defaultGraphConfig { graphDataColors = [ (0, 1, 0, 1)
                                                      , (1, 0, 1, 0.5)
                                                      ]
                                  , graphLabel = Just "cpu"
                                  }
        clock = textClockNew Nothing "<span fgcolor='orange'>%a %b %_d %H:%M</span>" 1
        note = notifyAreaNew defaultNotificationConfig
        wea = liftIO $ weatherNew (defaultWeatherConfig "KLNK") 10
        cpu = pollingGraphNew cpuCfg 0.5 cpuCallback
        conf = defaultSimpleTaffyConfig
                    { startWidgets = [ workspacesNew defaultWorkspacesConfig, note ]
                    , endWidgets = [ sniTrayNew, wea, clock, cpu]
                    , barHeight = 20
                    , monitorsAction = useAllMonitors }
    dyreTaffybar $ toTaffyConfig conf