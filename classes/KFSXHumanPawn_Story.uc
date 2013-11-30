/**
 * This class is deprecated and will be removed when version 4.0 is 
 * released.  The KFSXHumanPawn class extends from the story mode variant 
 * and manages all the different differences between wave and story mode.
 */
class KFSXHumanPawn_Story extends KFStoryGame.KFHumanPawn_Story;

var bool signalToss, signalFire;
var string damageTaken, armorLost, timeAlive, cashSpent, shotByHusk;
var string healedSelf, receivedHeal, healDartsConnected, healedTeammates;
var string boltsRetrieved, bladesRetrieved, pukedOn, welding, healing;
var KFSXReplicationInfo kfsxri;
var int prevTime, prevHuskgunAmmo, prevWeldStat, prevHealStat;

/**
 * If the Pawn touched a healing dart, arrow, or blade, increment appropriate stats
 */
function Touch(Actor Other) {
    local Inventory inv;
    local KFSXReplicationInfo instigatorRI;

    super.Touch(Other);
    if (MP7MHealinglProjectile(Other) != none && KFSXHumanPawn(Other.Instigator) != Self) {
        instigatorRI= class'KFSXReplicationInfo'.static.findKFSXri(Other.Instigator.PlayerReplicationInfo);
        instigatorRI.actions.accum(healDartsConnected, 1);
        if (Health < HealthMax)
            instigatorRI.actions.accum(healedTeammates, 1);
    }
    if (Other.IsInState('OnWall')) {
        for (inv= Inventory; inv != None; inv= inv.Inventory) {
            if (Weapon(inv) != none && Weapon(inv).AmmoAmount(0) < Weapon(inv).MaxAmmo(0)) {
                if (CrossbowArrow(Other) != none && Crossbow(inv) != None) {
                    kfsxri.actions.accum(boltsRetrieved, 1.0);
                } else if (CrossbuzzsawBlade(Other) != none && Crossbuzzsaw(inv) != None) {
                    kfsxri.actions.accum(bladesRetrieved, 1.0);
                }
            }
        }
    }
}

simulated function PostBeginPlay() {
    super.PostBeginPlay();
    prevTime= Level.GRI.ElapsedTime;
}

simulated function Tick(float DeltaTime) {
    local KFPlayerReplicationInfo kfPRI;
    local class<Projectile> nadeType;

    if (Role == ROLE_Authority && PlayerReplicationInfo != none) {
        if (!signalToss && bThrowingNade) {
            kfPRI= KFPlayerReplicationInfo(PlayerReplicationInfo);
            if (kfPRI != none && kfPRI.ClientVeteranSkill != none) {
                nadeType= kfPRI.ClientVeteranSkill.Static.GetNadeType(kfPRI);
            } else {
                nadeType= class'Nade';
            }
            kfsxri.weapons.accum(GetItemName(string(nadeType)), 1);
            signalToss= true;
        } else if (signalToss && !bThrowingNade) {
            signalToss= false;
        }
        if (signalFire && Huskgun(Weapon) != none && prevHuskgunAmmo < Weapon.AmmoAmount(0)) {
            prevHuskgunAmmo= Weapon.AmmoAmount(0);
        }
        if (!signalFire && Weapon != None && Weapon.IsFiring()) {
            if (Huskgun(Weapon) != none) {
                prevHuskgunAmmo= Weapon.AmmoAmount(0);
            }
            signalFire= true;
        } else if (signalFire && Weapon != None && !Weapon.IsFiring()) {
            signalFire= false;
        }
        if (KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements) != none) {
            if (prevWeldStat < KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).WeldingPointsStat.Value) {
                kfsxri.summary.accum(welding, KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).WeldingPointsStat.Value - prevWeldStat);
                prevWeldStat= KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).WeldingPointsStat.Value;
            }
            if (prevHealStat < KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).DamageHealedStat.Value) {
                kfsxri.summary.accum(healing, KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).DamageHealedStat.Value - prevHealStat);
                prevHealStat= KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).DamageHealedStat.Value;
            }
        }
    }
    super.Tick(DeltaTime);
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
        kfsxri.summary.accum(timeAlive, timeDiff);
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
    if (KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements) != none) {
        prevWeldStat= KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).WeldingPointsStat.Value;
        prevHealStat= KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).DamageHealedStat.Value;
    }
}

/**
 * Called whenever a weapon is fired.  
 * This function tracks usage for every weapon except the Welder
 */
