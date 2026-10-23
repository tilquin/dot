-- Build and sign the application with:
-- make -C "$HOME/Library/dot/applescripts"
-- Discovers Bluetooth headphones and built-in speakers; no personal names.
-- Inactive headphones are activated through the macOS Sound menu.
-- This fallback needs Accessibility and Automation (System Events) permission.

use framework "Foundation"
use scripting additions

on run
	try
		set audioTool to my findAudioTool()
		set currentOutput to do shell script (quoted form of audioTool) & " -c -t output"
		set availableOutputs to paragraphs of (do shell script (quoted form of audioTool) & " -a -t output")
		set speakersName to my builtInSpeakersFor(audioTool)
		set bluetoothProfile to my parseJSON(do shell script "/usr/sbin/system_profiler SPBluetoothDataType -json")
		set headphoneGroups to my bluetoothHeadphones(bluetoothProfile)
		set headphonesName to my chooseHeadphones(currentOutput, connectedNames of headphoneGroups, pairedNames of headphoneGroups)
		set originalInput to do shell script (quoted form of audioTool) & " -c -t input"
		try
			set targetOutput to my targetOutputFor(currentOutput, availableOutputs, headphonesName, speakersName)
		on error errorMessage number errorNumber
			if errorNumber is not 1001 or my canonicalName(currentOutput) is my canonicalName(headphonesName) then error errorMessage number errorNumber
			my activateHeadphonesFromSoundMenu(headphonesName)
			set targetOutput to my waitForHeadphonesOutput(audioTool, headphonesName)
		end try
		do shell script (quoted form of audioTool) & " -t output -s " & quoted form of targetOutput
		-- Sound-menu activation can also change macOS's default microphone.
		set currentInput to do shell script (quoted form of audioTool) & " -c -t input"
		if currentInput is not originalInput then
			do shell script (quoted form of audioTool) & " -t input -s " & quoted form of originalInput
		end if
	on error errorMessage number errorNumber
		if errorNumber is -128 then return -- Cancelled the device picker.
		if errorNumber is -1743 or errorNumber is -25211 then set errorMessage to "Allow Toggle Headphones in System Settings > Privacy & Security > Accessibility, and Automation > System Events. Then run it again."
		display alert "Could not switch audio output" message errorMessage as warning buttons {"OK"} default button "OK"
	end try
end run

on targetOutputFor(currentOutput, availableOutputs, headphonesName, speakersName)
	if my canonicalName(currentOutput) is my canonicalName(headphonesName) then
		set targetOutput to speakersName
	else
		set targetOutput to headphonesName
	end if

	set actualOutput to my matchingName(targetOutput, availableOutputs)
	if actualOutput is not missing value then return actualOutput
	error "Audio output is not active yet: " & targetOutput number 1001
end targetOutputFor

on parseJSON(jsonText)
	set jsonString to current application's NSString's stringWithString:jsonText
	set jsonData to jsonString's dataUsingEncoding:(current application's NSUTF8StringEncoding)
	set jsonObject to current application's NSJSONSerialization's JSONObjectWithData:jsonData options:0 |error|:(missing value)
	if jsonObject is missing value then error "macOS returned invalid device information." number 1005
	return jsonObject
end parseJSON

on builtInSpeakersFor(audioTool)
	set jsonLines to paragraphs of (do shell script (quoted form of audioTool) & " -a -t output -f json")
	repeat with jsonLine in jsonLines
		set outputDevice to my parseJSON(contents of jsonLine)
		if (outputDevice's objectForKey:"uid") as text is "BuiltInSpeakerDevice" then return (outputDevice's objectForKey:"name") as text
	end repeat
	error "No built-in speaker output is available." number 1001
end builtInSpeakersFor

on bluetoothHeadphones(bluetoothProfile)
	set connectedDevices to {}
	set allDevices to {}
	set controllers to bluetoothProfile's objectForKey:"SPBluetoothDataType"
	if controllers is missing value then error "macOS returned no Bluetooth device information." number 1005
	repeat with controller in controllers
		repeat with groupKey in {"device_connected", "device_not_connected"}
			set deviceGroup to controller's objectForKey:(contents of groupKey)
			if deviceGroup is not missing value then
				repeat with deviceEntry in deviceGroup
					repeat with nameKey in deviceEntry's allKeys()
						set deviceInfo to deviceEntry's objectForKey:nameKey
						set minorType to deviceInfo's objectForKey:"device_minorType"
						if minorType is not missing value then
							if (minorType as text) is in {"Headphones", "Headset"} then
								set deviceName to nameKey as text
								if my matchingName(deviceName, allDevices) is missing value then set end of allDevices to deviceName
								if (contents of groupKey) is "device_connected" and my matchingName(deviceName, connectedDevices) is missing value then set end of connectedDevices to deviceName
							end if
						end if
					end repeat
				end repeat
			end if
		end repeat
	end repeat
	return {connectedNames:connectedDevices, pairedNames:allDevices}
