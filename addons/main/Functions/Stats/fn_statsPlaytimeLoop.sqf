/*
Function: fdelta_stats_fnc_statsPlaytimeLoop

Description:
    Continuously increment playtime statistics in minutes.
    Function must be executed in scheduled environment.

Author:
    thegamecracks

*/
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};

while {true} do {
    sleep 60;
    {["playtime", _x] call fdelta_stats_fnc_statsIncrement} forEach allPlayers;
};
