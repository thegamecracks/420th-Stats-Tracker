/*
Function: fdelta_stats_fnc_statsInit

Description:
    Initialize stats tracking on server and all (JIP) clients.
    Function must be executed on server.

Author:
    thegamecracks

*/
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};

call fdelta_stats_fnc_statsReset;

fdelta_stats_ehID_EntityKilled = addMissionEventHandler ["EntityKilled", {
    params ["_entity", "_source", "_instigator"];

    if (isNull _source) exitWith {};
    if (_entity isEqualTo _source) exitWith {}; // Likely force respawned
    if (isNull _instigator) then {_instigator = UAVControl vehicle _source # 0};
    if (isNull _instigator) then {_instigator = _source};

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
        if (_stat isEqualTo "") exitWith {};
        private _friendly = side group _entity isEqualTo side group _instigator;
        private _amount = [1, -1] select _friendly;
        [_stat, _instigator, _amount] call fdelta_stats_fnc_statsIncrement;
    };
}];

fdelta_stats_ehID_OnUserSelectedPlayer = addMissionEventHandler ["OnUserSelectedPlayer", {
    params ["", "_unit"];
    // FIXME: In a player-hosted server, the hoster might get duplicate EHs on every respawn.
    //        This may not have any noticeable consequences as long as the below functions
    //        are idempotent, but it's probably a good idea to skip if our handler IDs still
    //        exist on the unit.
    _unit addEventHandler ["GetInMan", {call fdelta_stats_fnc_statsTrackTransportsOnGetInMan}];
    _unit addEventHandler ["GetOutMan", {call fdelta_stats_fnc_statsTrackTransportsOnGetOutMan}];
}];

0 spawn fdelta_stats_fnc_statsTrackIncaps;
0 spawn fdelta_stats_fnc_statsTrackPlaytime;
0 spawn fdelta_stats_fnc_statsTrackRevives;

diag_log text format ["%1: initialized stats tracking event handlers", _fnc_scriptName];
