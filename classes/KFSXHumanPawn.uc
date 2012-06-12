/**
 * Custom pawn class used by the KFStatsX mutator.  
 * Injects stat tracking code above the KFHumanPawn class 
 * to log events such as money spent, damage taken, etc...
 * @author etsai (Scary Ghost)
 */
class KFSXHumanPawn extends KFHumanPawn;

var float prevHealth, prevShield;
var PlayerLRI playerLRI;
var HiddenLRI hiddenLRI;
var int prevTime;

/**
 * Accumulate Time_Alive and perk time
 */
function Timer() {
    local int timeDiff;

    super.Timer();
    timeDiff= Level.GRI.ElapsedTime - prevTime;
    if (playerLRI != none) {
        playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Time_Alive), timeDiff);
    }
    if (hiddenLRI != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none) {
        hiddenLRI.stats.accum(GetItemName(string(KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill)), timeDiff);
    }
    prevTime= Level.GRI.ElapsedTime;
}

/**
 * Pawn possessed by a controller.
 * Overridden to grab the player and hidden LRIs
 */
function PossessedBy(Controller C) {
    super.PossessedBy(C);
    if (KFSXPlayerController(C) != none) {
        playerLRI= KFSXPlayerController(C).playerLRI;
        hiddenLRI= KFSXPlayerController(C).hiddenLRI;
    }
}

/**
 * Called whenever a weapon is fired.  
 * This function tracks usage for every weapon except the Welder and Huskgun
 */
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
            playerLRI.stats.accum(itemName,1);
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

        KFSXPlayerController(Controller).weaponLRI.stats.accum(itemName, load);
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
   
    playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Damage_Taken), 
            oldHealth - fmax(Health,0.0));
    playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Armor_Lost), 
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
        playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Damage_Taken), 
                oldHealth - fmax(Health,0.0));
        playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Armor_Lost), 
                oldShield - fmax(ShieldStrength,0.0));
    }
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation) {
    hiddenLRI.stats.accum(hiddenLRI.DEATHS, 1);
    if(Killer == Self.Controller) {
        hiddenLRI.stats.accum(hiddenLRI.SUICIDES, 1);
    }

    prevHealth= 0;
    prevShield= 0;

    super.Died(Killer, damageType, HitLocation);
}

function ServerBuyWeapon( Class<Weapon> WClass ) {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyWeapon(WClass);
    playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Cash_Spent), 
            (oldScore - PlayerReplicationInfo.Score));
}

function ServerBuyAmmo( Class<Ammunition> AClass, bool bOnlyClip ) {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyAmmo(AClass, bOnlyClip);
    playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Cash_Spent), 
            (oldScore - PlayerReplicationInfo.Score));
}

function ServerBuyKevlar() {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyKevlar();
    playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Cash_Spent), 
            (oldScore - PlayerReplicationInfo.Score));
}

function bool GiveHealth(int HealAmount, int HealMax) {
    local bool result;

    result= super.GiveHealth(HealAmount, HealMax);
    if (result) {
        playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Received_Heal), 1);
    }
    return result;
}
