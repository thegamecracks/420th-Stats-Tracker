/*
Function: fdelta_stats_fnc_statsTrackTransportsOnGetOutMan

Description:
    Handle a player exiting a vehicle for transport stats.
    Function must be executed on server.

Parameters:
    Object unit:
        The player that exited the vehicle.
    String role:
        The vehicle role that the unit exited.
    Object vehicle:
        The vehicle that was exited.

Author:
    thegamecracks

*/
params ["_unit", "", "_vehicle"];
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};
if (!isPlayer _unit) exitWith {};

_unit getVariable "fdelta_stats_transport" params ["_startPos"];
_unit setVariable ["fdelta_stats_transport", nil];
if (isNil "_startPos") exitWith {};

// FIXME: A player could drive themselves, switch seats, and let someone else
//        take the driver seat before exiting which would count as their stat.
//
//        Preferably the start position would reset any time the driver/pilot
//        changes, but there's no easy event handler for this.
//
//        ControlsShifted (mission event handler) is close, but has
//        unreliable execution with global arguments.
private _driver = currentPilot _vehicle;
if (!isPlayer _driver) exitWith {};
if (_unit isEqualTo _driver) exitWith {};

private _minTransportDistance = 2000; // TODO: turn into CBA setting or something
private _distance = getPosATL _unit distance2D _startPos;
if (_distance < _minTransportDistance) exitWith {};

diag_log text format [
    "%1: %2 was transported %3m by %4 (%5)",
    _fnc_scriptName,
    name _unit,
    _distance,
    name _driver,
    getPlayerUID _driver
];

["transports", _driver] call fdelta_stats_fnc_statsIncrement;

// TODO: make a new function to track slingloads
