/*
Function: fdelta_stats_fnc_dbStrip

Description:
    Remove all colons from the given string.

Parameters:
    String

Returns:
    String

Author:
    thegamecracks

*/
// https://github.com/SteezCram/extDB3/blob/master/Optional/legacy/original_source_code/sqf_examples/sqf/fn_strip.sqf
private _chars = toArray _this;
{
    if (_x == 58) then {
        _chars set [_forEachIndex, -1];
    };
} forEach _chars;
_chars = _chars - [-1];
toString _chars
