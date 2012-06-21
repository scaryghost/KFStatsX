/**
 * Based class for the custom linked replication information 
 * used by each stat group
 * @author etsai (Scary Ghost)
 */
class KFSXLinkedReplicationInfo extends LinkedReplicationInfo
    dependson(SortedMap);

var String damage, welding;
var String healedTeammates, healDartsConnected,
            backstabs, decapitations;

/** Map of values stored by this LRI */
var SortedMap player, actions, weapons, kills, perks;
var String playerIdHash;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority)
        player, actions, weapons, kills, perks;
}

function MatchStarting() {
    super.MatchStarting();
    if (PlayerController(Owner) == Level.GetLocalPlayerController()) {
        playerIDHash= class'KFSXMutator'.default.localHostSteamId;
    } else {
        playerIDHash= PlayerController(Owner).GetPlayerIDHash();
    }
}

event PostBeginPlay() {
    super.PostBeginPlay();
    player= Spawn(class'SortedMap');
    weapons= Spawn(class'SortedMap');
    kills= Spawn(class'SortedMap');
    actions= Spawn(class'SortedMap');
    perks= Spawn(class'SortedMap');
}

static function KFSXLinkedReplicationInfo findKFSXlri(PlayerReplicationInfo pri) {
    local LinkedReplicationInfo lri;
    for(lri= pri.CustomReplicationInfo; lri != none; lri= lri.NextReplicationInfo) {
        if (KFSXLinkedReplicationInfo(lri) != none)
            return KFSXLinkedReplicationInfo(lri);
    }
    return none;
}

defaultproperties {
    damage= "Damage"
    healedTeammates= "Healed Teammates"
    healDartsConnected= "Heal Darts Connected"
    welding= "Welding"
    backstabs= "Backstabs"
    decapitations= "Decapitations"
}
