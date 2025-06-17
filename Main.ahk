#Persistent
#SingleInstance force

; === Variables ===
global toggle := false
global interval := 100
seedItems := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Orange Tulip"
             , "Tomato Seed", "Corn Seed", "Daffodil Seed", "Watermelon Seed"
             , "Pumpkin Seed", "Apple Seed", "Bamboo Seed", "Coconut Seed"
             , "Cactus Seed", "Dragon Fruit Seed", "Mango Seed", "Grape Seed"
             , "Mushroom Seed", "Pepper Seed", "Cacao Seed", "Beanstalk Seed", "Ember Lily", "Sugar Apple"] 

             

gearItems := ["Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler"
             , "Godly Sprinkler", "Lightning Rod", "Master Sprinkler", "Favorite Tool", "Harvest Tool", "Friendship Pot"]

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

Gui, Add, Tab, vTabName w%guiWidth% h%guiHeight%, Seeds|Gears|Eggs|Settings
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

; SETTINGS
Gui, Tab, Settings
Gui, Add, Text, x%textX% y%textY%, Settings:


; Add controls outside of tabs (buttons and status)
Gui, Tab



Gui, Show, w%guiWidth% h%guiHeight%, Grow a Garden Bot
return

; === Hotkeys ===
F1::
startFunction()
return

F3::
Reload
return


; === Functions ===
createCheckboxLayout(itemArray, prefix) {
   
    global
    ;Column positions (for column 1 and column 2)
    column1X := textX
    column2X := textX + (guiWidth * 0.5)
    maxCheckboxesPerColumn := 12  ; Adjust this number based on your GUI height

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

sendKeybind(keybind, delay := 500) {
    if (keybind = "\") {
        Send, \
    }
    else {
        Send, {%keybind%}
    }
    Sleep, %delay%
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
    sendKeybind("Right", 70)
    sendKeybind("Right", 70)
    sendKeybind("Enter ", 120)
    sendKeybind("Left", 70)
    sendKeybind("Left", 70)
    sendKeybind("Enter",120)
}
setupPosition(){
    ; Get screen center coordinates
    centerX := A_ScreenWidth // 2
    centerY := A_ScreenHeight // 2

    MouseMove, centerX, centerY
    Click, Right, Down
    MouseMove, centerX, centerY + 200, 10 
    ; Release right click
    Click, Right, Up

    sendKeybind("\")
    sendKeybind("Right", 200)
    sendKeybind("Right", 200)
    sendKeybind("Right", 200)
    sendKeybind("Enter", 200)
    ; enter the loop

    ; Loop rotateShops 4 times
    Loop, 4 {
        rotateShops()
    }
}
resetUINav(
    sendKeybind("\")
    sendKeybind("\")
)
returnToGarden(){

}

buyItem(){
    sendKeybind("Enter")
    sendKeybind("Down")
    Loop, 20
        {
            sendKeybind("Enter", 100)
        }
    sendKeybind("Down")
}

skipItem(){
    sendKeybind("Enter")
    sendKeybind("Down")
    sendKeybind("Down")
}

; SEEDS
buySeeds(){
    global
    sendKeybind("e", 3000)
    Loop, 30
        {  
            sendKeybind("Down", 50)
        }
    Loop, 50
        {
            sendKeybind("Up", 50)
        }

    
    sendKeybind("Down")
    sendKeybind("Down") 


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

    Loop, 50
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
    ;Return to garden
    sendKeybind("Left")
    sendKeybind("Enter")

}

startFunction() {
    Gui, Submit, NoHide


    changeCameraMode()
    setupPosition()
    changeCameraMode()


    buySeeds()

    Sleep, 100
    GuiControl,, Status, Status: Sequence Complete
}

stopFunction() {
    GuiControl,, Status, Status: Stopped
}

; === Handle close ===
GuiClose:
ExitApp