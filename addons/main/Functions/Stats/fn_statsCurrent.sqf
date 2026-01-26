/*
Function: fdelta_stats_fnc_statsCurrent

Description:
    Return a hashmap of current stats being tracked.
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
if (isRemoteExecuted) exitWith {};
if (localNamespace isNil "fdelta_stats_current") then {call fdelta_stats_fnc_statsReset};
fdelta_stats_current
