/**
 * Custom scrake that tracks decapitations, backstabs, 
 * and how many times you stunned and raged it
 * @author etsai (Scary Ghost)
 */
class ZombieScrake_KFSX extends KFChar.ZombieScrake;

var String scrakesRaged, scrakesStunned;
var bool rageCounted;
var KFSXLinkedReplicationInfo instigatorLRI;
var float tempHealth;
var bool decapCounted;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, 
        class<DamageType> damageType, optional int HitIndex) {
    local float prevHealth, diffHealth;

    prevHealth= Health;
    if (InstigatedBy != none) {
        instigatorLRI= class'KFSXLinkedReplicationInfo'.static.findKFSXlri(InstigatedBy.PlayerReplicationInfo);
    }
    if (instigatorLRI != none && tempHealth == 0 && bBackstabbed) {
        instigatorLRI.actions.accum(instigatorLRI.backstabs, 1);
    }

    super.TakeDamage(Damage, InstigatedBy, Hitlocation, Momentum, damageType, HitIndex);

    diffHealth= prevHealth - fmax(Health, 0);
    if (decapCounted) {
        diffHealth-= tempHealth;
        tempHealth= 0;
    }
    if (instigatorLRI != none) {
        if (!decapCounted && bDecapitated) {
            instigatorLRI.actions.accum(instigatorLRI.decapitations, 1);
            decapCounted= true;
        }
    }
    if (instigatorLRI != none) {
        instigatorLRI.player.accum(instigatorLRI.damage, diffHealth);
    }
}

function RemoveHead() {
    tempHealth= Health;
    super.RemoveHead();
    tempHealth-= fmax(Health, 0);
}

state RunningState {
    function BeginState() {
        super.BeginState();
        if (!rageCounted && instigatorLRI != none) {
            instigatorLRI.actions.accum(scrakesRaged, 1);
            rageCounted= true;
        }
    }
}

function bool FlipOver() {
    if (super.FlipOver()) {
        if (Health > 0 && instigatorLRI != none) {
            instigatorLRI.actions.accum(scrakesStunned, 1);
        }
        return true;
    }

    return false;
}

defaultproperties {
    scrakesRaged= "Scrakes Raged"
    scrakesStunned= "Scrakes Stunned"
}
