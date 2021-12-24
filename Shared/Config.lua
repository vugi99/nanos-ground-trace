

Grid_Units = 250


--[[ CHUNKS : {
    x0y0 = {
        x0y0 = {},
        x1y0 = {},
        x0y1 = {},
    },
    x0y1 = {

    },
}
]]--
Chunk_Units = 2500
-- RESET CACHE WHEN CHANGING THESE ^
-- Chunk_Units / Grid_Units has to return an integer

Entities_Spawn = {
    "Character",
    "Prop",
    "StaticMesh",
    "Vehicle",
}

Max_Z_Added = 30000
Min_Z_Added = -10000

WillGroundTraceChunkForCacheInRadius = 30000
RequestForChunkEach_ms = 250