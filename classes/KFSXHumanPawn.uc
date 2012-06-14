/**
 * Custom pawn class used by the KFStatsX mutator.  
 * Injects stat tracking code above the KFHumanPawn class 
 * to log events such as money spent, damage taken, etc...
 * @author etsai (Scary Ghost)
 */
class KFSXHumanPawn extends KFHumanPawn;

var String damageTaken, armorLost, timeAlive, healedSelf, cashSpent, receivedHeal;
var String deaths, suicides;
var float prevHealth, prevShield;
var KFSXLinkedReplicationInfo lri;
var int prevTime;

/**
 * Accumulate Time_Alive and perk time
 */
function Timer() {
    local int timeDiff;

    super.Timer();
    timeDiff= Level.GRI.ElapsedTime - prevTime;
    if (lri != none) {
        lri.playerInfo.accum(timeAlive, timeDiff);
    }
    if (lri != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none) {
        lri.hiddenInfo.accum(GetItemName(string(KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill)), timeDiff);
    }
    prevTime= Level.GRI.ElapsedTime;
}

/**
 * Pawn possessed by a controller.
 * Overridden to grab the player and hidden LRIs
 */
function PossessedBy(Controller C) {
    super.PossessedBy(C);
    lri= class'KFSXLinkedReplicationInfo'.static.findKFSXlri(PlayerReplicationInfo);
}

function bool isMedicGun() {
    return MP7MMedicGun(Weapon) != none;
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
                itemName= healedSelf;
            else
                itemName= lri.healedTeammates;
            lri.playerInfo.accum(itemName,1);
            return;
        }

        if (KFMeleeGun(Weapon) != none || (mode == 1 && isMedicGun())) {
            load= 1;
        } else {
            load= Weapon.GetFireMode(mode).Load;
        }

        if (mode == 1 && (isMedicGun() || 
                (KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo))) {
            itemName$= " Alt";
        }

        lri.weaponInfo.accum(itemName, load);
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
   
    lri.playerInfo.accum(damageTaken, oldHealth - fmax(Health,0.0));
    lri.playerInfo.accum(armorLost, oldShield - fmax(ShieldStrength,0.0));
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

    if(lri != none) {
        lri.playerInfo.accum(damageTaken, oldHealth - fmax(Health,0.0));
        lri.playerInfo.accum(armorLost, oldShield - fmax(ShieldStrength,0.0));
    }
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation) {
    if (!Controller.IsInState('GameEnded')) {
        lri.hiddenInfo.accum(lri.deaths, 1);
        if(Killer == Self.Controller) {
            lri.hiddenInfo.accum(lri.suicides, 1);
        }
    }

    prevHealth= 0;
    prevShield= 0;

    super.Died(Killer, damageType, HitLocation);
}

function ServerBuyWeapon( Class<Weapon> WClass ) {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyWeapon(WClass);
    lri.playerInfo.accum(cashSpent, (oldScore - PlayerReplicationInfo.Score));
}

function ServerBuyAmmo( Class<Ammunition> AClass, bool bOnlyClip ) {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyAmmo(AClass, bOnlyClip);
    lri.playerInfo.accum(cashSpent, (oldScore - PlayerReplicationInfo.Score));
}

function ServerBuyKevlar() {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyKevlar();
    lri.playerInfo.accum(cashSpent, (oldScore - PlayerReplicationInfo.Score));
}

function bool GiveHealth(int HealAmount, int HealMax) {
    local bool result;

    result= super.GiveHealth(HealAmount, HealMax);
    if (result) {
        lri.playerInfo.accum(receivedHeal, 1);
    }
    return result;
}

defaultproperties {
    damageTaken= "Damage Taken"
    armorLost= "Armor Lost"
    timeAlive= "Time Alive"
    healedSelf= "Healed Self"
    cashSpent= "Cash Spent"
    receivedHeal= "Received Heal"
}
