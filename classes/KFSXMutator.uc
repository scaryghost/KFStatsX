class KFSXMutator extends Mutator;

var KFGameType gametype;
var class<PlayerController> kfsxPC;

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
    local PlayerReplicationInfo pri;
    local LinkedReplicationInfo lri;

    if (PlayerReplicationInfo(Other) != none && 
        PlayerReplicationInfo(Other).Owner != none) {
        
        pri= PlayerReplicationInfo(Other);
        lri= pri.spawn(class'KFSXLinkedPRI', pri.Owner);
        lri.NextReplicationInfo= pri.CustomReplicationInfo;
        pri.CustomReplicationInfo= lri;
    } else if (Frag(Other) != none) {
        Frag(Other).FireModeClass[0]= class'FragFire_KFSX';
    }

    return super.CheckReplacement(Other, bSuperRelevant);
}

defaultproperties {
    GroupName="KFStatX"
    FriendlyName="KFStatsX v1.0"
    Description="Tracks statistics for each player"
    kfsxPC= class'KFSXPlayerController'
}