function DeactivateSpawnProtection() {
    local int mode;
    local string itemName;
    local float load, healAmount;

    super.DeactivateSpawnProtection();
    
    if (prevHuskgunAmmo != 0 && Huskgun(Weapon) != none) {
        load= prevHuskgunAmmo - Weapon.AmmoAmount(0);
        prevHuskgunAmmo= 0;
    }
    if (load != 0 || (Weapon.isFiring() && Welder(Weapon) == none)) {
        itemName= Weapon.ItemName;
        if (Weapon.GetFireMode(1).bIsFiring)
            mode= 1;

        if (Syringe(Weapon) != none) {
            if (mode == 1) {
                itemName= healedSelf;
                healAmount= Syringe(Weapon).HealBoostAmount * KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.
                        GetHealPotency(KFPlayerReplicationInfo(PlayerReplicationInfo));
                if ((Health + healthToGive + healAmount) > HealthMax ) {
                    healAmount= HealthMax - (Health + healthToGive);
                }
                if (healAmount > 0) {
                    kfsxri.summary.accum(healing, healAmount);
                }
            } else {
                itemName= healedTeammates;
            }
            kfsxri.actions.accum(itemName,1);
            return;
        }

        if (KFMeleeGun(Weapon) != none || (mode == 1 && (KFMedicGun(Weapon) != none || ZEDGun(Weapon) != none || SPAutoShotgun(Weapon) != none))) {
            load= 1;
        } else if (load == 0) {
            load= Weapon.GetFireMode(mode).Load;
        }

        if (mode == 1 && (KFMedicGun(Weapon) != none || SPAutoShotgun(Weapon) != none || (KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo))) {
            itemName$= " Alt";
        }

        kfsxri.weapons.accum(itemName, load);
    }
}

simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex) {
    local float oldHealth;
    local float oldShield;

    oldHealth= Health;
    oldShield= ShieldStrength;

    //Does not work on TestMap
    if (ZombieHusk(InstigatedBy) != none && Momentum != vect(0,0,0) && damageType == class'HuskFireProjectile'.default.MyDamageType) {
        kfsxri.actions.accum(shotByHusk, 1);
    } else if (damageType == class'KFBloatVomit'.default.MyDamageType && BileCount != 7) {
        kfsxri.actions.accum(pukedOn, 1);
    }

    Super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
   
    if (kfsxri != none && oldHealth > 0) {
        kfsxri.summary.accum(damageTaken, oldHealth - fmax(Health,0.0));
        kfsxri.summary.accum(armorLost, oldShield - fmax(ShieldStrength,0.0));
    }
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
    oldShield= ShieldStrength;

    Super(xPawn).TakeDamage(2+Rand(3), BileInstigator, Location, vect(0,0,0), class'DamTypeVomit');
    healthtoGive-=5;

    if(kfsxri != none && oldHealth > 0) {
        kfsxri.summary.accum(damageTaken, oldHealth - fmax(Health,0.0));
        kfsxri.summary.accum(armorLost, oldShield - fmax(ShieldStrength,0.0));
    }
}

function ServerBuyWeapon(Class<Weapon> WClass, float ItemWeight) {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyWeapon(WClass, ItemWeight);
    kfsxri.summary.accum(cashSpent, (oldScore - PlayerReplicationInfo.Score));
}

function bool ServerBuyAmmo(Class<Ammunition> AClass, bool bOnlyClip) {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    if (super.ServerBuyAmmo(AClass, bOnlyClip)) {
        kfsxri.summary.accum(cashSpent, (oldScore - PlayerReplicationInfo.Score));
        return true;
    }
    return false;
}

function ServerBuyKevlar() {
    local float oldScore;

    oldScore= PlayerReplicationInfo.Score;
    super.ServerBuyKevlar();
    kfsxri.summary.accum(cashSpent, (oldScore - PlayerReplicationInfo.Score));
}

function bool GiveHealth(int HealAmount, int HealMax) {
    if (super.GiveHealth(HealAmount, HealMax)) {
        kfsxri.actions.accum(receivedHeal, 1);
        return true;
    }
    return false;
}

defaultproperties {
    damageTaken= "Damage Taken"
    armorLost= "Armor Lost"
    timeAlive= "Time Alive"
    healedSelf= "Healed Self"
    cashSpent= "Cash Spent"
    receivedHeal= "Received Heal"
    healDartsConnected= "Heal Darts Connected"
    healedTeammates= "Healed Teammates"
    shotByHusk= "Shot By Husk"
    boltsRetrieved= "Bolts Retrieved"
    bladesRetrieved= "Blades Retrieved"
    pukedOn= "Puked On"
    welding= "Welding"
    healing= "Healing"
}
