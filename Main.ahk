#Persistent
#SingleInstance force

; === Variables ===
global toggle := false
global interval := 100




; === SCHEDULED TASKS DEFINITION ===
; Format: [interval_minutes, function_name, description]
scheduledTasks := []
scheduledTasks[1] := [5, "buySeeds", "Buy Seeds every 5 minutes"]
scheduledTasks[2] := [5, "buyGears", "Buy Gears every 5 minutes"]
scheduledTasks[3] := [30, "buyEggs", "Buy Eggs every 30 minutes"]

; === QUEUE SYSTEM ===
taskQueue := []  ; Queue to hold functions that need to run
seedItems := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Orange Tulip"
    , "Tomato Seed", "Daffodil Seed", "Watermelon Seed"
    , "Pumpkin Seed", "Apple Seed", "Bamboo Seed", "Coconut Seed"
    , "Cactus Seed", "Dragon Fruit Seed", "Mango Seed", "Grape Seed"
    , "Mushroom Seed", "Pepper Seed", "Cacao Seed", "Beanstalk Seed", "Ember Lily", "Sugar Apple", "Burning Bud"]
; seedItems := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed"
;     , "Tomato Seed", "Cauliflower Seed", "Watermelon seed"
;     , "Green Apple Seed", "Avocado Seed", "Banana Seed", "Pineapple Seed"
;     , "Kiwi Seed", "Bell Pepper Seed", "Prickly Pear Seed", "Loquat Seed"
;     , "Feijoa Seed", "Sugar Apple Seed"]

; gearItems := ["Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler"
;              , "Godly Sprinkler", "Lightning Rod", "Master Sprinkler", "Favorite Tool", "Harvest Tool", "Friendship Pot"]
gearItems := ["Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler"
    , "Godly Sprinkler", "Magnifying Glass","Tanning Mirror","Master Sprinkler","Cleaning Spray", "Favorite Tool", "Harvest Tool", "Friendship Pot"]

eggItems := ["Common Egg", "Uncommon Egg", "Rare Egg", "Legendary Egg", "Mythical Egg"
    , "Bug Egg"]
; Get res for automatic scaling
SysGet, ScreenWidth, 16
SysGet, ScreenHeight, 17

; Calculate GUI size based on screen resolution
guiWidth := Round(ScreenWidth * 0.35)
guiHeight := Round(ScreenHeight * 0.45)

; Ensure minimum size
if (guiWidth < 300)
    guiWidth := 300
if (guiHeight < 200)
    guiHeight := 200

Gui, Add, Tab, vTabName w%guiWidth% h%guiHeight%, Seeds|Gears|Eggs|Auto Honey|Settings
Gui, Font, s10, Segoe UI

; Scale accordingly to screen size, all customisable
textX := Round(guiWidth * 0.05)
textY := Round(guiHeight * 0.10)
editX := Round(guiWidth * 0.4)
editY := Round(guiHeight * 0.15)
editWidth := Round(guiWidth * 0.25)
buttonWidth := Round(guiWidth * 0.15)
buttonHeight := Round(guiHeight * 0.10)
statusY := Round(guiHeight * 0.6)

; SEEDS
Gui, Tab, Seeds
Gui, Add, Text, x%textX% y%textY%, Select Seeds:

createCheckboxLayout(seedItems, "Seed")
buttonY := guiHeight - 80  ; 80 pixels from the bottom

Gui, Add, Button, gStartFunction x%textX% y%buttonY% w%buttonWidth% h%buttonHeight%, Start (f1)
Gui, Add, Button, gStopFunction x%editX% y%buttonY% w%buttonWidth% h%buttonHeight%, Stop (f3)

; GEARS
Gui, Tab, Gears
Gui, Add, Text, x%textX% y%textY%, Select Gears:
createCheckboxLayout(gearItems, "Gear")

; EGGS
Gui, Tab, Eggs
Gui, Add, Text, x%textX% y%textY%, Select Eggs:
createCheckboxLayout(eggItems, "Egg")

; AUTO HONEY
Gui, Tab, Auto Honey
Gui, Add, Text, x%textX% y%textY%, Auto Honey:

; Gui, Add, Button, gStartAutoHoney x%textX% y%buttonY% w%buttonWidth% h%buttonHeight%, Start (f4)

; SETTINGS
Gui, Tab, Settings
Gui, Add, Text, x%textX% y%textY%, Settings:

Gui, Add, Button, gSaveSettings x%textX% y%buttonY% w%buttonWidth% h%buttonHeight%, Save Settings

Gui, Add, Button, gResetSettings x%editX% y%buttonY% w%buttonWidth% h%buttonHeight%, Reset Settings

; Add controls outside of tabs (buttons and status)
Gui, Tab

