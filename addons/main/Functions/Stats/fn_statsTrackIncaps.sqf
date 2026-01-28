/*
Function: fdelta_stats_fnc_statsTrackIncaps

Description:
    Continuously increment incapacitation statistics.
    Function must be executed in scheduled environment.

Author:
    thegamecracks

*/
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};

while {true} do {
    sleep 2;
    {
        private _last = _x getVariable ["fdelta_stats_lifeState", "HEALTHY"];
        private _current = lifeState _x;
        _x setVariable ["fdelta_stats_lifeState", _current];
        if (_last isEqualTo "INCAPACITATED" || {_current isNotEqualTo "INCAPACITATED"}) then {continue};

        diag_log text format [
            "%1: %2 (%3) was incapacitated",
            _fnc_scriptName,
            name _x,
            getPlayerUID _x
        ];

        ["incaps", _x] call fdelta_stats_fnc_statsIncrement;
    } forEach allPlayers;
};
