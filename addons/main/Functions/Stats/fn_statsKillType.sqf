/*
Function: fdelta_stats_fnc_statsKillType

Description:
    Determine the type of kill stat that a given object should use.
    If the object has no kill stat, an empty string is returned.

Parameters:
    Object obj:
        The object's kill type to return.

Returns:
    String

Author:
    thegamecracks

*/
params ["_obj"];
private _cache = localNamespace getVariable "fdelta_stats_kill_type_cache";
if (isNil "_cache") then {
    _cache = createHashMap;
    localNamespace setVariable ["fdelta_stats_kill_type_cache", _cache];
};

_cache getOrDefaultCall [
    typeOf _obj,
    {
        private _config = configOf _obj;
        private _simulation = getText (_config >> "simulation");
        switch (true) do {
            case (_simulation == "soldier"): {"kills"};
            case (_simulation == "airplane");
            case (_simulation == "airplanex");
            case (_simulation == "helicopter");
            case (_simulation == "helicopterrtd"): {"kills_air"};
            case (_simulation == "car");
            case (_simulation == "carx"): {"kills_cars"};
            case (_simulation == "ship");
            case (_simulation == "shipx");
            case (_simulation == "submarinex"): {"kills_ships"};
            case (_simulation == "tank");
            case (_simulation == "tankx"): {"kills_tanks"};
            default {""};
        }
    },
    true
]
