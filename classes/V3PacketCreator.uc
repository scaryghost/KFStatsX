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
    parts[3]= string(byte(info.endGameType == 0 && !info.levelSwitching));
    if (info.endGameType == 2) {
        info.wave--;
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

function array<string> createWaveDataPacket(WaveData data) {
    local array<string> parts, packets;
    local int i;

    parts[0]= generateHeader(matchHeader);
    parts[1]= string(Level.Game.GetServerPort());
    parts[2]= "wave";
    parts[3]= string(data.wave);
    parts[4]= data.category;

    for(i= 0; i < data.perkData.Length; i++) {
        if (data.perkData[i].stats.maxStatIndex > 0) {
            parts[5]= GetItemName(string(data.perkData[i].perk));
            parts[6]= getStatValues(data.perkData[i].stats);
            packets[packets.Length]= join(parts, sectionSeparator);
        }
    }

    return packets;
}

function string createWaveSummaryPacket(PacketCreator.WaveSummary summary) {
    local array<string> parts;

    parts[0]= generateHeader(matchHeader);
    parts[1]= string(Level.Game.GetServerPort());
    parts[2]= "wave";
    parts[3]= string(summary.wave);
    parts[4]= "summary";
    parts[5]= string(summary.result);;
    parts[6]= string(summary.end - summary.start);
    parts[7]= getStatValues(summary.perks);

    return join(parts, sectionSeparator);
}

function string createMatchResultPacket(int wave, int elapsedTime, int endGameType) {
    local array<string> parts;

    if (endGameType == 2) {
        wave--;
    }
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

