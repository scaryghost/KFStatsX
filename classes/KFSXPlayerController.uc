class KFSXPlayerController extends KFPlayerController;

var KFSXLinkedReplicationInfo weaponLRI;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority) 
        weaponLRI;
}

simulated event PostBeginPlay() {
    local LinkedReplicationInfo lri;

    super.PostBeginPlay();
    if (Role == ROLE_Authority) {
        for(lri= PlayerReplicationInfo.CustomReplicationInfo; lri != none; lri= lri.NextReplicationInfo) {
            if (WeaponLRI(lri) != none) {
                weaponLRI= WeaponLRI(lri);
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
