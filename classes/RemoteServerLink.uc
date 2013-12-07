/**
 * Maintains the remote tracking server information and 
 * handles the packet broadcasting
 * @author etsai (Scary Ghost)
 */
class RemoteServerLink extends UDPLink
    dependson(PacketCreater);

/** UDP port number the packets are broadcasted from */
var int udpPort;
/** Address of the remote tracking server */
var IpAddr serverAddr;

var PacketCreater packetCreater;

var array<string> difficulties, lengths;
var string matchHeader, playerHeader;
var string killsKey, assistsKey;

/** True if a stat packet has been broadcasted */
var bool broadcastedStatPacket;

function PostBeginPlay() {
    local KFGameType gametype;
    local array<string> parts;
    local int i;

    udpPort= BindPort();
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
    local PacketCreater.MatchInfo info;
    local Mutator mutIt;
    local string matchInfoPacket;

    info.map= locs(Left(string(Level), InStr(string(Level), ".")));
    info.difficulty= difficulties[int(Level.Game.GameDifficulty)];
    if (KFStoryGameInfo(Level.Game) != none) {
        info.length= "Objective";
    } else {
        info.length= lengths[KFGameType(Level.Game).KFGameLength];
    }
    
    for(mutIt= Level.Game.BaseMutator; mutIt != None; mutIt= mutIt.NextMutator) {
        info.mutators[info.mutators.Length]= mutIt.FriendlyName;
    }
    matchInfoPacket= packetCreater.createMatchInfoPacket(info);
    if (Len(matchInfoPacket) > 0) {
        SendText(serverAddr, matchInfoPacket);
    }
}

/**
 * Send the match information to the remote server
 */
function broadcastMatchResults() {
    SendText(serverAddr, packetCreater.createMatchResultPacket(KFGameType(Level.Game).WaveNum + 1, 
            Level.GRI.ElapsedTime, KFGameReplicationInfo(Level.GRI).EndGameType));
}

/**
 * Send wave specific stats to the remote server
 */
function broadcastWaveInfo(SortedMap stats, int wave, string group) {
    broadcastedStatPacket= true;
    SendText(serverAddr, packetCreater.createWaveInfoPacket(stats, wave, group));
}

/**
 * Broadcast the stat objects from the custom replication info tied to the given pri
 * @param   pri  The PlayerReplicationInfo object to save
 */
function broadcastPlayerStats(PlayerReplicationInfo pri) {
    local KFSXReplicationInfo kfsxri;
    local PacketCreater.PlayerInfo info;
    local int timeConnected, i;
    local array<string> packets;

    timeConnected= Level.GRI.ElapsedTime - pri.StartTime;
    if (timeConnected > 0 && !(pri.bOutOfLives && pri.Deaths == 0)) {
        kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(pri);
        if (KFPlayerReplicationInfo(pri) != none) {
            kfsxri.summary.put(assistsKey, KFPlayerReplicationInfo(pri).KillAssists);
        }
        kfsxri.summary.put(killsKey, pri.Kills);

        info.timeConnected= timeConnected;
        info.wave= KFGameType(Level.Game).WaveNum + 1;
        info.reachedFinalWave= byte(info.wave > KFGameType(Level.Game).FinalWave);
        info.survivedFinalWave= byte(!pri.bOnlySpectator && kfsxri.survivedFinale && 
                (info.reachedFinalWave != 0));
        info.endGameType= KFGameReplicationInfo(Level.GRI).EndGameType;
        info.levelSwitching= xVotingHandler(Level.Game.VotingHandler) != none && 
                xVotingHandler(Level.Game.VotingHandler).bLevelSwitchPending;

        packets= packetCreater.createPlayerPackets(kfsxri, info);
        for(i= 0; i < packets.Length; i++) {
            SendText(serverAddr, packets[i]);
        }
        broadcastedStatPacket= true;
    }
}

defaultproperties {
    killsKey= "Kills"
    assistsKey= "Kill Assists"
}
