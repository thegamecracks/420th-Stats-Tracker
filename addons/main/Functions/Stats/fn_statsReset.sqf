/*
Function: fdelta_stats_fnc_statsReset

Description:
    Replace the hashmap of current stats with a new hashmap.
    Function must be executed on server.

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
if (!isServer) exitWith {};

private _old = localNamespace getVariable "fdelta_stats_current";
localNamespace setVariable ["fdelta_stats_current", call fdelta_stats_fnc_statsTemplate];
if (!isNil "_old") then {_old} else {call fdelta_stats_fnc_statsTemplate}
