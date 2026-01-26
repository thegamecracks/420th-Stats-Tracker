/*
Function: fdelta_stats_fnc_statsIncrement

Description:
    Increment a stat for the given player and return the new stat.
    Function must be executed on server.

Parameters:
    String name:
        The name of the stat to increment.
    Object player:
        The player to increment for.
    Number amount:
        (Optional, default 1)
        The amount to increase the number by.

Returns:
    Number

Author:
    thegamecracks

*/
if (!isServer) exitWith {};
params ["_name", "_player", ["_amount", 1]];

private _uid = getPlayerUID _player;
if (_uid isEqualTo "") exitWith {diag_log text format [
    "%1: cannot increment stat of non-player object (%2)",
    _fnc_scriptName,
    _player
]};

private _var = format ["fdelta_stats_current_%1", _name];
private _stats = localNamespace getVariable _var;
if (isNil "_stats") exitWith {diag_log text format [
    "%1: invalid stat name %2",
    _fnc_scriptName,
    str _name
]};

private _value = _stats getOrDefault [_uid, 0] + _amount;
_stats set [_uid, _value];
_value
