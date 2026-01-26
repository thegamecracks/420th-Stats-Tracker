/*
Function: fdelta_stats_fnc_dbSyncLoop

Description:
    Periodically submit current stats to database and reset.
    Function must be executed in scheduled environment.

Author:
    thegamecracks

*/
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};
if !(localNamespace getVariable ["fdelta_stats_db_ready", false]) exitWith {};

private _serverID = "main"; // TODO: turn into CBA setting or something
while {true} do {
    sleep 300; // TODO: turn into CBA setting or something

    private _statCount = 0;
    try {
        private _stats = call fdelta_stats_fnc_statsReset;
        {
            private _statID = _x;
            private _playerStats = _y;
            {
                private _uid = _x;
                private _amount = _y;

                private _unit = _uid call BIS_fnc_getUnitByUID;
                private _name = name _unit; // may be "", converted to null

                private _args = [_uid, _name, _statID, _serverID, _amount];
                ["addPlayerStat", _args, false] call fdelta_stats_fnc_dbQuery;
                _statCount = _statCount + 1;

            } forEach _playerStats;

        } forEach _stats;

	} catch {
		diag_log text format [
            "%1: exception caught, dropping stats! %2",
            _fnc_scriptName,
            _exception
        ];
	};

    diag_log text format ["%1: %2 stat(s) submitted", _fnc_scriptName, _statCount];
};
