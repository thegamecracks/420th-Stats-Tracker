/*
Function: fdelta_stats_fnc_statsTrackRevives

Description:
    Continuously increment revive statistics.
    Clients must set "fdelta_stats_revived_by" on any unit they have revived.
    Function must be executed in scheduled environment.

Author:
    thegamecracks

*/
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};

while {true} do {
    sleep 10;

    private _revivedUnits =
        allPlayers // can be allUnits, but iteration is slower
        select {!isNil {_x getVariable "fdelta_stats_revived_by"}};

    {
        private _revived_by = _x getVariable "fdelta_stats_revived_by";
        _x setVariable ["fdelta_stats_revived_by", nil, true];

        if !(_revived_by isEqualType objNull) then {continue}; // prevent type errors

        private _uid = getPlayerUID _revived_by;
        if (_uid isEqualTo "") then {continue};

        diag_log text format [
            "%1: %2 was revived by %3 (%4)",
            _fnc_scriptName,
            name _x,
            name _revived_by,
            _uid
        ];

        ["revives", _revived_by] call fdelta_stats_fnc_statsIncrement;
    } forEach _revivedUnits;
};
