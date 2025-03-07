hook.Add("WKPlayerLoaded", "wk-variables-send", function(ply)
    -- for i = 1, 1000 do
    --     ply:SetWKVar("test" .. i, "test")
    --     ply:SetWKVar("test2" .. i, 123)
    --     ply:SetWKVar("float" .. i, 1230000000.456)
    --     ply:SetWKVar("test3" .. i, true)
    --     ply:SetWKVar("test4" .. i, {test = "test"})
    --     ply:SetWKVar("random" .. i, math.random(1, 100))
    -- end
end)