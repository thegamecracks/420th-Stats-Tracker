/*
Function: fdelta_stats_fnc_statsTrackTransportsOnGetInMan

Description:
    Handle a player entering a vehicle for transport stats.
    Function must be executed on server.

Parameters:
    Object unit:
        The player that entered the vehicle.
    String role:
        The vehicle role that the unit entered.
    Object vehicle:
        The vehicle that was entered.

Author:
    thegamecracks

*/
params ["_unit", "", "_vehicle"];
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};
if (!isPlayer _unit) exitWith {};

_unit setVariable ["fdelta_stats_transport", [getPosATL _vehicle]];