; Add live clock display
clockY := guiHeight - 120
Gui, Add, Text, vClockDisplay x%textX% y%clockY% w%guiWidth%, Loading...

Gui, Show, w%guiWidth% h%guiHeight%, Grow a Garden Bot

; Load settings if they exist
if (FileExist("settings.ini")) {
    LoadSettings()
}

; Start the clock timer
SetTimer, UpdateClock, 1000
UpdateClock()  ; Initial call to display clock immediately

return

; === Hotkeys ===
F1::


    SaveSettings()

    startFunction()
return

F3::
    Reload
return

; === Functions ===
findColour(x, y){
    CoordMode, Pixel, Screen
    PixelGetColor, colour, x, y
    return colour
}

HideTooltip:
    ToolTip
return

hotbarControl(action, key) {
    if (action = "select") {
        Send, {%key%}
    }
    else if (action = "unselect") {
        Send, {%key%}
        Sleep, 200
        Send, {%key%}
    }
    else if (action = "toggle") {
        Send, {%key%}
    }
}

createCheckboxLayout(itemArray, prefix) {

    global
    ;Column positions (for column 1 and column 2)
    column1X := textX
    column2X := textX + (guiWidth * 0.5)
    maxCheckboxesPerColumn := 12

    Loop, % itemArray.MaxIndex()
    {

        if (A_Index <= maxCheckboxesPerColumn) {
            ; First column
            checkboxX := column1X
            checkboxY := textY + 25 + (A_Index - 1) * 20
        } else {
            ; Second column
            checkboxX := column2X
            checkboxY := textY + 25 + (A_Index - maxCheckboxesPerColumn - 1) * 20
        }

        varName := prefix . A_Index
        Gui, Add, Checkbox, v%varName% x%checkboxX% y%checkboxY%, % itemArray[A_Index]
    }
}

sendKeybind(keybind, delay := 250){
    if (keybind = "\") {
        Send, \
    }
    else if (keybind = "`") {
        Send, ``
    }
    else {
        Send, {%keybind%}
    }
    Sleep, %delay%
}

holdKeybind(key, duration) {
    Send, {%key% down}
    Sleep, %duration%
    Send, {%key% up}
}

changeCameraMode(){
    sendKeybind("esc")
    sendKeybind("Tab")
    sendKeybind("Down")
    sendKeybind("Right")
    sendKeybind("Right")
    sendKeybind("esc")
}

