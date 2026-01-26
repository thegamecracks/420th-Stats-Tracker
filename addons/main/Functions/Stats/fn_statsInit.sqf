/*
Function: fdelta_stats_fnc_statsInit

Description:
    Initialize stats tracking on server and all (JIP) clients.

Author:
    thegamecracks

*/
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};

localNamespace setVariable ["fdelta_stats_current_deaths",         createHashMap];
localNamespace setVariable ["fdelta_stats_current_incaps",         createHashMap]; // TODO
localNamespace setVariable ["fdelta_stats_current_kills",          createHashMap];
localNamespace setVariable ["fdelta_stats_current_kills_air",      createHashMap];
localNamespace setVariable ["fdelta_stats_current_kills_cars",     createHashMap];
localNamespace setVariable ["fdelta_stats_current_kills_ships",    createHashMap];
localNamespace setVariable ["fdelta_stats_current_kills_tanks",    createHashMap];
localNamespace setVariable ["fdelta_stats_current_playtime",       createHashMap]; // TODO
localNamespace setVariable ["fdelta_stats_current_transports",     createHashMap]; // TODO

fdelta_stats_ehID_entityKilled = addMissionEventHandler ["EntityKilled", {
    params ["_entity", "_source", "_instigator"];

    if (isNull _source) exitWith {};
    if (_entity isEqualTo _source) exitWith {}; // Likely force respawned

    if (isPlayer _entity) then {
        ["deaths", _entity] call fdelta_stats_fnc_statsIncrement;
    };

    if (isPlayer _instigator) then {
        private _stat = switch (true) do {
            case (_entity isKindOf "CAManBase"): {"kills"};
            case (_entity isKindOf "Air"): {"kills_air"};
            case (_entity isKindOf "Car"): {"kills_cars"};
            case (_entity isKindOf "Ship"): {"kills_ships"};
            case (_entity isKindOf "Tank"): {"kills_tanks"};
            default {""};
        };
        if (_stat isNotEqualTo "") then {
            [_stat, _instigator] call fdelta_stats_fnc_statsIncrement;
        };
    };
}];

diag_log text format ["%1: initialized stats tracking event handlers", _fnc_scriptName];
