/**
 * Maintains the remote tracking server information and 
 * handles the packet broadcasting
 * @author etsai (Scary Ghost)
 */
class RemoteServerLink extends UDPLink
    dependson(PacketCreator);

/** UDP port number the packets are broadcasted from */
var int udpPort;
/** Address of the remote tracking server */
var IpAddr serverAddr;

var PacketCreator packetCreator;

var array<string> difficulties, lengths;
var string matchHeader, playerHeader;
var string killsKey, assistsKey;

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
    local PacketCreator.MatchInfo info;
    local string matchInfoPacket;

    info.map= locs(Left(string(Level), InStr(string(Level), ".")));
    info.difficulty= difficulties[int(Level.Game.GameDifficulty)];
    if (KFStoryGameInfo(Level.Game) != none) {
        info.length= "Objective";
    } else {
        info.length= lengths[KFGameType(Level.Game).KFGameLength];
    }
    
    matchInfoPacket= packetCreator.createMatchInfoPacket(info);
    if (Len(matchInfoPacket) > 0) {
        SendText(serverAddr, matchInfoPacket);
    }
}

/**
 * Send the match information to the remote server
 */
function broadcastMatchResults() {
    SendText(serverAddr, packetCreator.createMatchResultPacket(KFGameType(Level.Game).WaveNum + 1,
            Level.GRI.ElapsedTime, KFGameReplicationInfo(Level.GRI).EndGameType));
}

function broadcastWaveData(WaveData data) {
    local array<string> packets;
    local int i;

    packets= packetCreator.createWaveDataPacket(data);
    for(i= 0; i < packets.Length; i++) {
        SendText(serverAddr, packets[i]);
    }
}

function broadcastWaveSummary(PacketCreator.WaveSummary summary) {
    local string packet;

    packet= packetCreator.createWaveSummaryPacket(summary);
    if (Len(packet) != 0) {
        SendText(serverAddr, packet);
    }
}

/**
 * Send wave specific stats to the remote server
 */
function broadcastWaveInfo(SortedMap stats, int wave, string group) {
    local WaveData data;
    local int i;
    local array<string> packets;

    data= Spawn(class'WaveData');
    data.wave= wave;
    data.category= group;
    data.perkData.Length= 1;
    data.perkData[0].stats= stats;

    packets= packetCreator.createWaveDataPacket(data);
    for(i= 0; i < packets.Length; i++) {
        SendText(serverAddr, packets[i]);
    }
}

/**
 * Broadcast the stat objects from the custom replication info tied to the given pri
 * @param   pri  The PlayerReplicationInfo object to save
 */
function broadcastPlayerStats(PlayerReplicationInfo pri) {
    local KFSXReplicationInfo kfsxri;
    local PacketCreator.PlayerInfo info;
    local int timeConnected, i;
    local array<string> packets;

    timeConnected= Level.GRI.ElapsedTime - pri.StartTime;
    kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(pri);
    if (!kfsxri.joinedDuringFinale && timeConnected > 0 && !(pri.bOutOfLives && pri.Deaths == 0)) {
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
        info.steamID64= kfsxri.playerIDHash;

        info.stats.Length= 6;
        info.stats[0].category= "summary";
        info.stats[0].statsMap= kfsxri.summary;
        info.stats[1].category= "weapons";
        info.stats[1].statsMap= kfsxri.weapons;
        info.stats[2].category= "kills";
        info.stats[2].statsMap= kfsxri.kills;
        info.stats[3].category= "perks";
        info.stats[3].statsMap= kfsxri.perks;
        info.stats[4].category= "actions";
        info.stats[4].statsMap= kfsxri.actions;
        info.stats[5].category= "deaths";
        info.stats[5].statsMap= kfsxri.deaths;
        
        packets= packetCreator.createPlayerPackets(info);
        for(i= 0; i < packets.Length; i++) {
            SendText(serverAddr, packets[i]);
        }
    }
}

defaultproperties {
    killsKey= "Kills"
    assistsKey= "Kill Assists"
}
