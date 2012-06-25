/**
 * Custom fleshpound that tracks decapitations, backstabs, 
 * and how many times you raged it
 * @author etsai (Scary Ghost)
 */
class ZombieFleshPound_KFSX extends KFChar.ZombieFleshPound;

var String fleshpoundsRaged;
var KFSXReplicationInfo instigatorRI;
var float tempHealth;
var bool decapCounted;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, 
        class<DamageType> damageType, optional int HitIndex) {
    local float prevHealth, diffHealth;

    prevHealth= Health;
    if (InstigatedBy != none) {
        instigatorRI= class'KFSXReplicationInfo'.static.findKFSXri(InstigatedBy.PlayerReplicationInfo);
    }
    if (instigatorRI != none && tempHealth == 0 && bBackstabbed) {
        instigatorRI.actions.accum(instigatorRI.backstabs, 1);
    }

    super.TakeDamage(Damage, InstigatedBy, Hitlocation, Momentum, damageType, HitIndex);

    diffHealth= prevHealth - fmax(Health, 0);
    if (decapCounted) {
        diffHealth-= tempHealth;
        tempHealth= 0;
    }
    if (instigatorRI != none) {
        if (!decapCounted && bDecapitated) {
            instigatorRI.actions.accum(instigatorRI.decapitations, 1);
            decapCounted= true;
        }
    }
    if (instigatorRI != none) {
        instigatorRI.player.accum(instigatorRI.damage, diffHealth);
    }
}

function RemoveHead() {
    tempHealth= Health;
    super.RemoveHead();
    tempHealth-= fmax(Health, 0);
}

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
