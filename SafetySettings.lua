local whitelistedAnimations = {
	ClimbAnimation = 0,
	FallAnimation = 0,
	IdleAnimation = 0,
	JumpAnimation = 0,
	MoodAnimation = 0,
	RunAnimation = 0,
	SwimAnimation = 0,
	WalkAnimation = 0
}

local safetySettings = {
	emoteDistance = 5,
	wsTreshold = 5,
	whitelist = whitelistedAnimations
}

return safetySettings