end bluetoothHeadphones

on chooseHeadphones(currentOutput, connectedDevices, allDevices)
	-- Switching back to speakers should never ask which headphones to use.
	if my matchingName(currentOutput, allDevices) is not missing value then return currentOutput
	if (count connectedDevices) > 0 then
		set candidates to connectedDevices
	else
		set candidates to allDevices
	end if
	if (count candidates) is 0 then error "No paired Bluetooth headphones were found. Pair your headphones in macOS first." number 1001
	if (count candidates) is 1 then return item 1 of candidates
	set chosenDevice to choose from list candidates with title "Toggle Headphones" with prompt "Which headphones should receive audio?" without multiple selections allowed
	if chosenDevice is false then error number -128
	return item 1 of chosenDevice
end chooseHeadphones

on matchingName(deviceName, availableNames)
	repeat with availableName in availableNames
		if my canonicalName(contents of availableName) is my canonicalName(deviceName) then return contents of availableName
	end repeat
	return missing value
end matchingName

on canonicalName(deviceName)
	set savedDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to character id 8217
	set nameParts to text items of (deviceName as text)
	set AppleScript's text item delimiters to "'"
	set normalizedName to nameParts as text
	set AppleScript's text item delimiters to savedDelimiters
	return normalizedName
end canonicalName

on waitForHeadphonesOutput(audioTool, headphonesName)
	repeat 40 times
		set availableOutputs to paragraphs of (do shell script (quoted form of audioTool) & " -a -t output")
		set activeOutput to my matchingName(headphonesName, availableOutputs)
		if activeOutput is not missing value then return activeOutput
		delay 0.25
	end repeat
	error "macOS did not finish activating the headphones within 10 seconds." number 1004
end waitForHeadphonesOutput

on activateHeadphonesFromSoundMenu(headphonesName)
	tell application "System Events"
		if not UI elements enabled then error "Allow Toggle Headphones in System Settings > Privacy & Security > Accessibility, then run it again." number 1003
		tell process "ControlCenter"
			set soundMenuItem to missing value
			repeat with menuItem in menu bar items of menu bar 1
				if my uiLabel(menuItem) contains "Sound" then
					set soundMenuItem to contents of menuItem
					exit repeat
				end if
			end repeat
			if soundMenuItem is missing value then error "Show Sound in the menu bar in System Settings, so Toggle Headphones can activate the AirPods." number 1003
			if not my pressUIElement(soundMenuItem) then error "macOS did not allow Toggle Headphones to open the Sound menu." number 1003
		end tell
	end tell

	repeat 20 times
		tell application "System Events" to tell process "ControlCenter"
			if exists window 1 then
				set panelElements to entire contents of window 1
				repeat with panelElement in panelElements
					if my canonicalName(my uiLabel(panelElement)) contains my canonicalName(headphonesName) then
						if my pressUIElement(panelElement) then return
					end if
				end repeat
			end if
		end tell
		delay 0.1
	end repeat
	error "Could not find " & headphonesName & " in the macOS Sound menu. Make sure the headphones are nearby and paired." number 1004
end activateHeadphonesFromSoundMenu

on uiLabel(uiElement)
	set labelText to ""
	tell application "System Events"
		try
			set labelText to name of uiElement as text
		end try
		try
			set labelText to labelText & " " & (description of uiElement as text)
		end try
		try
			set labelText to labelText & " " & (value of uiElement as text)
		end try
	end tell
	return labelText
end uiLabel

on pressUIElement(uiElement)
	-- Device labels can be static text inside the actual clickable row.
	set candidate to contents of uiElement
	repeat 3 times
		tell application "System Events"
			try
				perform action "AXPress" of candidate
				return true
			end try
			try
				set candidate to value of attribute "AXParent" of candidate
			on error
				return false
			end try
		end tell
	end repeat
	return false
end pressUIElement

on findAudioTool()
	repeat with candidate in {"/opt/homebrew/bin/SwitchAudioSource", "/usr/local/bin/SwitchAudioSource"}
		set candidatePath to contents of candidate
		try
			do shell script "test -x " & quoted form of candidatePath
			return candidatePath
		end try
	end repeat
	error "Install the audio helper in Terminal: brew install switchaudio-osx" number 1002
end findAudioTool
