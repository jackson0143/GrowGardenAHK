#Persistent
#SingleInstance force

; === Variables ===
global toggle := false
global interval := 100

; Get res for automatic scaling
SysGet, ScreenWidth, 16
SysGet, ScreenHeight, 17

; Calculate GUI size based on screen resolution
guiWidth := Round(ScreenWidth * 0.25)
guiHeight := Round(ScreenHeight * 0.30)

; Ensure minimum size
if (guiWidth < 300)
    guiWidth := 300
if (guiHeight < 200)
    guiHeight := 200


Gui, Add, Tab, vTabName w%guiWidth% h%guiHeight%, Seeds|Gears|Eggs|Honey Event
Gui, Font, s10, Segoe UI 

; Scale accordingly to screen size, all customisable
textX := Round(guiWidth * 0.05)
textY := Round(guiHeight * 0.15)
editX := Round(guiWidth * 0.4)
editY := Round(guiHeight * 0.15)
editWidth := Round(guiWidth * 0.25)
buttonY := Round(guiHeight * 0.35)
buttonWidth := Round(guiWidth * 0.15)
buttonHeight := Round(guiHeight * 0.15)
statusY := Round(guiHeight * 0.6)

Gui, Add, Text, x%textX% y%textY%, Click Interval (ms):
Gui, Add, Edit, vInterval x%editX% y%editY% w%editWidth%, 100

Gui, Add, Button, gStart x%textX% y%buttonY% w%buttonWidth% h%buttonHeight%, Start (f1)
Gui, Add, Button, gStop x%editX% y%buttonY% w%buttonWidth% h%buttonHeight%, Stop (f3)

Gui, Add, Text, vStatus x%textX% y%statusY%, Status: Stopped

Gui, Show, w%guiWidth% h%guiHeight%, Grow a Garden Bot
return

; === Hotkeys ===
F1::
Gosub, Start
return

F3::
Reload
return

; === Start Button ===
Start:
Gui, Submit, NoHide
global interval := Interval
global toggle := true
SetTimer, ClickLoop, %interval%
GuiControl,, Status, Status: Running
return

; === Stop Button ===
Stop:
global toggle := false
SetTimer, ClickLoop, Off
GuiControl,, Status, Status: Stopped
return

; === Click loop ===
ClickLoop:
if (toggle) {
    Click
}
return

; === Handle close ===
GuiClose:
ExitApp