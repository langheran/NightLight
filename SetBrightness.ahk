; GLOBAL SETTINGS ===============================================================================================================

#Warn
#NoEnv
#SingleInstance Force
#Include BrightnessSetter.ahk

bobj := new BrightnessSetter
bobj.SetBrightness(150, 1, 0) 

args:=""
Loop, %0%  ; For each parameter:
{
    param := %A_Index%
	num = %A_Index%
	args := args . param
}
if(args<>"")
{
    BAll:=args
    if BAll is number
    {
        Brightness.Set(BAll, BAll, BAll)
        ExitApp
    }
}

SetBatchLines -1

global Reset     := 128
global LoadRed   := Brightness.Get().Red
global LoadGreen := Brightness.Get().Green
global LoadBlue  := Brightness.Get().Blue
global LoadAll   := ((LoadRed = LoadGreen) && (LoadRed = LoadBlue) && (LoadGreen = LoadBlue)) ? LoadRed : " - "

; GUI ===========================================================================================================================

Gui, Margin, 5, 5
Gui, Font, s16 w800 q4 c76B900, MS Shell Dlg 2
Gui, Add, Text, xm ym w240 0x0201, % "Display Brightness"


Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, GroupBox, xm y+15 w240 h110, % "Change Brightness (RGB)"

Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, Text, xp+10 yp+25 w70 h22 0x0200, % "Red"
Gui, Add, Edit, x+1 yp w80 h22 0x2002 Limit3 hwndhEdit1 vBRed
Gui, Add, UpDown, Range0-255, % LoadRed
Gui, Font, s9 w400 q1 csilver, MS Shell Dlg 2
Gui, Add, Text, x+5 yp w65 h22 0x0200, % "(0 - 255)"

Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, Text, xs+10 y+4 w70 h22 0x0200, % "Green"
Gui, Add, Edit, x+1 yp w80 h22 0x2002 Limit3 hwndhEdit2 vBGreen
Gui, Add, UpDown, Range0-255, % LoadGreen
Gui, Font, s9 w400 q1 csilver, MS Shell Dlg 2
Gui, Add, Text, x+5 yp w65 h22 0x0200, % "(0 - 255)"

Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, Text, xs+10 y+4 w70 h22 0x0200, % "Blue"
Gui, Add, Edit, x+1 yp w80 h22 0x2002 Limit3 hwndhEdit3 vBBlue
Gui, Add, UpDown, Range0-255, % LoadBlue
Gui, Font, s9 w400 q1 csilver, MS Shell Dlg 2
Gui, Add, Text, x+5 yp w65 h22 0x0200, % "(0 - 255)"


Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, GroupBox, xm y+15 w240 h60, % "Change Brightness (ALL)"

Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, Text, xp+10 yp+25 w70 h22 0x0200, % "All"
Gui, Add, Edit, x+1 yp w80 h22 0x2002 Limit3 hwndhEdit4 vBAll
Gui, Add, UpDown, Range0-255, % LoadAll
Gui, Font, s9 w400 q1 csilver, MS Shell Dlg 2
Gui, Add, Text, x+5 yp w65 h22 0x0200, % "(0 - 255)"


Gui, Add, Button, xm+20 y+20 w70 gSetRGBSettings, % "Set RGB"
Gui, Add, Button, x+5 yp w70 gSetALLSettings, % "Set ALL"
Gui, Add, Button, x+5 yp w70 gResetSettings, % "Reset"

Gui, Show, AutoSize
return

; SCRIPT ========================================================================================================================

SetRGBSettings:
    Gui, Submit, NoHide
    Brightness.Set(BRed, BGreen, BBlue)
    GuiControl,, BAll,   % (BRed = BGreen) && (BRed = BBlue) && (BGreen = BBlue) ? BRed : " - "
return

SetALLSettings:
    Gui, Submit, NoHide
    if BAll is digit
    {
        Brightness.Set(BAll, BAll, BAll)
        GuiControl,, BRed,   % BAll
        GuiControl,, BGreen, % BAll
        GuiControl,, BBlue,  % BAll
    }
    else
        MsgBox % BAll " is no digit"
return

ResetSettings:
    Brightness.Set(Reset, Reset, Reset)
    GuiControl,, BRed,   % Reset
    GuiControl,, BGreen, % Reset
    GuiControl,, BBlue,  % Reset
    GuiControl,, BAll,   % Reset
return

; EXIT ==========================================================================================================================

GuiClose:
GuiEscape:
ExitApp

; FUNCTIONS =====================================================================================================================

Class Brightness
{
    Get()                                                                         ; http://msdn.com/library/dd316946(vs.85,en-us)
    {
        VarSetCapacity(buf, 1536, 0)
        DllCall("gdi32.dll\GetDeviceGammaRamp", "Ptr", hDC := DllCall("user32.dll\GetDC", "Ptr", 0, "Ptr"), "Ptr", &buf)
        CLR := {}
        CLR.Red   := NumGet(buf,        2, "UShort") - 128
        CLR.Green := NumGet(buf,  512 + 2, "UShort") - 128
        CLR.Blue  := NumGet(buf, 1024 + 2, "UShort") - 128
        return CLR, DllCall("user32.dll\ReleaseDC", "Ptr", 0, "Ptr", hDC)
    }

    Set(ByRef red := 128, ByRef green := 128, ByRef blue := 128)                  ; http://msdn.com/library/dd372194(vs.85,en-us)
    {
        loop % VarSetCapacity(buf, 1536, 0) / 6
        {
            NumPut((r := (red   + 128) * (A_Index - 1)) > 65535 ? 65535 : r, buf,        2 * (A_Index - 1), "UShort")
            NumPut((g := (green + 128) * (A_Index - 1)) > 65535 ? 65535 : g, buf,  512 + 2 * (A_Index - 1), "UShort")
            NumPut((b := (blue  + 128) * (A_Index - 1)) > 65535 ? 65535 : b, buf, 1024 + 2 * (A_Index - 1), "UShort")
        }
        ret := DllCall("gdi32.dll\SetDeviceGammaRamp", "Ptr", hDC := DllCall("user32.dll\GetDC", "Ptr", 0, "Ptr"), "Ptr", &buf)
        return ret, DllCall("user32.dll\ReleaseDC", "Ptr", 0, "Ptr", hDC)
    }
}

; ===============================================================================================================================