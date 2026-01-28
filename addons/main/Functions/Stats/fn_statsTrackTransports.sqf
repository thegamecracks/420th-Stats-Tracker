/*
Function: fdelta_stats_fnc_statsTrackTransports

Description:
    Continuously increment transport statistics.
    Function must be executed in scheduled environment.

Author:
    thegamecracks

*/
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};

private _minTransportDistance = 2000; // TODO: turn into CBA setting or something
private _getNullTransport = {[objNull, [0,0,0]]};
private _getCurrentTransport = {
    private _vehicle = objectParent _x;
    if (isNull _vehicle) exitWith _getNullTransport;
    // if !(_vehicle isKindOf "Air") exitWith _getNullTransport;

    private _driver = currentPilot _vehicle;
    if (!isPlayer _driver) exitWith _getNullTransport;
    if (_driver isEqualTo _x) exitWith _getNullTransport;

    [_driver, getPosATL _x]
};

// TODO: update this function or make a new function to track slingloads

while {true} do {
    sleep 5;
    {
        // To track transports, we set a variable on each player
        // containing their player driver and starting position.
        private _last = _x getVariable ["fdelta_stats_transport", call _getNullTransport];
        private _current = call _getCurrentTransport;

        _last params ["_driver", "_lastPos"];
        _current params ["_currentDriver"];

        // If there's no change in driver, nothing has happened yet.
        // This could mean they're on foot or they're still being transported.
        if (_driver isEqualTo _currentDriver) then {continue};

        // A driver change has occurred, make sure to update the last known driver.
        _x setVariable ["fdelta_stats_transport", _current];

        // This catches the common case where the player just entered a vehicle.
        if (!isPlayer _driver) then {continue};

        // This catches an edge case where the pilot/copilot switch control.
        // This resets the starting position.
        if (!isNull _currentDriver) then {continue};

        // We know the player has disembarked, so let's make sure they
        // actually travelled some distance.
        private _distance = getPosATL _x distance2D _lastPos;
        if (_distance < _minTransportDistance) then {continue};

        diag_log text format [
            "%1: %2 was transported %3m by %4 (%5)",
            _fnc_scriptName,
            name _x,
            _distance,
            name _driver,
            getPlayerUID _driver
        ];

        ["transports", _driver] call fdelta_stats_fnc_statsIncrement;
    } forEach allPlayers;
};
