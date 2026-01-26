/*
Function: fdelta_stats_fnc_statsTemplate

Description:
    Return an empty hashmap of all stats available for tracking.

Returns:
    HashMap [
        String,
        Hashmap [
            String,
            Number
        ]
    ]

Author:
    thegamecracks

*/
createHashMapFromArray [
    ["deaths",      createHashMap],
    ["incaps",      createHashMap], // TODO
    ["kills",       createHashMap],
    ["kills_air",   createHashMap],
    ["kills_cars",  createHashMap],
    ["kills_ships", createHashMap],
    ["kills_tanks", createHashMap],
    ["playtime",    createHashMap], // TODO
    ["revives",     createHashMap], // TODO
    ["transports",  createHashMap]  // TODO
]
