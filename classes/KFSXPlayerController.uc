/**
 * Custom controller used by the KFStatsX mutator
 * @author etsai (Scary Ghost)
 */
class KFSXPlayerController extends KFPlayerController;

/** Weapon usage */
var WeaponLRI weaponLRI;
/** Player actions and summary */
var PlayerLRI playerLRI;
/** Kill count */
var KillsLRI killsLRI;
/** Stats hidden from the player */
var HiddenLRI hiddenLRI;
/** SteamID of the player */
var String playerIdHash;

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

function MatchStarting() {
    super.MatchStarting();
    if (Self == Level.GetLocalPlayerController()) {
        playerIDHash= class'KFSXMutator'.default.localHostSteamId;
    } else {
        playerIDHash= GetPlayerIDHash();
    }
}

function SetPawnClass(string inClass, string inCharacter) {
    super.SetPawnClass(inClass, inCharacter);
    PawnClass = Class'KFSXHumanPawn';
}

/**
 * Custom console command to bring up the stats menu
 */
exec function InGameStats() {
    ClientOpenMenu("KFStatsX.StatsMenu");
}
