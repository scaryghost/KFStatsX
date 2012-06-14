/**
 * Based class for the custom linked replication information 
 * used by each stat group
 * @author etsai (Scary Ghost)
 */
class KFSXLinkedReplicationInfo extends LinkedReplicationInfo
    dependson(SortedMap);

var String damage, deaths, suicides;
var String healedTeammates, healDartsConnected, welding,
            backstabs, decapitations;

/** Map of values stored by this LRI */
var SortedMap playerInfo, weaponInfo, killsInfo, hiddenInfo;
var String playerIdHash;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority)
        playerInfo, weaponInfo, killsInfo;
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
    playerInfo= Spawn(class'SortedMap');
    weaponInfo= Spawn(class'SortedMap');
    killsInfo= Spawn(class'SortedMap');
    hiddenInfo= Spawn(class'SortedMap');
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
    deaths= "Deaths"
    suicides= "Suicides"
    healedTeammates= "Healed Teammates"
    healDartsConnected= "Heal Darts Connected"
    welding= "Welding"
    backstabs= "Backstabs"
    decapitations= "Decapitations"
}
