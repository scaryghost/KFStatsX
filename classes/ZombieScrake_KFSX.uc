/**
 * Custom scrake that tracks decapitations, backstabs, 
 * and how many times you stunned and raged it
 * @author etsai (Scary Ghost)
 */
class ZombieScrake_KFSX extends KFChar.ZombieScrake;

var String scrakesRaged, scrakesStunned;
var bool rageCounted;
var KFSXReplicationInfo instigatorRI;

state RunningState {
    function BeginState() {
        super.BeginState();
        if (!rageCounted && instigatorRI != none) {
            instigatorRI.actions.accum(scrakesRaged, 1);
            rageCounted= true;
        }
    }
}

function bool FlipOver() {
    if (super.FlipOver()) {
        if (Health > 0 && instigatorRI != none) {
            instigatorRI.actions.accum(scrakesStunned, 1);
        }
        return true;
    }

    return false;
}

defaultproperties {
    scrakesRaged= "Scrakes Raged"
    scrakesStunned= "Scrakes Stunned"
}
