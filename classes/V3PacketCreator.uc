class V3PacketCreator extends PacketCreator;

function array<string> createPlayerPackets(PacketCreator.PlayerInfo info) {
    local string baseMsg;
    local int i;
    local array<string> packets, parts;
    
    baseMsg= generateHeader(playerHeader) $ sectionSeparator $ Level.Game.GetServerPort() $ 
            sectionSeparator $ info.steamID64;

    parts[0]= baseMsg;
    for(i= 0; i < info.stats.Length; i++) {
        parts[1]= string(i);
        parts[2]= info.stats[i].category;
        parts[3]= getStatValues(info.stats[i].statsMap);
        packets[i]= join(parts, sectionSeparator);
    }

    parts[1]= string(packets.Length);
    parts[2]= "match";
    if (info.levelSwitching && info.endGameType == 0) {
        parts[3]= "1";
    } else {
        parts[3]= string(info.endGameType);
    }
    parts[4]= string(info.wave);
    parts[5]= string(info.reachedFinalWave);
    parts[6]= string(info.survivedFinalWave);
    parts[7]= string(info.timeConnected);
    parts[8]= "_close";
    packets[packets.Length]= join(parts, sectionSeparator);

    return packets;
}

function string createMatchInfoPacket(PacketCreator.MatchInfo info) {
    local array<string> parts;

    parts[0]= generateHeader(matchHeader);
    parts[1]= string(Level.Game.GetServerPort());
    parts[2]= "info";
    parts[3]= info.difficulty;
    parts[4]= info.length;
    parts[5]= info.map;
    return join(parts, sectionSeparator);
}

function string createWaveInfoPacket(SortedMap stats, int wave, string category) {
    local array<string> parts;

    parts[0]= generateHeader(matchHeader);
    parts[1]= string(Level.Game.GetServerPort());
    parts[2]= category;
    parts[3]= string(wave);
    parts[4]= getStatValues(stats);
    return join(parts, sectionSeparator);
}

function string createMatchResultPacket(int wave, int elapsedTime, int endGameType) {
    local array<string> parts;

    parts[0]= generateHeader(matchHeader);
    parts[1]= string(Level.Game.GetServerPort());
    parts[2]= "result";
    parts[3]= string(wave);
    parts[4]= string(elapsedTime);
    parts[5]= string(endGameType);
    return join(parts, sectionSeparator);
}

defaultproperties {
    matchHeader=(version=3,protocol="kfstatsx-match")
    playerHeader=(version=3,protocol="kfstatsx-player")
}

