/*
Function: fdelta_stats_fnc_dbQuery

Description:
    Run the given prepared statement asynchronously and optionally return its result.
    Function must be executed on server.

Parameters:
    String function:
        The function to run.
    Array args:
        The arguments to pass to the function.
        Note that nested arrays must be converted into strings beforehand.
    Boolean wait:
        (Optional, default true)
        If enabled, waits for the query to return a response.
        This requires the script to be running in scheduled envrionment.

Returns:
    String
        Whatever response was given, or an empty string if wait is false.

Author:
    thegamecracks

*/
// https://github.com/SteezCram/extDB3/blob/master/Optional/legacy/original_source_code/sqf_examples/sqf/fn_async_custom.sqf
if (!isServer) exitWith {};
if (isRemoteExecuted) exitWith {};
params ["_function", ["_args", []], ["_wait", true]];

private _debug = false; // TODO: turn into CBA setting or something

private _mode = ["1", "2"] select _wait;
private _query = [_function] + (_args apply {str _x call fdelta_stats_fnc_dbStrip}) joinString ":";
private _args = format ["%1:fdelta_stats:%2", _mode, _query];

if (_debug) then {diag_log text format ["%1: Executing query %2", _fnc_scriptName, _query]};
private _key = "extDB3" callExtension _args;

if (!_wait) exitWith {""};
parseSimpleArray _key params ["_type", "_key"];
if (_type isNotEqualTo 2) exitWith {throw format [
    "%1: Failed to execute query %2 (type %3, data %4)",
    _fnc_scriptName,
    _query,
    _type,
    _key
]};

uiSleep random .03;

private _result = "";
for "_i" from 0 to 1 step 0 do {
    private _message = "extDB3" callExtension format ["4:%1", _key];

    if (_message isEqualTo "") exitWith {throw format [
        "%1: No response received for query %2",
        _fnc_scriptName,
        _query
    ]};

    if (_debug) then {diag_log text format [
        "%1: Query %2 received ""%3""",
        _fnc_scriptName,
        _query,
        _message
    ]};
    _message = parseSimpleArray _message;

    switch (_message # 0) do {
        case 0: {
            throw format [
                "%1: Query %2 failed with %3",
                _fnc_scriptName,
                _query,
                str (_message # 1)
            ];
            break;
        };
        case 1: {
            _result = _message # 1;
            break;
        };
        case 3: {
            uiSleep 0.1;
        };
        case 5: {
            private _pipe = "extDB3" callExtension format ["5:%1", _key];
            while {_pipe isNotEqualTo ""} do {
                _result = _result + _pipe;
                _pipe = "extDB3" callExtension format ["5:%1", _key];
            };
            _result = parseSimpleArray _result select 1;
            if (_debug) then {diag_log text format [
                "%1: Query %2 received multipart ""%3""",
                _fnc_scriptName,
                _query,
                str _result
            ]};
            break;
        };
        default {
            throw format ["%1: Unexpected response %2 for query %3", _fnc_scriptName, _message, _query];
            break;
        };
    };
};
_result
