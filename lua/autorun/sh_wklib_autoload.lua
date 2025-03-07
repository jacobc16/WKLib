local hook_Run = hook.Run
local file_Find = file.Find
local MsgC = MsgC
local Color = Color
local SortedPairs = SortedPairs
local string_StartWith = string.StartWith
local AddCSLuaFile = AddCSLuaFile
local include = include
local string_gsub = string.gsub

WKLib = {}

WKLib.pon = include("thirdparty/pon.lua")

local function printLog(name, ...)
	MsgC(Color(0, 255, 255), "[" .. name .. "] ", Color(255, 255, 255), ...)
end

function WKLib.loadLua(dir, logTable, isSubFolder, parentFolder)
	logTable = logTable or false
	isSubFolder = isSubFolder or false
	parentFolder = parentFolder or ""

	local _, folders = file_Find(dir .. "/*", "LUA")

	for k, v in SortedPairs(folders) do
		local _dir = dir .. "/" .. v .. "/"
		local files, extraFolders = file_Find(_dir .. "*", "LUA")

		for _, fileName in SortedPairs(files) do
			local filePath = _dir .. fileName
			if string_StartWith(fileName, "sh_") then
				if SERVER then
					AddCSLuaFile(filePath)
					include(filePath)
				else
					include(filePath)
				end
			elseif string_StartWith(fileName, "sv_") and SERVER then
				include(filePath)
			elseif string_StartWith(fileName, "cl_") then
				if SERVER then
					AddCSLuaFile(filePath)
				else
					include(filePath)
				end
			end
		end

		local moduleName = string_gsub(v, "%d%d_", "")
		local logEachFolder = logTable and logTable.eachFolder or false

		if not isSubFolder and logTable and logEachFolder then
			local color = logTable.color or Color(255, 0, 0)
			printLog(logTable.name, color, logTable.text .. " ", Color(255, 255, 255), "Loaded: ", Color(255, 255, 0), moduleName .. "\n")
		end

		if extraFolders then
			_dir = _dir:sub(1, -2)
			WKLib.loadLua(_dir, logTable, true, moduleName)
		end
	end

	local logFinish = logTable and logTable.onFinish or false
	if not isSubFolder and logTable and logFinish then
		printLog(logTable.name, Color(255, 255, 255), "Finished loading ", Color(255, 255, 0), parentFolder, "\n")
	end
end

print(DarkRP)

WKLib.loadLua("wklib", {
	onFinish = true,
	name = "WKLib",
})

hook_Run("WKLib:OnLoaded")

if (SERVER) then
	AddCSLuaFile("thirdparty/pon.lua")
end