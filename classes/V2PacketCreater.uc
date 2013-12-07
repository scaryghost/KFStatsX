class V2PacketCreater extends PacketCreater;

var private PacketCreater.MatchInfo matchInformation;

function array<string> createPlayerPackets(KFSXReplicationInfo kfsxri, PacketCreater.PlayerInfo info) {
    local string baseMsg;
    local array<string> statMsgs, resultParts;
        
    baseMsg= generateHeader(playerHeader) $ separator $ kfsxri.playerIDHash $ separator;

    statMsgs[statMsgs.Length]= "0" $ separator $ "summary" $ separator $ getStatValues(kfsxri.summary);
    statMsgs[statMsgs.Length]= "1" $ separator $ "weapons" $ separator $ getStatValues(kfsxri.weapons);
    statMsgs[statMsgs.Length]= "2" $ separator $ "kills" $ separator $ getStatValues(kfsxri.kills);
    statMsgs[statMsgs.Length]= "3" $ separator $ "perks" $ separator $ getStatValues(kfsxri.perks);
    statMsgs[statMsgs.Length]= "4" $ separator $ "actions" $ separator $ getStatValues(kfsxri.actions);
    statMsgs[statMsgs.Length]= "5" $ separator $ "deaths" $ separator $ getStatValues(kfsxri.deaths);

    resultParts[0]= "6";
    resultParts[1]= "match";
    resultParts[2]= matchInformation.map;
    resultParts[3]= matchInformation.difficulty;
    resultParts[4]= matchInformation.length;
    if (info.levelSwitching && info.endGameType == 0) {
        resultParts[5]= "1";
    } else {
        resultParts[5]= string(info.endGameType);
    }
    resultParts[6]= string(info.wave);
    resultParts[7]= string(info.reachedFinalWave);
    resultParts[8]= string(info.survivedFinalWave);
    resultParts[9]= string(info.timeConnected);
    resultParts[10]= "_close";
    statMsgs[statMsgs.Length]= join(resultParts, separator);

    return statMsgs;
}

function string createWaveInfoPacket(SortedMap stats, int wave, string category) {
    local array<string> packetParts;

    packetParts[0]= generateHeader(matchHeader);
    packetParts[1]= category;
    packetParts[2]= matchInformation.difficulty;
    packetParts[3]= matchInformation.length;
    packetParts[4]= string(wave);
    packetParts[5]= matchInformation.map;
    packetParts[6]= getStatValues(stats);
    packetParts[7]= "_close";

    return join(packetParts, separator);
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
    return join(matchParts, separator);
}

function string createMatchInfoPacket(PacketCreater.MatchInfo info) {
    matchInformation= info;
    return "";
}

defaultproperties {
    matchHeader=(version=2,protocol="kfstatsx-match")
    playerHeader=(version=2,protocol="kfstatsx-player")
}
