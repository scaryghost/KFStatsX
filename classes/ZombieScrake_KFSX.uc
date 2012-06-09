class ZombieScrake_KFSX extends KFChar.ZombieScrake;

var bool rageCounted;
var PlayerLRI instigatorLRI;
var float tempHealth;
var bool decapCounted;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, 
        class<DamageType> damageType, optional int HitIndex) {
    local float prevHealth, diffHealth;
    prevHealth= Health;

    if (InstigatedBy != none && KFSXPlayerController(InstigatedBy.Controller) != none) {
        instigatorLRI= KFSXPlayerController(InstigatedBy.Controller).playerLRI;
    }
    if (instigatorLRI != none && tempHealth == 0 && bBackstabbed) {
        instigatorLRI.accum(instigatorLRI.getKey(instigatorLRI.StatKeys.Backstabs), 1);
    }

    super.TakeDamage(Damage, InstigatedBy, Hitlocation, Momentum, damageType, HitIndex);

    diffHealth= prevHealth - fmax(Health, 0);
    if (decapCounted) {
        diffHealth-= tempHealth;
        tempHealth= 0;
    }
    if (instigatorLRI != none) {
        if (!decapCounted && bDecapitated) {
            instigatorLRI.accum(instigatorLRI.getKey(instigatorLRI.StatKeys.Decapitations), 1);
            decapCounted= true;
        }
        instigatorLRI.accum(instigatorLRI.getKey(instigatorLRI.StatKeys.Damage_Dealt), diffHealth);
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
        if (!rageCounted) {
            instigatorLRI.accum(instigatorLRI.getKey(instigatorLRI.StatKeys.Scrakes_Raged), 1);
            rageCounted= true;
        }
    }
}

function bool FlipOver() {
    if (super.FlipOver()) {
        if (Health > 0 && instigatorLRI != none) {
            instigatorLRI.accum(instigatorLRI.getKey(instigatorLRI.StatKeys.Scrakes_Stunned), 1);
        }
        return true;
    }

    return false;
}

