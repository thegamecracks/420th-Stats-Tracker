class CfgPatches {
    class fdelta_stats_main {
        name = "Stats Tracker";
        author = "thegamecracks";
        url = "https://github.com/thegamecracks/420th-Stats-Tracker";

        requiredVersion = 2.20;
        requiredAddons[] = {
        };
        skipWhenMissingDependencies = 0;

        units[] = {};
    };
};

class CfgFunctions {
    class fdelta_stats {
        class Database {
            file = "z\fdelta_stats\addons\main\Functions\Database";
            class dbInit { postInit = 1; };
            class dbQuery {};
            class dbStrip {};
            class dbSyncLoop {};
        };
        class Stats {
            file = "z\fdelta_stats\addons\main\Functions\Stats";
            class statsCurrent {};
            class statsIncrement {};
            class statsInit { postInit = 1; };
            class statsPlaytimeLoop {};
            class statsReset {};
            class statsRevivesLoop {};
            class statsTemplate {};
        };
    };
};
