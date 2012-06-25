/**
 * Custom fleshpound that tracks decapitations, backstabs, 
 * and how many times you raged it
 * @author etsai (Scary Ghost)
 */
class ZombieFleshPound_KFSX extends KFChar.ZombieFleshPound;

var String fleshpoundsRaged;
var KFSXReplicationInfo instigatorLRI;
var float tempHealth;
var bool decapCounted;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, 
        class<DamageType> damageType, optional int HitIndex) {
    local float prevHealth, diffHealth;

    prevHealth= Health;
    if (InstigatedBy != none) {
        instigatorLRI= class'KFSXReplicationInfo'.static.findKFSXri(InstigatedBy.PlayerReplicationInfo);
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

/** Copied from ZombieFleshPound */
function StartCharging() {
    local KFSXReplicationInfo targetLRI;

    super.StartCharging();

    if(bFrustrated) {
        targetLRI= class'KFSXReplicationInfo'.static.findKFSXri(Pawn(FleshpoundZombieController(Controller).Target).PlayerReplicationInfo);
    } else {
        targetLRI= instigatorLRI;
    }
    if (Health > 0 && targetLRI != none) {
        targetLRI.actions.accum(fleshpoundsRaged, 1);
    }
}

defaultproperties {
    fleshpoundsRaged= "Fleshpounds Raged"
    ControllerClass=class'FleshpoundZombieController_KFSX'
}
