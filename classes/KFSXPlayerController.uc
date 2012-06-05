class KFSXPlayerController extends KFPlayerController;

var KFSXLinkedPRI kfsxPRI;

event PostBeginPlay() {
    local LinkedReplicationInfo lri;

    super.PostBeginPlay();
    for(lri= PlayerReplicationInfo.CustomReplicationInfo; lri != none; lri= lri.NextReplicationInfo) {
        if (KFSXLinkedPRI(lri) != none) {
            kfsxPRI= KFSXLinkedPRI(lri);
            break;
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
