local print = print
local hook_Call = hook.Call
local WKLib = WKLib
local gameevent_Listen = gameevent.Listen
local Player = Player
local FindMetaTable = FindMetaTable
local istable = istable
local isbool = isbool
local isnumber = isnumber
local player_GetAll = player.GetAll
local ipairs = ipairs
local pairs = pairs
local hook_Add = hook.Add
local concommand_Add = concommand.Add
local IsValid = IsValid
local CurTime = CurTime
local netStart = net.Start
local writeUInt = net.WriteUInt
local writeString = net.WriteString
local send = net.Send
local broadcast = net.Broadcast

wkvars_cache = wkvars_cache or {}
wkvars_pcache = wkvars_pcache or {}

local plyMeta = FindMetaTable("Player")

local function sendWKVar(owner, var, value, players)
	local ownerId = owner:UserID()

	wkvars_cache[ownerId] = wkvars_cache[ownerId] or {}
	wkvars_cache[ownerId][var] = value

	netStart("wk-variables-plyset")
	writeUInt(ownerId, 16)
	writeString(var)

	if istable(value) then
		writeUInt(3, 8)
	elseif isbool(value) then
		writeUInt(2, 8)
	elseif isnumber(value) then
		writeUInt(1, 8)
	else
		writeUInt(0, 8)
	end

	WKLib.networking.WriteChunks(value)

	if players then
		send(players)
	else
		broadcast()
	end
end

function plyMeta:SetWKVar(var, value, players)
	self.WKVars = self.WKVars or {}
	self.WKVars[var] = value

	sendWKVar(self, var, value, players)
end

function plyMeta:SetPrivateWKVar(var, value)
	local ownerId = self:UserID()
	wkvars_pcache[ownerId] = wkvars_pcache[ownerId] or {}
	wkvars_pcache[ownerId][var] = true

	self:SetWKVar(var, value, self)
end

function plyMeta:RemoveWKVar(var, players)
	local ownerId = self:UserID()
	self.WKVars = self.WKVars or {}
	self.WKVars[var] = nil

	wkvars_cache[ownerId] = wkvars_cache[ownerId] or {}
	wkvars_cache[ownerId][var] = nil

	netStart("wk-variables-plyremove")
	writeUInt(ownerId, 16)
	writeString(var)

	if players then
		send(players)
	else
		broadcast()
	end
end


function plyMeta:SendWKVars()
	if self:EntIndex() == 0 then return end

	local players = player_GetAll()

	print("Sending WKVars to", self:Nick())
	netStart("wk-variables-plyinit")
	writeUInt(#players, 16)

	for _, ply in ipairs(players) do
		local userId = ply:UserID()
		writeUInt(userId, 16)
		local data = {}

		print("Getting vars for", ply:Nick())

		for varName, varValue in pairs(wkvars_cache[userId] or {}) do
			if self ~= ply and (wkvars_pcache[userId] or {})[varName] then
				print("Skipping private var", varName .. " for", ply:Nick())
				continue
			end

			data[varName] = varValue
		end

		WKLib.networking.WriteChunks(data)
	end

	send(self)
end

hook_Add("PlayerDisconnected", "wk-variables-plyremove", function(ply)
	local userId = ply:UserID()
	wkvars_cache[userId] = nil
	wkvars_pcache[userId] = nil
end)

gameevent_Listen( "player_activate" )
hook_Add("player_activate", "wk-variables-send", function(data)
	local ply = Player(data.userid)
	ply.WKVars = ply.WKVars or {}
	hook_Call("WKPlayerLoaded", nil, ply)
	ply:SendWKVars()
end)

concommand_Add("_wkrequestvars", function(ply)
	if not IsValid(ply) then return end

	if ply.WKVarsLastRequest and ply.WKVarsLastRequest > (CurTime() - 5) then return end

	ply.WKVarsLastRequest = CurTime()
	ply:SendWKVars()
end)