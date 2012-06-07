/**
 * Mutator to load in the KFStatsX modifications
 * @author etsai (Scary Ghost)
 */
class KFSXMutator extends Mutator;

/** Reference to the KFGameType object */
var KFGameType gametype;
/** Player controller class to use for KFStatsX */
var class<PlayerController> kfsxPC;
/** Linked replication info classes to attach to PRI */
var array<class<LinkedReplicationInfo> > lriList;

function PostBeginPlay() {
    gameType= KFGameType(Level.Game);
    if (gameType == none) {
        Destroy();
        return;
    }

    gameType.PlayerControllerClass= kfsxPC;
    gameType.PlayerControllerClassName= string(kfsxPC);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local int i;
    local PlayerReplicationInfo pri;
    local LinkedReplicationInfo lri;

    if (PlayerReplicationInfo(Other) != none && 
        PlayerReplicationInfo(Other).Owner != none) {
        
        pri= PlayerReplicationInfo(Other);
        for(i= 0; i < lriList.Length; i++) {
            lri= pri.spawn(lriList[i], pri.Owner);
            lri.NextReplicationInfo= pri.CustomReplicationInfo;
            pri.CustomReplicationInfo= lri;
        }
        return true;
    } else if (Frag(Other) != none) {
        Frag(Other).FireModeClass[0]= class'FragFire_KFSX';
        return true;
    } else if (Huskgun(Other) != none) {
        Huskgun(Other).FireModeClass[0]= class'HuskGunFire_KFSX';
    }

    return super.CheckReplacement(Other, bSuperRelevant);
}

defaultproperties {
    GroupName="KFStatX"
    FriendlyName="KFStatsX v1.0"
    Description="Tracks statistics for each player"

    bAddToServerPackages=true
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
    
    kfsxPC= class'KFSXPlayerController'
    lriList(0)= class'WeaponLRI'
    lriList(1)= class'PlayerLRI'
}
