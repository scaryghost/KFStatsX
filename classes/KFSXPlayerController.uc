/**
 * Custom controller used by the KFStatsX mutator
 * @author etsai (Scary Ghost)
 */
class KFSXPlayerController extends KFPlayerController;

var WeaponLRI weaponLRI;
var PlayerLRI playerLRI;
var KillsLRI killsLRI;
var HiddenLRI hiddenLRI;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority) 
        weaponLRI, playerLRI, killsLRI;
}

simulated event PostBeginPlay() {
    local LinkedReplicationInfo lri;

    super.PostBeginPlay();
    if (Role == ROLE_Authority) {
        for(lri= PlayerReplicationInfo.CustomReplicationInfo; lri != none; lri= lri.NextReplicationInfo) {
            if (WeaponLRI(lri) != none) {
                weaponLRI= WeaponLRI(lri);
            } else if (PlayerLRI(lri) != none) {
                playerLRI= PlayerLRI(lri);
            } else if (KillsLRI(lri) != none) {
                killsLRI= KillsLRI(lri);
            } else if (HiddenLRI(lri) != none) {
                hiddenLRI= HiddenLRI(lri);
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
