
Package.Require("Config.lua")


Events.Subscribe("RequestChunkGroundTrace", function(chunk_x, chunk_y, max_z, min_z)
    --print("RequestChunkGroundTrace")
    local chunk = {}
    local max = math.floor(Chunk_Units / Grid_Units)
    for x = 0, max - 1 do
        for y = 0, max - 1 do
            local TraceResult = Client.Trace(
                Vector(chunk_x * Chunk_Units + x * Grid_Units, chunk_y * Chunk_Units + y * Grid_Units, max_z),
                Vector(chunk_x * Chunk_Units + x * Grid_Units, chunk_y * Chunk_Units + y * Grid_Units, min_z),
                CollisionChannel.WorldStatic,
                false,
                false,
                true,
                {},
                false
            )
            if TraceResult.Success then
                TraceResult.Success = nil
                TraceResult.BoneName = nil
                chunk["x" .. tostring(x) .. "y" .. tostring(y)] = TraceResult
            end
        end
    end
    Events.CallRemote("GroundTraceForCache", chunk_x, chunk_y, chunk)
end)