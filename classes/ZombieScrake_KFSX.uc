class ZombieScrake_KFSX extends KFChar.ZombieScrake;

var bool rageCounted;
var PlayerLRI instigatorLRI;
var float tempHealth;
var bool decapCounted;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, 
        class<DamageType> damageType, optional int HitIndex) {
    local float prevHealth, diffHealth;
    local HiddenLRI hiddenLRI;

    prevHealth= Health;
    if (InstigatedBy != none && KFSXPlayerController(InstigatedBy.Controller) != none) {
        instigatorLRI= KFSXPlayerController(InstigatedBy.Controller).playerLRI;
        hiddenLRI= KFSXPlayerController(InstigatedBy.Controller).hiddenLRI;
    }
    if (instigatorLRI != none && tempHealth == 0 && bBackstabbed) {
        instigatorLRI.stats.accum(instigatorLRI.getKey(instigatorLRI.StatKeys.Backstabs), 1);
    }

    super.TakeDamage(Damage, InstigatedBy, Hitlocation, Momentum, damageType, HitIndex);

    diffHealth= prevHealth - fmax(Health, 0);
    if (decapCounted) {
        diffHealth-= tempHealth;
        tempHealth= 0;
    }
    if (instigatorLRI != none) {
        if (!decapCounted && bDecapitated) {
            instigatorLRI.stats.accum(instigatorLRI.getKey(instigatorLRI.StatKeys.Decapitations), 1);
            decapCounted= true;
        }
    }
    if (hiddenLRI != none) {
        hiddenLRI.stats.accum(hiddenLRI.DAMAGE, diffHealth);
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
            instigatorLRI.stats.accum(instigatorLRI.getKey(instigatorLRI.StatKeys.Scrakes_Raged), 1);
            rageCounted= true;
        }
    }
}

function bool FlipOver() {
    if (super.FlipOver()) {
        if (Health > 0 && instigatorLRI != none) {
            instigatorLRI.stats.accum(instigatorLRI.getKey(instigatorLRI.StatKeys.Scrakes_Stunned), 1);
        }
        return true;
    }

    return false;
}