rotateShops(){
    sendKeybind("Right", 50)
    sendKeybind("Right", 50)
    sendKeybind("Enter ", 100)
    sendKeybind("Left", 50)
    sendKeybind("Left", 50)
    sendKeybind("Enter",100)
}
setupPosition(){
    changeCameraMode()

    Sleep, 500
    ; Get screen center coordinates
    centerX := A_ScreenWidth // 2
    centerY := A_ScreenHeight // 2

    ;Face down
    MouseMove, centerX, centerY
    Click, Right, Down
    MouseMove, centerX, centerY + 200, 10
    Click, Right, Up

    ; After facing down, zoom out and in to adjust FOV
    Sleep, 300
    resetCamera()
    Sleep, 800

    ; Perform the shop tp to adjust facing position

    sendKeybind("\")
    sendKeybind("Right", 200)
    sendKeybind("Right", 200)
    sendKeybind("Right", 200)
    sendKeybind("Enter", 200)
    ; enter the loop
    Sleep, 500
    ; Loop rotateShops 4 times
    Loop, 4 {
        rotateShops()
    }

    resetUINav()
    ; now bring back the camera mode to default
    changeCameraMode()
}
resetSelectedPosition(){
    Loop, 30
    {
        sendKeybind("Down", 30)
    }
    Loop, 40
    {
        sendKeybind("Up", 30)
    }
    sendKeybind("Down")
    sendKeybind("Down")

    sendKeybind("Enter",100)
    sendKeybind("Enter",100)

    Sleep, 200  ; Wait for screen to update

    buttonColours := ["0x1DB31D", "0x26EE26"]
    if (checkMultipleColours(buttonColours, 700, 610, 25)) {
        sendKeybind("Enter")
    }
}
resetCamera(){
    Sleep, 300

    ; Zoom in for 2 seconds, then zoom out slightly
    holdKeybind("i", 2000)
    Sleep, 100
    holdKeybind("o", 250)

    Sleep, 500
}

/*
Reset the default UI Nav position (where it is off)
*/
resetUINav(){
    Sleep, 300
    sendKeybind("\")
    sendKeybind("\")

    Sleep, 500

    ; Click at center of screen
    centerX := A_ScreenWidth // 2
    centerY := A_ScreenHeight // 2
    Click, %centerX%, %centerY%
}
returnToGarden(){
    resetUINav()
    sendKeybind("\")
    Loop, 4{
        sendKeybind("Right")
    }
    sendKeybind("Enter")
    resetUINav()
}

selectItemFromInventory(itemName, hotbarPosition)
{   sendKeybind("\")
    sendKeybind("`")
    sendKeybind("Down")
    sendKeybind("Down")
    sendKeybind("Down")
    sendKeybind("Enter")

    Loop, 20{
        sendKeybind("Backspace", 50)
    }

    ; Send each character of the itemName
    Loop, Parse, itemName
    {
        sendKeybind(A_LoopField, 50)
    }

    sendKeybind("Enter")
    Sleep, 500
    sendKeybind("Left")
    sendKeybind("Left")
    sendKeybind("Left")
    ;Select item
    sendKeybind("Right")
    sendKeybind("Right")
    sendKeybind("Enter")

    ; move to the 'shop button to align position, then move down'
    sendKeybind("Left")
    sendKeybind("Left")
    sendKeybind("Left")
    Loop, 6 {
        sendKeybind("Down")
    }
    ;Place item according to hotbar position
    ; We're at position 1, so move (hotbarPosition - 1) times
    Loop, % hotbarPosition - 1
    {
        sendKeybind("Right")
    }
    sendKeybind("Enter")
    sendKeybind("`")
    resetUINav()
}
buyItem(){
    sendKeybind("Enter")
    sendKeybind("Down")
    Loop, 20
    {
        sendKeybind("Enter", 30)
    }
    sendKeybind("Down")
}

skipItem(){

    sendKeybind("Down")
}

; SEEDS
buySeeds(){
    global
    sendKeybind("\")
    sendKeybind("Right")
    sendKeybind("Right")
    sendKeybind("Right")
    sendKeybind("Enter")
    Sleep, 500

    sendKeybind("e", 3000)

    resetSelectedPosition()

    Loop, % seedItems.MaxIndex()
    {
        ; Variable name is Seed1, Seed2, Seed3, corresponding to the checkboxes
        varName := "Seed" . A_Index
        if (%varName%) {

            buyItem()

        } else {
            skipItem()

        }
    }

    Loop, 35
    {
        sendKeybind("Up", 50)
    }

    ; Go down to carrot to reset, then exit menu
    sendKeybind("Down")
    sendKeybind("Down")
    sendKeybind("Enter")
    sendKeybind("Enter")
    sendKeybind("Up")
    sendKeybind("Enter")

}

buyGears(){

    global
    
    Sleep, 500
    hotbarControl("select", "2")

    Click, Left, Down
    Click, Left, Up

    Sleep, 500

    sendKeybind("E", 2000)

    Click, 1640, 425
    Click, 1780, 430

    Sleep, 2500
    sendKeybind("\")
    resetSelectedPosition()

    Loop, % gearItems.MaxIndex()
    {

        varName := "Gear" . A_Index
        ToolTip, %varName%
        if (%varName%) {

            buyItem()

        } else {
            skipItem()

        }
    }

    Loop, 35
    {
        sendKeybind("Up", 50)
    }

    sendKeybind("Down")
    sendKeybind("Down")
    sendKeybind("Enter")
    sendKeybind("Enter")
    sendKeybind("Up")
    sendKeybind("Enter")

}

buyEggs(){
    global

    Sleep, 500
    hotbarControl("select", "2")

    Click, Left, Down
    Click, Left, Up

    Sleep, 500

    ; Define the movement pattern
    holdTimes := [870, 200, 200]
    waitTimes := [500, 500, 500]

    ; Execute each movement pattern
    Loop, 3 {
        currentIndex := A_Index
        ; Hold S for specified time
        Send, {S down}
        Sleep, holdTimes[currentIndex]
        Send, {S up}
        Sleep, waitTimes[currentIndex]

        ; Navigate to shop and buy
        navigateAndBuyEgg()
    }
    Sleep, 500
    sendKeybind("\")
}

navigateAndBuyEgg() {
    sendKeybind("e")
    sendKeybind("\")
    Loop, 4 {
        sendKeybind("Right")
    }
    sendKeybind("Down")
    sendKeybind("Enter")
    sendKeybind("\")
}

; Add functions to queue based on scheduled times
addToQueue() {
    global scheduledTasks, taskQueue
    
    ; Loop through each scheduled task
    for index, task in scheduledTasks {
        intervalMinutes := task[1]
        functionName := task[2]
        description := task[3]
        
        ; Check if this function should be added to queue now
        if (shouldRunFunction(functionName, intervalMinutes)) {
            ; Add to queue
            taskQueue.Push([functionName, description])
            ToolTip, Added %description% to queue at %A_Hour%:%A_Min%:%A_Sec%
            SetTimer, HideTooltip, -2000
        }
    }
}

; Process the task queue
processQueue() {
    global taskQueue, isScriptRunning
    
    ; Don't run if script is still in setup phase
    if (isScriptRunning) {
        return
    }
    
    ; Process all tasks in queue
    while (taskQueue.Length() > 0) {
        ; Get next task from queue
        task := taskQueue.RemoveAt(1)
        functionName := task[1]
        description := task[2]
        
        ToolTip, Running %description% at %A_Hour%:%A_Min%:%A_Sec%
        SetTimer, HideTooltip, -2000
        
        ; Execute the function
        %functionName%()
        
        ; Return to garden after each function
        returnToGarden()
    }
}



startFunction() {
    Gui, Submit, NoHide
    ; ================================================
    ; INITIALISING SETTINGS
    ; ================================================
    global isScriptRunning
    isScriptRunning := true

    resetUINav()
    Sleep, 500

    setupPosition()
    returnToGarden()

    ; ================================================
    ; INVENTORY WRENCH SELECTION
    ; ================================================
    selectItemFromInventory("wrench",2)
    Sleep, 1000

    ; ================================================
    ; INITIAL SETUP COMPLETE - START SCHEDULING
    ; ================================================
    isScriptRunning := false
    
    ; Start the queue system timers
    SetTimer, addToQueue, 60000  ; Check every minute to add tasks to queue
    SetTimer, processQueue, 5000  ; Process queue every 5 seconds
    
    ToolTip, Initial setup complete. Scheduling started at %A_Hour%:%A_Min%:%A_Sec%
    SetTimer, HideTooltip, -3000
}

stopFunction() {
    GuiControl,, Status, Status: Stopped
}

SaveSettings() {
    global seedItems, gearItems, eggItems
    Gui, Submit, NoHide

    ; Save seed checkboxes
    Loop, % seedItems.MaxIndex()
    {
        varName := "Seed" . A_Index
        IniWrite, % %varName%, settings.ini, Seeds, %varName%
    }

    ; Save gear checkboxes
    Loop, % gearItems.MaxIndex()
    {
        varName := "Gear" . A_Index
        IniWrite, % %varName%, settings.ini, Gears, %varName%
    }

    ; Save egg checkboxes
    Loop, % eggItems.MaxIndex()
    {
        varName := "Egg" . A_Index
        IniWrite, % %varName%, settings.ini, Eggs, %varName%
    }

}

LoadSettings() {
    global seedItems, gearItems, eggItems
    Loop, % seedItems.MaxIndex()
    {
        varName := "Seed" . A_Index
        IniRead, value, settings.ini, Seeds, %varName%, 0
        GuiControl,, %varName%, %value%
    }

    Loop, % gearItems.MaxIndex()
    {
        varName := "Gear" . A_Index
        IniRead, value, settings.ini, Gears, %varName%, 0
        GuiControl,, %varName%, %value%
    }

    Loop, % eggItems.MaxIndex()
    {
        varName := "Egg" . A_Index
        IniRead, value, settings.ini, Eggs, %varName%, 0
        GuiControl,, %varName%, %value%
    }

}

ResetSettings(){
    global seedItems, gearItems, eggItems
    ; Reset all checkboxes to unchecked
    Loop, % seedItems.MaxIndex()
    {
        varName := "Seed" . A_Index
        GuiControl,, %varName%, 0
    }

    Loop, % gearItems.MaxIndex()
    {
        varName := "Gear" . A_Index
        GuiControl,, %varName%, 0
    }

    Loop, % eggItems.MaxIndex()
    {
        varName := "Egg" . A_Index
        GuiControl,, %varName%, 0
    }
    MsgBox, Settings reset
    SaveSettings()
}
; === Handle close ===
GuiClose:
    SaveSettings()
ExitApp

checkMultipleColours(colourList, x, y, tolerance := 10) {

    CoordMode, Pixel, Screen
    PixelGetColor, detectedColour, x, y

    for i, targetColour in colourList {
        targetColourNum := targetColour
        detectedColourNum := detectedColour

        if (Abs(targetColourNum - detectedColourNum) <= tolerance) {
            return true
        }
    }

    return false
}

UpdateClock() {
    ;Display the current time
    currentTime := A_Hour . ":" . A_Min . ":" . A_Sec
    GuiControl,, ClockDisplay, %currentTime%
}

; === SCHEDULING LOGIC ===

; Check if a function should run based on clock time intervals
shouldRunFunction(functionName, intervalMinutes) {
    ; Check if current minute is divisible by the interval
    if (Mod(A_Min, intervalMinutes) = 0) {
        return true
    }
    
    return false
}



