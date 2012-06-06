class KFSXPlayerController extends KFPlayerController;

var KFSXLinkedPRI kfsxPRI;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority) 
        kfsxPRI;
}

simulated event PostBeginPlay() {
    local LinkedReplicationInfo lri;

    super.PostBeginPlay();
    if (Role == ROLE_Authority) {
        for(lri= PlayerReplicationInfo.CustomReplicationInfo; lri != none; lri= lri.NextReplicationInfo) {
            if (KFSXLinkedPRI(lri) != none) {
                kfsxPRI= KFSXLinkedPRI(lri);
                break;
            }
        }
    }
}

function SetPawnClass(string inClass, string inCharacter) {
    super.SetPawnClass(inClass, inCharacter);
    PawnClass = Class'KFSXHumanPawn';
}

exec function InGameStats() {
    ClientOpenMenu("KFStatsX.StatsMenu");
}
