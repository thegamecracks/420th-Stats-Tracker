/*
Function: fdelta_stats_fnc_dbInit

Description:
    Initialize the extDB3 connection, if available.

Author:
    thegamecracks

*/
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};

private _version = "extDB3" callExtension "9:VERSION";
if (_version isEqualTo "") exitWith {diag_log text format [
    "%1: extDB3 not available, database synchronization disabled",
    _fnc_scriptName
]};

diag_log text format [
    "%1: setting up extDB3 database (version %2)",
    _fnc_scriptName,
    _version
];

private _databaseReady = false;
if ("extDB3" callExtension "9:LOCK_STATUS" isEqualTo "[1]") then {
    // A mission reload probably occurred, verify that our protocol exists
    private _ret = parseSimpleArray ("extDB3" callExtension "0:fdelta_stats:getProtocolVersion");
    private _message = "%1: database is locked and unable to be configured";
    if (_ret # 0 isNotEqualTo 0) then {
        _message = "%1: database is locked but appears to be configured, finishing setup";
        _databaseReady = true;
    };
    diag_log text format [_message, _fnc_scriptName];
} else {
    private _ret = "extDB3" callExtension "9:ADD_DATABASE:fdelta_stats_db";
    if (_ret isNotEqualTo "[1]") exitWith {diag_log text format [
        "%1: extDB3 ADD_DATABASE failed with: %2",
        _fnc_scriptName,
        _ret
    ]};

    _ret = "extDB3" callExtension "9:ADD_DATABASE_PROTOCOL:fdelta_stats_db:SQL_CUSTOM:fdelta_stats:fdelta_stats.ini";
    if (_ret isNotEqualTo "[1]") exitWith {diag_log text format [
        "%1: extDB3 ADD_DATABASE_PROTOCOL failed with: %2",
        _fnc_scriptName,
        _ret
    ]};

    diag_log text format [
        "%1: extDB3 OUTPUTSIZE: %2",
        _fnc_scriptName,
        "extDB3" callExtension "9:OUTPUTSIZE"
    ];
    diag_log text format [
        "%1: extDB3 LOCK: %2",
        _fnc_scriptName,
        "extDB3" callExtension "9:LOCK"
    ];
    _databaseReady = true;
};

localNamespace setVariable ["fdelta_stats_db_ready", _databaseReady];
0 spawn fdelta_stats_fnc_dbSyncLoop;
