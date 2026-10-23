-- Compile as an application with:
-- osacompile -o "$HOME/Applications/Toggle Headphones.app" <this file>
-- Switches the playback output only; leaves microphone selection unchanged.

property headphonesName : "Karl’s AirPods Max"
property speakersName : "MacBook Pro Speakers"

on run
	try
		set audioTool to my findAudioTool()
		set currentOutput to do shell script (quoted form of audioTool) & " -c -t output"
		set availableOutputs to paragraphs of (do shell script (quoted form of audioTool) & " -a -t output")
		set targetOutput to my targetOutputFor(currentOutput, availableOutputs)
		do shell script (quoted form of audioTool) & " -t output -s " & quoted form of targetOutput
	on error errorMessage
		display alert "Could not switch audio output" message errorMessage as warning buttons {"OK"} default button "OK"
	end try
end run

on targetOutputFor(currentOutput, availableOutputs)
	if currentOutput is headphonesName then
		set targetOutput to speakersName
	else
		set targetOutput to headphonesName
	end if

	if availableOutputs does not contain targetOutput then
		if targetOutput is headphonesName then
			error "Connect " & headphonesName & " first, then run Toggle Headphones again." number 1001
		else
			error "Audio output is unavailable: " & targetOutput number 1001
		end if
	end if
	return targetOutput
end targetOutputFor

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
