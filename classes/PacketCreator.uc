class PacketCreator extends Object
    abstract;

struct Header {
    var int version;
    var string protocol;
};

struct MatchInfo {
    var string difficulty, length, map;
    var array<string> mutators;
};

struct PlayerStats {
    var string category;
    var SortedMap statsMap;
};

struct PlayerInfo {
    var int wave, timeConnected, endGameType;
    var byte reachedFinalWave, survivedFinalWave;
    var bool levelSwitching;
    var string steamID64;
    var array<PlayerStats> stats;
};

var Header matchHeader, playerHeader;
var string sectionSeparator, password;

function array<string> createPlayerPackets(PacketCreator.PlayerInfo info);
function string createWaveInfoPacket(SortedMap stats, int wave, string category);
function string createMatchResultPacket(int wave, int elapsedTime, int endGameType);
function string createMatchInfoPacket(PacketCreator.MatchInfo info);

function string generateHeader(Header header) {
    return header.protocol $ "," $ header.version $ "," $ password;
}

/**
 * Convert the entries in the SortedMap into 
 * comma separated ${key}=${value} pairs
 */
function string getStatValues(SortedMap stats) {
    local string statVals;
    local int i;
    local bool addComma;

    for(i= 0; i < stats.maxStatIndex; i++) {
        if (stats.values[i] != 0) {
            if (addComma) statVals$= ",";
            statVals$= stats.keys[i] $ "=" $ int(round(stats.values[i]));
            addComma= true;
        }
    }
    return statVals;
}

function string join(array<string> parts, string separator) {
    local int i;
    local string whole;

    for(i= 0; i < parts.Length; i++) {
        if (i != 0) {
            whole$= separator;
        }
        whole$= parts[i];
    }
    return whole;
}

defaultproperties {
    sectionSeparator= "|";
}
