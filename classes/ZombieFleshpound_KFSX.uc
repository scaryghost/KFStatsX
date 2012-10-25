/**
 * Custom fleshpound that tracks decapitations, backstabs, 
 * and how many times you raged it
 * @author etsai (Scary Ghost)
 */
class ZombieFleshPound_KFSX extends KFChar.ZombieFleshPound;

var String fleshpoundsRaged;
var KFSXReplicationInfo instigatorRI;

/** Copied from ZombieFleshPound */
function StartCharging() {
    local KFSXReplicationInfo targetRI;

    super.StartCharging();

    if(bFrustrated) {
        targetRI= class'KFSXReplicationInfo'.static.findKFSXri(Pawn(FleshpoundZombieController(Controller).Target).PlayerReplicationInfo);
    } else {
        targetRI= instigatorRI;
    }
    if (Health > 0 && targetRI != none) {
        targetRI.actions.accum(fleshpoundsRaged, 1);
    }
}

defaultproperties {
    fleshpoundsRaged= "Fleshpounds Raged"
    ControllerClass=class'FleshpoundZombieController_KFSX'
}
