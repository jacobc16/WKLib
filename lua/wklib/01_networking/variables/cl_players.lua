local net_Receive = net.Receive
local Player = Player
local IsValid = IsValid
local tonumber = tonumber
local tobool = tobool
local readUInt = net.ReadUInt
local readString = net.ReadString

net_Receive("wk-variables-plyinit", function()
	local playerCount = readUInt(16)

	print("Player count", playerCount)
	for i = 1, playerCount do
		local plyId = readUInt(16)
		local vars = WKLib.networking.ReadChunks()

		local ply = Player(plyId)

		print("Trying to set vars for", plyId)
		if not IsValid(ply) then
			// If the player isn't valid, we'll wait until they are, trying every 0.1 seconds for 10 seconds
			timer.Create("wk-variables-plyinit-" .. plyId, 0.1, 100, function()
				local ply = Player(plyId)

				if IsValid(ply) then
					ply.WKVars = WKLib.pon.decode(vars) or {}
					timer.Remove("wk-variables-plyinit-" .. plyId)
				end
			end)

			continue
		end

		ply.WKVars = WKLib.pon.decode(vars) or {}
	end
end)

local function setVar(ply, var, type, value)
	ply.WKVars = ply.WKVars or {}

	if type == 0 then
		ply.WKVars[var] = value
	elseif type == 1 then
		ply.WKVars[var] = tonumber(value)
	elseif type == 2 then
		ply.WKVars[var] = tobool(value)
	elseif type == 3 then
		ply.WKVars[var] = WKLib.pon.decode(value)
	end
end

net_Receive("wk-variables-plyset", function()
	local plyId = readUInt(16)
	local var = readString()
	local type = readUInt(8)
	local value = WKLib.networking.ReadChunks()

	local ply = Player(plyId)

	if not IsValid(ply) then
		timer.Create("wk-variables-plyinit-" .. plyId, 0.1, 100, function()
			local ply = Player(plyId)

			if IsValid(ply) then
				setVar(ply, var, type, value)
				timer.Remove("wk-variables-plyinit-" .. plyId)
			end
		end)
		return
	end

	setVar(ply, var, type, value)
end)

net_Receive("wk-variables-plyremove", function()
	local plyId = readUInt(16)
	local key = readString()

	if not IsValid(plyId) then return end

	local ply = Player(plyId)

	if not ply then return end

	ply.WKVars = ply.WKVars or {}
	ply.WKVars[key] = nil
end)