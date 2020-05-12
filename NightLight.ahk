#Persistent
#SingleInstance, Force
#Include Class_Monitor.ahk

Menu, Tray, NoStandard
Menu, Tray, Add, LCD White (6600), DayLight6600
Menu, Tray, Add, Daylight`, overcast (6500), DayLight6500
Menu, Tray, Add, Sunlight (5900), Sunlight5900
Menu, Tray, Add, Horizon daylight (5000), HorizonDaylight5000
Menu, Tray, Add, Moonlight (4100), Moonlight4100
Menu, Tray, Add, Cool Incandescent (3300), CoolIncandescent3300
Menu, Tray, Add, Incandescent Light Bulb (2700), IncandescentLightBulb2700
Menu, Tray, Add, &Exit, ExitApplication

GoSub, ReadTemperature
GoSub, SetTemperature
SetTimer, Watch, 1000
return

Class SessionChange
{
    static hScript := A_ScriptHwnd
    static WTSSESSION_CHANGE := ObjBindMethod(SessionChange, "WM_WTSSESSION_CHANGE")

    __New()
    {
        if !(DllCall("wtsapi32\WTSRegisterSessionNotificationEx", "ptr", 0, "ptr", this.hScript, "uint", 1))
            throw Exception("Error in WTSRegisterSessionNotificationEx function")
        OnMessage(0x02B1, this.WTSSESSION_CHANGE)
    }

    WM_WTSSESSION_CHANGE(wParam)
    {
        if (wParam = 0x5) || (wParam = 0x8)
            MonitorControl.SetBrightness(MonRed, MonGreen, MonBlue)
    }

    __Delete()
    {
        OnMessage(0x02B1, "")
        if !(DllCall("wtsapi32\WTSUnRegisterSessionNotificationEx", "ptr", 0, "ptr", this.hScript))
            throw Exception("Error in WTSUnRegisterSessionNotificationEx function")
    }
}

ReadTemperature:
IniRead, Temperature, %A_ScriptDir%\NightLight.ini, Settings, Temperature, 6600
return

SetTemperature:
MonitorControl.SetColorTemperature(Temperature, 0.5)
RegWrite, REG_BINARY, HKCU\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\$$windows.data.bluelightreduction.bluelightreductionstate\Current, Data, 02000000079B967A7C49D50100000000434201001000D00A02C614E1BAD9D4C7AFD2EA0100
CLR := MonitorControl.GetBrightness()
global MonRed := CLR.Red
global MonGreen := CLR.Green
global MonBlue := CLR.Blue
IniWrite, %Temperature%, %A_ScriptDir%\NightLight.ini, Settings, Temperature
return

Watch:
CLR := MonitorControl.GetBrightness()
if(CLR.Red!=MonRed || CLR.Blue!=MonBlue || CLR.Green!=MonGreen)
{
    GoSub, SetTemperature
}
return

ExitApplication:
ExitApp
return

DayLight6600:
Temperature:=6600
GoSub, SetTemperature
return
DayLight6500:
Temperature:=6500
GoSub, SetTemperature
return
Sunlight5900:
Temperature:=5900
GoSub, SetTemperature
return
HorizonDaylight5000:
Temperature:=5000
GoSub, SetTemperature
return
Moonlight4100:
Temperature:=4100
GoSub, SetTemperature
return
CoolIncandescent3300:
Temperature:=3300
GoSub, SetTemperature
return
IncandescentLightBulb2700:
Temperature:=2700
GoSub, SetTemperature
return

