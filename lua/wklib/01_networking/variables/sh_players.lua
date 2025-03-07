local FindMetaTable = FindMetaTable

local ply = FindMetaTable("Player")

function ply:GetWKVars()
	self.WKVars = self.WKVars or {}
	return self.WKVars
end

function ply:GetWKVar(var, fallback)
	local vars = self:GetWKVars()
	fallback = fallback or nil

	return vars[var] or fallback
end