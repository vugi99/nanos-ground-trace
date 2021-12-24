
Package.Require("Config.lua")

local CurMap_Cache = {
    MAX_Z = Max_Z_Added,
    MIN_Z = Min_Z_Added,
    CHUNKS = {},
}

function GetChunkAndGridKeyFromLocation(loc)
    local x_val = math.floor(loc.X / Chunk_Units)
    local y_val = math.floor(loc.Y / Chunk_Units)

    local xg_val = math.floor((loc.X - x_val * Chunk_Units) / Grid_Units)
    local yg_val = math.floor((loc.Y - y_val * Chunk_Units) / Grid_Units)
    return {x_val, y_val}, {xg_val, yg_val}
end
--print(GetChunkNameAndGridNameKeyFromLocation(Vector(64522, -24390)))

function GetNearestNotCalculatedChunk(loc)
    local nearest_sq
    local nearest
    local start_chunk = GetChunkAndGridKeyFromLocation(loc)
    if not CurMap_Cache.CHUNKS["x" .. tostring(start_chunk[1]) .. "y" .. tostring(start_chunk[2])] then
        return start_chunk, 0
    end
    for i = math.floor(-WillGroundTraceChunkForCacheInRadius / Chunk_Units), math.floor((WillGroundTraceChunkForCacheInRadius / Chunk_Units) - 1) do
        for i2 = math.floor(-WillGroundTraceChunkForCacheInRadius / Chunk_Units), math.floor((WillGroundTraceChunkForCacheInRadius / Chunk_Units) - 1) do
            if not CurMap_Cache.CHUNKS["x" .. tostring(start_chunk[1] + i) .. "y" .. tostring(start_chunk[2] + i2)] then
                local dist_sq = GetDistanceSq2D(Vector(start_chunk[1], start_chunk[2], 0), Vector(start_chunk[1] + i, start_chunk[2] + i2))
                if (not nearest_sq or nearest_sq > dist_sq) then
                    nearest_sq = dist_sq
                    nearest = {start_chunk[1] + i, start_chunk[2] + i2}
                end
            end
        end
    end
    return nearest, nearest_sq
end

function GetDistanceSq2D(loc, loc2)
    return ((loc2.X - loc.X)^2) + ((loc2.Y - loc.Y)^2)
end

function FixMapName(map_name)
    return map_name:gsub("::", ";")
end

function LoadMapCache()
    local map_name = FixMapName(Server.GetMap())
    local file = io.open("Packages/" .. Package.GetPath() .. "/Cache/" .. map_name .. ".json", "r")
    if file then
        local content = file:read("*a")
        CurMap_Cache = JSON.parse(content)
        io.close(file)
        print("ground-trace : " .. map_name .. " cache loaded")
    end
end
LoadMapCache()

function SaveMapCache()
    local map_name = FixMapName(Server.GetMap())
    local path = "Packages/" .. Package.GetPath() .. "/Cache/" .. map_name .. ".json"
    local file = io.open(path, "w")
    if file then
        file:write(JSON.stringify(CurMap_Cache))
        io.close(file)
        print("ground-trace : " .. map_name .. " cache saved")
    end
end

for k, v in pairs(Entities_Spawn) do
    _ENV[v].Subscribe("Spawn", function(v2)
        local loc = v2:GetLocation()
        if loc.Z > CurMap_Cache.MAX_Z - Max_Z_Added then
            CurMap_Cache.MAX_Z = loc.Z + Max_Z_Added
        end
        if loc.Z < CurMap_Cache.MIN_Z - Min_Z_Added then
            CurMap_Cache.MIN_Z = loc.Z + Min_Z_Added
        end
    end)
end

Package.Subscribe("Unload", function()
    SaveMapCache()
end)

Timer.SetInterval(function()
    for k, v in pairs(Character.GetPairs()) do
        local ply = v:GetPlayer()
        if ply then
            local nearest, nearest_sq = GetNearestNotCalculatedChunk(v:GetLocation())
            if nearest then
                Events.CallRemote("RequestChunkGroundTrace", ply, nearest[1], nearest[2], CurMap_Cache.MAX_Z, CurMap_Cache.MIN_Z)
            end
        end
    end
end, RequestForChunkEach_ms)

Events.Subscribe("GroundTraceForCache", function(ply, chunk_x, chunk_y, chunk)
    --print(chunk_x, chunk_y)
    for k, v in pairs(chunk) do
        chunk[k].Location = {X = chunk[k].Location.X, Y = chunk[k].Location.Y, Z = chunk[k].Location.Z}
        chunk[k].Normal = {X = chunk[k].Normal.X, Y = chunk[k].Normal.Y, Z = chunk[k].Normal.Z}
    end
    CurMap_Cache.CHUNKS["x" .. tostring(chunk_x) .. "y" .. tostring(chunk_y)] = chunk
end)

function GroundTrace(x, y)
    local chunk_key, grid_key = GetChunkAndGridKeyFromLocation(Vector(x, y, 0))
    local chunk = CurMap_Cache.CHUNKS["x" .. tostring(chunk_key[1]) .. "y" .. tostring(chunk_key[2])]
    if chunk then
        local trace = chunk["x" .. tostring(grid_key[1]) .. "y" .. tostring(grid_key[2])]
        if trace then
            local tbl = {}
            for k, v in pairs(trace) do
                if k == "Location" then
                    tbl[k] = Vector(v.X, v.Y, v.Z)
                elseif k == "Normal" then
                    tbl[k] = Rotator(v.X, v.Y, v.Z)
                else
                    tbl[k] = v
                end
            end
            return tbl
        else
            return "NoHit"
        end
    end
    return false
end
Package.Export("GroundTrace", GroundTrace)

function GetRandomSuccessfulGroundTrace()
    local valid_chunks = {}
    local count = 0
    for k, v in pairs(CurMap_Cache.CHUNKS) do
        for k2, v2 in pairs(v) do
            table.insert(valid_chunks, k)
            count = count + 1
            break
        end
    end

    if count > 0 then
        local random_chunk_key = valid_chunks[math.random(count)]
        if random_chunk_key then
            local r_chunk = CurMap_Cache.CHUNKS[random_chunk_key]
            local traces_in_chunk = {}
            local count_2 = 0
            for k, v in pairs(r_chunk) do
                table.insert(traces_in_chunk, v)
                count_2 = count_2 + 1
            end

            local random_trace = traces_in_chunk[math.random(count_2)]
            return random_trace
        end
    end
    return false
end
Package.Export("GetRandomSuccessfulGroundTrace", GetRandomSuccessfulGroundTrace)