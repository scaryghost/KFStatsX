/**
 * Stores the custom stats information.  This does not extend from 
 * LinkedReplicationInfo due to compatibility issues with ServerPerksV5
 * @author etsai (Scary Ghost)
 */
class KFSXReplicationInfo extends ReplicationInfo
    dependson(SortedMap);

var PlayerReplicationInfo ownerPRI;
var string timeSpectating;

/** Map of values stored by this LRI */
var SortedMap summary, actions, weapons, kills, perks, deaths;
var string playerIdHash;
var string fleshpoundsRaged, unknownKiller;
var int prevTime;
var bool survivedFinale, joinedDuringFinale;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority)
        summary, actions, weapons, kills, deaths, ownerPRI;
}

function Tick(float DeltaTime) {
    super.Tick(DeltaTime);
    if (PlayerController(Owner) == Level.GetLocalPlayerController()) {
        playerIDHash= class'KFSXMutator'.default.localHostSteamId;
    } else {
        playerIDHash= PlayerController(Owner).GetPlayerIDHash();
    }
    Disable('Tick');
    SetTimer(1.0, true);
}

function Timer() {
    local int currTime, timeDiff;

    super.Timer();
    currTime= Level.GRI.ElapsedTime;
    timeDiff= currTime - prevTime;
    if (ownerPRI != none && ownerPRI.bOnlySpectator) {
        summary.accum(timeSpectating, timeDiff);
    }
    prevTime= currTime;
}

event PostBeginPlay() {
    super.PostBeginPlay();
    summary= Spawn(class'SortedMap');
    weapons= Spawn(class'SortedMap');
    kills= Spawn(class'SortedMap');
    actions= Spawn(class'SortedMap');
    perks= Spawn(class'SortedMap');
    deaths= Spawn(class'SortedMap');
    prevTime= Level.GRI.ElapsedTime;
}

static function KFSXReplicationInfo findKFSXri(PlayerReplicationInfo pri) {
    local KFSXReplicationInfo repInfo;

    if (pri == none)
        return none;

    foreach pri.DynamicActors(Class'KFSXReplicationInfo', repInfo)
        if (repInfo.ownerPRI == pri)
            return repInfo;
 
    return none;
}

defaultproperties {
    fleshpoundsRaged= "Fleshpounds Raged"
    timeSpectating= "Time Spectating"
    unknownKiller= "Unknown"
    survivedFinale= true
}
