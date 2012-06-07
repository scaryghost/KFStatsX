/**
 * Custom pawn class used by the KFStatsX mutator.  
 * Injects stat tracking code above the KFHumanPawn class 
 * to log events such as money spent, damage taken, etc...
 * @author etsai (Scary Ghost)
 */
class KFSXHumanPawn extends KFHumanPawn;

var float prevHealth, prevShield;
var PlayerLRI playerLRI;

function Timer() {
    super.Timer();
    if (playerLRI == none) {
        playerLRI= KFSXPlayerController(Controller).playerLRI;
    }
}

function DeactivateSpawnProtection() {
    local int mode;
    local string itemName;
    local float load;
    super.DeactivateSpawnProtection();
    
    if (Weapon.isFiring() && Syringe(Weapon) == none && 
            Welder(Weapon) == none && Huskgun(Weapon) == none) {
        itemName= Weapon.ItemName;
        if (Weapon.GetFireMode(1).bIsFiring)
            mode= 1;

        if (KFMeleeGun(Weapon) != none || (mode == 1 && MP7MMedicGun(Weapon) != none)) {
            load= 1;
        } else {
            load= Weapon.GetFireMode(mode).Load;
        }

        if (mode == 1 && (MP7MMedicGun(Weapon) != none || 
                (KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo))) {
            itemName$= " Alt";
        }

        KFSXPlayerController(Controller).weaponLRI.accum(itemName, load);
    }
}

simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, 
        Vector Momentum, class<DamageType> damageType, optional int HitIndex) {
    local float oldHealth;
    local float oldShield;

    oldHealth= Health;
    prevHealth= oldHealth;
    oldShield= ShieldStrength;
    prevShield= oldShield;

    Super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
   
    playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Damage_Taken), 
            oldHealth - fmax(Health,0.0));
    playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Armor_Lost), 
            oldShield - fmax(ShieldStrength,0.0));
    prevHealth= 0;
    prevShield= 0;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation) {
    playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Damage_Taken), prevHealth);
    playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Armor_Lost), prevShield);
/*
        pri.addToHiddenStat(pri.HiddenStat.DEATHS, 1);

        if(Killer == Self.Controller) {
            pri.addToHiddenStat(pri.HiddenStat.SUICIDE, 1);
        }
*/
    prevHealth= 0;
    prevShield= 0;

    super.Died(Killer, damageType, HitLocation);
}

function ServerBuyWeapon( Class<Weapon> WClass ) {
    local int oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyWeapon(WClass);
    playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Cash_Spent), 
            oldScore - PlayerReplicationInfo.Score);
}

function ServerBuyAmmo( Class<Ammunition> AClass, bool bOnlyClip ) {
    local int oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyAmmo(AClass, bOnlyClip);
    playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Cash_Spent), 
            oldScore - PlayerReplicationInfo.Score);
}

function ServerBuyKevlar() {
    local int oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyKevlar();
    playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Cash_Spent), 
            oldScore - PlayerReplicationInfo.Score);
}
