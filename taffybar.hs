import System.Taffybar

import System.Taffybar.Systray
import System.Taffybar.TaffyPager
import System.Taffybar.Pager
import System.Taffybar.SimpleClock
import System.Taffybar.FreedesktopNotifications
import System.Taffybar.Weather
import System.Taffybar.NetMonitor

import System.Taffybar.Widgets.PollingBar
import System.Taffybar.Widgets.PollingGraph

import System.Information.CPU
import System.Posix.Process (forkProcess)

cpuCallback = do
  (userLoad, systemLoad, totalLoad) <- cpuLoad
  return [totalLoad, systemLoad]

pagerConf = defaultPagerConfig
    { emptyWorkspace = const ""
    , activeWorkspace = colorize "black" "white" . wrap " " " "
    , hiddenWorkspace = wrap " " " "
    , visibleWorkspace = colorize "black" "gray" . wrap " " " "
    , activeWindow = escape . shorten 120
    , widgetSep = "   "
    }

main = do
    let cpuCfg = defaultGraphConfig { graphDataColors = [ (0, 1, 0, 1)
                                                      , (1, 0, 1, 0.5)
                                                      ]
                                  , graphLabel = Just "cpu"
                                  }
        clock = textClockNew Nothing "<span fgcolor='orange'>%a %b %_d %H:%M</span>" 1
        pager = taffyPagerNew pagerConf
        note = notifyAreaNew defaultNotificationConfig
        wea = weatherNew (defaultWeatherConfig "KLNK") 10
        cpu = pollingGraphNew cpuCfg 0.5 cpuCallback
        tray = systrayNew
        conf n extra = defaultTaffybarConfig
                    { startWidgets = [ pager, note ]
                    , endWidgets = extra ++ [ wea, clock, netMonitorNew 2 "enp2s0", cpu]
                    , barHeight = 20
                    , monitorNumber = n }
    forkProcess $ defaultTaffybar $ conf 0 []
    defaultTaffybar $ conf 1 [tray]
