-- Run with: osascript <this file> <compiled Toggle Headphones.scpt>
-- Pure fixture tests: no permission prompts or live audio changes.
on run arguments
	set toggleScript to load script POSIX file (item 1 of arguments)
	set smartName to "Someone" & (character id 8217) & "s AirPods Max"
	set plainName to "Someone's AirPods Max"
	set speakerName to "Generic built-in speakers"
	set outputs to {smartName, speakerName, "Display", "Virtual Audio"}
	if toggleScript's targetOutputFor(smartName, outputs, plainName, speakerName) is not speakerName then error "Headphones to speakers failed"
	if toggleScript's targetOutputFor(speakerName, outputs, plainName, speakerName) is not smartName then error "Speakers to headphones failed"
	if toggleScript's targetOutputFor("Display", outputs, plainName, speakerName) is not smartName then error "Display to headphones failed"
	if toggleScript's targetOutputFor(plainName, outputs, smartName, speakerName) is not speakerName then error "Apostrophe normalization failed"
	if toggleScript's matchingName("Unknown", outputs) is not missing value then error "Unknown output matched"
	my expectMissingOutput(toggleScript, speakerName, {speakerName}, plainName, speakerName)
	my expectMissingOutput(toggleScript, plainName, {smartName}, plainName, speakerName)

	set fixture to "{\"SPBluetoothDataType\":[{\"device_connected\":[{\"Studio Cans\":{\"device_minorType\":\"Headphones\"}},{\"Mouse\":{\"device_minorType\":\"Mouse\"}},{\"Work Headset\":{\"device_minorType\":\"Headset\"}},{\"Unknown\":{}}],\"device_not_connected\":[{\"Travel Buds\":{\"device_minorType\":\"Headphones\"}}]}]}"
	set groups to toggleScript's bluetoothHeadphones(toggleScript's parseJSON(fixture))
	if connectedNames of groups is not {"Studio Cans", "Work Headset"} then error "Connected headphone classification failed"
	if pairedNames of groups is not {"Studio Cans", "Work Headset", "Travel Buds"} then error "Paired headphone classification failed"
	if toggleScript's chooseHeadphones(speakerName, {"Studio Cans"}, pairedNames of groups) is not "Studio Cans" then error "Connected device preference failed"
	if toggleScript's chooseHeadphones(speakerName, {}, {"Travel Buds"}) is not "Travel Buds" then error "Inactive paired headphone fallback failed"
	if toggleScript's chooseHeadphones("Travel Buds", connectedNames of groups, pairedNames of groups) is not "Travel Buds" then error "Current headphone preference failed"

	set emptyGroups to toggleScript's bluetoothHeadphones(toggleScript's parseJSON("{\"SPBluetoothDataType\":[{}]}"))
	if connectedNames of emptyGroups is not {} or pairedNames of emptyGroups is not {} then error "Empty Bluetooth groups failed"
	set rejectedNoHeadphones to false
	try
		toggleScript's chooseHeadphones(speakerName, {}, {})
	on error errorMessage number errorNumber
		if errorNumber is not 1001 then error errorMessage number errorNumber
		set rejectedNoHeadphones to true
	end try
	if not rejectedNoHeadphones then error "Missing headphones were accepted"
	return "14 checks passed; no live audio changes."
end run

on expectMissingOutput(toggleScript, currentOutput, outputs, headphonesName, speakersName)
	try
		toggleScript's targetOutputFor(currentOutput, outputs, headphonesName, speakersName)
	on error errorMessage number errorNumber
		if errorNumber is not 1001 then error errorMessage number errorNumber
		return
	end try
	error "Missing output was accepted"
end expectMissingOutput
