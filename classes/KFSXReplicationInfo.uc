/**
 * Stores the custom stats information.  This does not extend from 
 * LinkedReplicationInfo due to compatibility issues with ServerPerksV5
 * @author etsai (Scary Ghost)
 */
class KFSXReplicationInfo extends ReplicationInfo
    dependson(SortedMap);

var PlayerReplicationInfo ownerPRI;
var String damage, welding;
var String backstabs, decapitations;

/** Map of values stored by this LRI */
var SortedMap player, actions, weapons, kills, perks;
var String playerIdHash;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority)
        player, actions, weapons, kills, ownerPRI;
}

function Tick(float DeltaTime) {
    super.Tick(DeltaTime);
    if (PlayerController(Owner) == Level.GetLocalPlayerController()) {
        playerIDHash= class'KFSXMutator'.default.localHostSteamId;
    } else {
        playerIDHash= PlayerController(Owner).GetPlayerIDHash();
    }

    Disable('Tick');
}

event PostBeginPlay() {
    super.PostBeginPlay();
    player= Spawn(class'SortedMap');
    weapons= Spawn(class'SortedMap');
    kills= Spawn(class'SortedMap');
    actions= Spawn(class'SortedMap');
    perks= Spawn(class'SortedMap');
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
    damage= "Damage"
    welding= "Welding"
    backstabs= "Backstabs"
    decapitations= "Decapitations"
}
