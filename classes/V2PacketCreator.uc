class V2PacketCreator extends PacketCreator;

var private PacketCreator.MatchInfo matchInformation;

function array<string> createPlayerPackets(PacketCreator.PlayerInfo info) {
    local string baseMsg;
    local int i;
    local array<string> packets, parts;
        
    baseMsg= generateHeader(playerHeader) $ sectionSeparator $ info.steamID64;

    parts[0]= baseMsg;
    for(i= 0; i < info.stats.Length; i++) {
        parts[1]= string(i);
        parts[2]= info.stats[i].category;
        parts[3]= getStatValues(info.stats[i].statsMap);
        packets[i]= join(parts, sectionSeparator);
    }

    parts[1]= string(packets.Length);
    parts[2]= "match";
    parts[3]= matchInformation.map;
    parts[4]= matchInformation.difficulty;
    parts[5]= matchInformation.length;
    if (info.levelSwitching && info.endGameType == 0) {
        parts[6]= "1";
    } else {
        parts[6]= string(info.endGameType);
    }
    parts[7]= string(info.wave);
    parts[8]= string(info.reachedFinalWave);
    parts[9]= string(info.survivedFinalWave);
    parts[10]= string(info.timeConnected);
    parts[11]= "_close";
    packets[packets.Length]= join(parts, sectionSeparator);

    return packets;
}

function array<string> createWaveDataPacket(WaveData data) {
    local array<string> packetParts, packets;
    local int i;

    packetParts[0]= generateHeader(matchHeader);
    packetParts[1]= data.category;
    packetParts[2]= matchInformation.difficulty;
    packetParts[3]= matchInformation.length;
    packetParts[4]= string(data.wave);
    packetParts[5]= matchInformation.map;
    packetParts[7]= "_close";

    for(i= 0; i < data.perkData.Length; i++) {
        packetParts[6]= getStatValues(data.perkData[i].stats);
        packets[packets.Length]= join(packetParts, sectionSeparator);
    }

    return packets;
}

function string createMatchResultPacket(int wave, int elapsedTime, int endGameType) {
    local array<string> matchParts;

    matchParts[0]= generateHeader(matchHeader);
    matchParts[1]= "result";
    matchParts[2]= matchInformation.difficulty;
    matchParts[3]= matchInformation.length;
    matchParts[4]= string(wave);
    matchParts[5]= matchInformation.map;
    matchParts[6]= string(elapsedTime);
    if (endGameType == 0) {
        matchParts[7]= "1";
    } else {
        matchParts[7]= string(endGameType);
    }
    matchParts[8]= "_close";
    return join(matchParts, sectionSeparator);
}

function string createMatchInfoPacket(PacketCreator.MatchInfo info) {
    matchInformation= info;
    return "";
}

defaultproperties {
    matchHeader=(version=2,protocol="kfstatsx-match")
    playerHeader=(version=2,protocol="kfstatsx-player")
}
