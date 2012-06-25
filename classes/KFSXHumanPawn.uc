/**
 * Custom pawn class used by the KFStatsX mutator.  
 * Injects stat tracking code above the KFHumanPawn class 
 * to log events such as money spent, damage taken, etc...
 * @author etsai (Scary Ghost)
 */
class KFSXHumanPawn extends KFHumanPawn;

var string damageTaken, armorLost, timeAlive, cashSpent;
var string healedSelf, receivedHeal, boltsRetrieved, healDartsConnected, healedTeammates;
var string deaths;
var float prevHealth, prevShield;
var KFSXReplicationInfo kfsxri;
var int prevTime;

/**
 * If the Pawn touched a healing dart, tell the dart's instigator 
 * to increment heal darts connected
 */
function Touch(Actor Other) {
    local KFSXReplicationInfo instigatorRI;

    super.Touch(Other);
    if (isHealingProjectile(Other) && KFSXHumanPawn(Other.Instigator) != Self) {
        instigatorRI= class'KFSXReplicationInfo'.static.findKFSXri(Other.Instigator.PlayerReplicationInfo);
        instigatorRI.actions.accum(healDartsConnected, 1);
        if (Health < HealthMax)
            instigatorRI.actions.accum(healedTeammates, 1);
    }
}

function bool isHealingProjectile(Actor Other) {
    return MP7MHealinglProjectile(Other) != none;
}

simulated function PostBeginPlay() {
    super.PostBeginPlay();
    prevTime= Level.GRI.ElapsedTime;
}

/**
 * Accumulate Time_Alive and perk time
 */
function Timer() {
    local int currTime, timeDiff;

    super.Timer();
    currTime= Level.GRI.ElapsedTime;
    timeDiff= currTime - prevTime;
    if (kfsxri != none) {
        kfsxri.player.accum(timeAlive, timeDiff);
        if (KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none) {
            kfsxri.perks.accum(GetItemName(string(KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill)), timeDiff);
        }
    }
    prevTime= currTime;
}

/**
 * Pawn possessed by a controller.
 * Overridden to grab the stat info
 */
function PossessedBy(Controller C) {
    super.PossessedBy(C);
    kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(PlayerReplicationInfo);
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
                itemName= healedTeammates;
            kfsxri.actions.accum(itemName,1);
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

        kfsxri.weapons.accum(itemName, load);
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
   
    kfsxri.player.accum(damageTaken, oldHealth - fmax(Health,0.0));
    kfsxri.player.accum(armorLost, oldShield - fmax(ShieldStrength,0.0));
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

    if(kfsxri != none) {
        kfsxri.player.accum(damageTaken, oldHealth - fmax(Health,0.0));
        kfsxri.player.accum(armorLost, oldShield - fmax(ShieldStrength,0.0));
    }
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation) {
    if (!Controller.IsInState('GameEnded')) {
        kfsxri.player.accum(deaths, 1);
    }

    prevHealth= 0;
    prevShield= 0;

    super.Died(Killer, damageType, HitLocation);
}

function ServerBuyWeapon( Class<Weapon> WClass ) {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyWeapon(WClass);
    kfsxri.player.accum(cashSpent, (oldScore - PlayerReplicationInfo.Score));
}

function ServerBuyAmmo( Class<Ammunition> AClass, bool bOnlyClip ) {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyAmmo(AClass, bOnlyClip);
    kfsxri.player.accum(cashSpent, (oldScore - PlayerReplicationInfo.Score));
}

function ServerBuyKevlar() {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyKevlar();
    kfsxri.player.accum(cashSpent, (oldScore - PlayerReplicationInfo.Score));
}

function bool GiveHealth(int HealAmount, int HealMax) {
    local bool result;

    result= super.GiveHealth(HealAmount, HealMax);
    if (result) {
        kfsxri.actions.accum(receivedHeal, 1);
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
    deaths= "Deaths"
    boltsRetrieved= "Bolts Retrieved"
    healDartsConnected= "Heal Darts Connected"
    healedTeammates= "Healed Teammates"
}
