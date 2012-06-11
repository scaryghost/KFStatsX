/**
 * Maintains the remote tracking server information and 
 * handles the packet broadcasting
 * @author etsai (Scary Ghost)
 */
class RemoteServerLink extends UDPLink;

/** UDP port number the packets are broadcasted from */
var int udpPort;
/** Address of the remote tracking server */
var IpAddr serverAddr;

/** Stores map name, difficulty, and length */
var string matchData;

/** Character to separate packet information */
var string separator;
/** Protocol name for the match informatiion scheme */
var string matchProtocol;
/** Version of the match informatiion scheme */
var string marchProtocolVersion;
/** Protocol name for the player informatiion scheme */
var string playerProtocol;
/** Version of the player informatiion scheme */
var string playerProtocolVersion;

/** Reference to the deaths object in KFSXGameRules */
var SortedMap deaths;

function PostBeginPlay() {
    udpPort= bindPort(class'KFSXMutator'.default.serverPort+1, true);
    if (udpPort > 0) Resolve(class'KFSXMutator'.default.serverAddress);
}

event Resolved(IpAddr addr) {
    serverAddr= addr;
    serverAddr.port= class'KFSXMutator'.default.serverPort;
}

/**
 * Initialize matchData with map name, difficulty, and length
 */
function MatchStarting() {
    matchData= Left(string(Level), InStr(string(Level), ".")) $ separator;
    matchData$= int(Level.Game.GameDifficulty) $ separator;
    matchData$= KFGameType(Level.Game).KFGameLength $ separator;
}

/**
 * Send the match information to the remote server
 */
function broadcastMatchResults() {
    local string matchPacket;
    matchPacket= matchProtocol $ "," $ marchProtocolVersion $ separator;
    matchPacket$= matchData;
    matchPacket$= Level.GRI.ElapsedTime $ separator;
    matchPacket$= KFGameReplicationInfo(Level.GRI).EndGameType $ separator;
    matchPacket$= KFGameType(Level.Game).WaveNum+1 $ separator;
    matchPacket$= getStatValues(deaths);
    SendText(serverAddr, "kfstatsx-pwd" $ separator $ class'KFSXMutator'.default.serverPwd);
    SendText(serverAddr, matchPacket);
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

/**
 * Broadcast the stats from the custom linked replication info objects
 * @param   pc  The controller to save
 */
function broadcastPlayerStats(KFSXPlayerController pc) {
    local string baseMsg;
    local array<string> statMsgs;
    local int index;


    pc.hiddenLRI.stats.put("Time Connected", Level.GRI.ElapsedTime - pc.PlayerReplicationInfo.StartTime);
    baseMsg= playerProtocol $ "," $ playerProtocolVersion $ separator $ "playerid:" $ pc.playerIDHash $ separator;

    statMsgs[statMsgs.Length]= "seq:0" $ separator $ "player" $ separator $ getStatValues(pc.playerLRI.stats);
    statMsgs[statMsgs.Length]= "seq:1" $ separator $ "weapon" $ separator $ getStatValues(pc.weaponLRI.stats);
    statMsgs[statMsgs.Length]= "seq:2" $ separator $ "kills" $ separator $ getStatValues(pc.killsLRI.stats);
    statMsgs[statMsgs.Length]= "seq:3" $ separator $ "hidden" $ separator $ getStatValues(pc.hiddenLRI.stats);
    statMsgs[statMsgs.Length]= "seq:4" $ separator $ "match" $ separator $ matchData $ 
        KFGameReplicationInfo(Level.GRI).EndGameType $ separator $ 
        KFGameType(Level.Game).WaveNum+1 $ separator $ "_close";
    SendText(serverAddr, "kfstatsx-pwd" $ separator $ class'KFSXMutator'.default.serverPwd);
    for(index= 0; index < statMsgs.Length; index++) {
        SendText(serverAddr, baseMsg $ statMsgs[index]);
    }
}

defaultproperties {
    separator= "|"
    matchProtocol= "kfstatsx-match";
    marchProtocolVersion= "1";
    playerProtocol= "kfstatsx-player";
    playerProtocolVersion= "1";
}
