/**
 * Custom pawn class used by the KFStatsX mutator.  
 * Injects stat tracking code above the KFHumanPawn class 
 * to log events such as money spent, damage taken, etc...
 * @author etsai (Scary Ghost)
 */
class KFSXHumanPawn extends KFHumanPawn;

var float prevHealth, prevShield;
var PlayerLRI playerLRI;
var int prevTime;

function Timer() {
    local int timeDiff;

    super.Timer();
    if (playerLRI == none) {
        playerLRI= KFSXPlayerController(Controller).playerLRI;
    }
    timeDiff= Level.GRI.ElapsedTime - prevTime;
    playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Time_Alive), timeDiff);
    prevTime= Level.GRI.ElapsedTime;
}

function DeactivateSpawnProtection() {
    local int mode;
    local string itemName;
    local float load;
    super.DeactivateSpawnProtection();
    
    if (Weapon.isFiring() && Welder(Weapon) == none && Huskgun(Weapon) == none) {
        itemName= Weapon.ItemName;
        if (Weapon.GetFireMode(1).bIsFiring)
            mode= 1;

        if (Syringe(Weapon) != none) {
            if (mode ==1)
                itemName= playerLRI.getKey(playerLRI.StatKeys.Healed_Self);
            else
                itemName= playerLRI.getKey(playerLRI.StatKeys.Healed_Teammates);
            playerLRI.accum(itemName,1);
            return;
        }

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

/**
 * Copied from KFPawn.TakeBileDamage()
 * Had to inject stats tracking code here because the original
 * function uses xPawn.TakeDamage to prevent resetting the bile timer
 */
function TakeBileDamage() {
    local float oldHealth;
    local float oldShield;

    oldHealth= Health;
    prevHealth= oldHealth;
    oldShield= ShieldStrength;
    prevShield= oldShield;

    Super(xPawn).TakeDamage(2+Rand(3), BileInstigator, Location, vect(0,0,0), class'DamTypeVomit');
    healthtoGive-=5;

    if(playerLRI != none) {
        playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Damage_Taken), 
                oldHealth - fmax(Health,0.0));
        playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Armor_Lost), 
                oldShield - fmax(ShieldStrength,0.0));
    }
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

function bool GiveHealth(int HealAmount, int HealMax) {
    local bool result;

    result= super.GiveHealth(HealAmount, HealMax);
    if (result) {
        playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Received_Heal), 1);
    }
    return result;
}
