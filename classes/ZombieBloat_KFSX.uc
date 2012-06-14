/**
 * Custom bloat that tracks decapitations and backstabs
 * @author etsai (Scary Ghost)
 */
class ZombieBloat_KFSX extends KFChar.ZombieBloat;

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
        instigatorLRI.playerInfo.accum(instigatorLRI.backstabs, 1);
    }

    super.TakeDamage(Damage, InstigatedBy, Hitlocation, Momentum, damageType, HitIndex);

    diffHealth= prevHealth - fmax(Health, 0);
    if (decapCounted) {
        diffHealth-= tempHealth;
        tempHealth= 0;
    }
    if (instigatorLRI != none) {
        if (!decapCounted && bDecapitated) {
            instigatorLRI.playerInfo.accum(instigatorLRI.decapitations, 1);
            decapCounted= true;
        }
    }
    if (instigatorLRI != none) {
        instigatorLRI.hiddenInfo.accum(instigatorLRI.damage, diffHealth);
    }
}

function RemoveHead() {
    tempHealth= Health;
    super.RemoveHead();
    tempHealth-= fmax(Health, 0);
}
