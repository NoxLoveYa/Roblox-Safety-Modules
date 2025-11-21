local Players = game:GetService("Players")

local safetySettings = require(game.ServerStorage:WaitForChild("SafetySettings"))
local safetyFolder = game.ReplicatedStorage:WaitForChild("SafetyFolder", 1) or Instance.new("Folder", game.ReplicatedStorage)
safetyFolder.Name = "SafetyFolder"


local onEmoteBlocked: RemoteEvent = Instance.new("RemoteEvent", safetyFolder)
onEmoteBlocked.Name = "onEmoteBlocked"


local raycastParams: RaycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function normalizeContentId(id: string): string
	local num = id:match("%d+")
	if num then
		return "rbxassetid://" .. num
	end
	return id
end

local function loadAnimWhitelistFromAnimate(animateScript: Script)
	safetySettings.whitelist = {}

	for _, obj in ipairs(animateScript:GetDescendants()) do
		if obj:IsA("Animation") then
			local rawId = obj.AnimationId
			if rawId and rawId ~= "" then
				local normId = normalizeContentId(rawId)
				safetySettings.whitelist[normId] = true
			end
		end
	end
end

local function isAnimWhitelisted(animationTrack: AnimationTrack): boolean
	local playedId = normalizeContentId(animationTrack.Animation.AnimationId)
	local allowed = safetySettings.whitelist[playedId] == true

	return allowed
end

local function getPlayerInDirection(character: Model, humanoidRootPart: Part, direction: Vector3)
	raycastParams.FilterDescendantsInstances = { character }

	local raycastResult: RaycastResult = workspace:Raycast(
		humanoidRootPart.Position,
		direction,
		raycastParams
	)

	if raycastResult then
		local hitPart = raycastResult.Instance
		if not hitPart or not hitPart:IsDescendantOf(workspace) then return nil end

		local hitCharacter = hitPart:FindFirstAncestorOfClass("Model")
		if not hitCharacter then return nil end

		local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)
		if not hitPlayer then return nil end
		
		return hitPlayer
	end
	
	return nil
end

Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(character: Model)
		local humanoid: Humanoid = character:WaitForChild("Humanoid")
		local humanoidRootPart: Part = character:WaitForChild("HumanoidRootPart")
		local animator: Animator = humanoid:WaitForChild("Animator")
		local animateScript: Script = character:FindFirstChild("Animate")

		if not animateScript then
			animateScript = character:WaitForChild("Animate", 5)
		end

		if not animateScript then
			warn("No Animate script found for", player)
			return
		end

		loadAnimWhitelistFromAnimate(animateScript)

		animator.AnimationPlayed:Connect(function(animationTrack: AnimationTrack)
			local isAnimationWhitelisted = isAnimWhitelisted(animationTrack)
			if isAnimationWhitelisted then return end

			local closePlayer = getPlayerInDirection(character, humanoidRootPart, humanoidRootPart.CFrame.LookVector.Unit * safetySettings.emoteDistance)
			if closePlayer then
				onEmoteBlocked:FireAllClients(character)
				animationTrack:Stop(.1)
			end
			
			closePlayer = getPlayerInDirection(character, humanoidRootPart, -humanoidRootPart.CFrame.LookVector.Unit * safetySettings.emoteDistance)
			if closePlayer then
				onEmoteBlocked:FireAllClients(character)
				animationTrack:Stop(.1)
			end
		end)
	end)
end)
