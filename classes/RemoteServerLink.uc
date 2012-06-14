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
var string matchProtocolVersion;
/** Protocol name for the player informatiion scheme */
var string playerProtocol;
/** Version of the player informatiion scheme */
var string playerProtocolVersion;

var array<string> difficulties, lengths;

function PostBeginPlay() {
    local KFGameType gametype;
    local array<string> parts;
    local int i;

    udpPort= bindPort(class'KFSXMutator'.default.serverPort+1, true);
    if (udpPort > 0) Resolve(class'KFSXMutator'.default.serverAddress);

    gametype= KFGameType(Level.Game);
    Split(gametype.GIPropsExtras[0], ";", parts);
    for(i= 0; i < parts.Length; i+= 2)
        difficulties[int(parts[i])]= parts[i+1];
    Split(gametype.GIPropsExtras[1], ";", parts);
    for(i= 0; i < parts.Length; i+= 2)
        lengths[int(parts[i])]= parts[i+1];
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
    matchData$= difficulties[int(Level.Game.GameDifficulty)] $ separator;
    matchData$= lengths[KFGameType(Level.Game).KFGameLength] $ separator;
}

/**
 * Send the match information to the remote server
 */
function broadcastMatchResults(SortedMap deaths) {
    local string matchPacket;
    matchPacket= matchProtocol $ "," $ matchProtocolVersion $ separator;
    matchPacket$= matchData;
    matchPacket$= Level.GRI.ElapsedTime $ separator;
    matchPacket$= KFGameReplicationInfo(Level.GRI).EndGameType $ separator;
    matchPacket$= KFGameType(Level.Game).WaveNum+1 $ separator;
    matchPacket$= getStatValues(deaths) $ separator $ "_close";
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
function broadcastPlayerStats(PlayerReplicationInfo pri) {
    local string baseMsg;
    local array<string> statMsgs;
    local int index;
    local KFSXLinkedReplicationInfo lri;

    lri= class'KFSXLinkedReplicationInfo'.static.findKFSXlri(pri);
    lri.hiddenInfo.put("Time Connected", Level.GRI.ElapsedTime - pri.StartTime);
    baseMsg= playerProtocol $ "," $ playerProtocolVersion $ separator $ "playerid:" $ lri.playerIDHash $ separator;

    statMsgs[statMsgs.Length]= "seq:0" $ separator $ "player" $ separator $ getStatValues(lri.playerInfo);
    statMsgs[statMsgs.Length]= "seq:1" $ separator $ "weapon" $ separator $ getStatValues(lri.weaponInfo);
    statMsgs[statMsgs.Length]= "seq:2" $ separator $ "kills" $ separator $ getStatValues(lri.killsInfo);
    statMsgs[statMsgs.Length]= "seq:3" $ separator $ "hidden" $ separator $ getStatValues(lri.hiddenInfo);
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
    matchProtocolVersion= "1";
    playerProtocol= "kfstatsx-player";
    playerProtocolVersion= "1";
}
