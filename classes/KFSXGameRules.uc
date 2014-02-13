/**
 * Custom kill and death rules for KFStatsX
 * @author etsai (Scary Ghost)
 */
class KFSXGameRules extends GameRules
    dependson(WaveData);

var array<Pawn> decappedPawns, ragedScrakes;
/** Record of deaths from all players */
var WaveData deaths, kills, weapons;
/** key for environment death (fall or world fire) */
var string envDeathKey;
/** Key for self inflicted death */
var string selfDeathKey;
/** Key for teammate death */
var string teammateDeathKey;
/** Key for swatted crawler */
var string swattedCrawler;
/** Key for player deaths */
var string deathKey;
/** Key for scrakes stunned */
var string scrakesStunned, husksStunned;
var string scrakesRaged;
var string backstabs, decapitations;
var string damageKey;

function PostBeginPlay() {
    NextGameRules = Level.Game.GameRulesModifiers;
    Level.Game.GameRulesModifiers = Self;
    deaths= Spawn(class'WaveData');
    deaths.category= "deaths";
    kills= Spawn(class'WaveData');
    kills.category= "kills";
    weapons= Spawn(class'WaveData');
    weapons.category= "weapons";
}

private function bool contains(array<Pawn> pawns, Pawn key) {
    local int i;
    for(i= 0; i < pawns.length && pawns[i] != key; i++);

    return i < pawns.length;
}

private function remove(out array<Pawn> pawns, Pawn key) {
    local int i;
    for(i= 0; i < pawns.length && pawns[i] != key; i++);

    if (i < pawns.length) {
        pawns.remove(i, 1);
    }
}

function resetWaveData() {
    deaths.reset();
    kills.reset();
    weapons.reset();
}

function setWave(int wave) {
    deaths.wave= wave;
    kills.wave= wave;
    weapons.wave= wave;
}

function sendWaveData(RemoteServerLink link) {
    link.broadcastWaveData(deaths);
    link.broadcastWaveData(kills);
    link.broadcastWaveData(weapons);
}

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, 
        out vector Momentum, class<DamageType> DamageType ) {
    local KFSXReplicationInfo instigatorRI;
    local ZombieFleshPound zfp;
    local ZombieScrake zsc;
    local int newDamage;
    local bool nonFatalBlow;

    newDamage= super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation,  Momentum, DamageType);
    if (instigatedBy != none) {
        instigatorRI= class'KFSXReplicationInfo'.static.findKFSXri(instigatedBy.PlayerReplicationInfo);
        if (instigatorRI != none) {
            nonFatalBlow= newDamage < injured.Health;
            instigatorRI.summary.accum(damageKey, min(injured.Health, newDamage));
            if (KFMonster(injured) != none) {
                if (KFMonster(injured).bBackstabbed) {
                    instigatorRI.actions.accum(backstabs, 1);
                }
                if (!contains(decappedPawns, injured) && KFMonster(injured).bDecapitated) {
                    instigatorRI.actions.accum(decapitations, 1);
                    decappedPawns[decappedPawns.length]= injured;
                }
            }
            zfp= ZombieFleshPound(injured);
            zsc= ZombieScrake(injured);
            if (zfp != none && nonFatalBlow && !zfp.bZapped && !(zfp.bCrispified && zfp.bBurnified) && !zfp.bDecapitated &&
                    (!injured.IsInState('BeginRaging') && !injured.IsInState('RageCharging')) && zfp.TwoSecondDamageTotal + newDamage > zfp.RageDamageThreshold) {
                instigatorRI.actions.accum(instigatorRI.fleshpoundsRaged, 1);
            } else if (zsc != none) {
                if (nonFatalBlow && !contains(ragedScrakes, injured) && !zsc.bDecapitated && 
                        (Level.Game.GameDifficulty < 5.0 && (zsc.Health - newDamage) < 0.5 * zsc.HealthMax || (zsc.Health - newDamage) < 0.75 * zsc.HealthMax)) {
                    instigatorRi.actions.accum(scrakesRaged, 1);
                    ragedScrakes[ragedScrakes.length]= injured;
                }
                if (nonFatalBlow && newDamage * 1.5 > float(injured.default.Health)) {
                    instigatorRI.actions.accum(scrakesStunned, 1);
                }
            } else if (ZombieHusk(injured) != none && nonFatalBlow && (newDamage * 1.5 >float(injured.default.Health) || 
                    (damageType == class'DamTypeCrossbow' || damageType == class'DamTypeCrossbowHeadShot' ||
                    damageType == class'DamTypeWinchester' || damageType == class'DamTypeM14EBR' || damageType == class'DamTypeM99HeadShot' || 
                    damageType == class'DamTypeM99SniperRifle' || damageType == class'DamTypeSPSniper' ) && newDamage > 200)) {
                instigatorRI.actions.accum(husksStunned, 1);
            }
        }

    }
    
    return newDamage;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
    local KFSXReplicationInfo kfsxri;

    if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        if(KFHumanPawn(Killed) != none && (damageType == class'Engine.Fell' || damageType == class'Gameplay.Burned')) {
            deaths.getStatsMap(KFPlayerReplicationInfo(Killed.PlayerReplicationInfo).ClientVeteranSkill).accum(envDeathKey,1);
            kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Killed.PlayerReplicationInfo);
            kfsxri.deaths.accum(envDeathKey, 1);
        } else if (ZombieCrawler(Killed) != none && Killed.Physics == PHYS_Falling && class<DamTypeMelee>(damageType) != none ) {
            kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Killer.PlayerReplicationInfo);
            kfsxri.actions.accum(swattedCrawler, 1);
        }
        remove(decappedPawns, Killed);
        if (ZombieScrake(Killed) != none) {
            remove(ragedScrakes, Killed);
        }
        return false;
    }
    return true;
}


function ScoreKill(Controller Killer, Controller Killed) {
    local string itemName;
    local KFSXReplicationInfo kfsxri;

    Super.ScoreKill(Killer,Killed);
    if (PlayerController(Killed) != none) {
        kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Killed.PlayerReplicationInfo);
        kfsxri.summary.accum(deathKey, 1);

        if (KFGameType(Level.Game).WaveNum == KFGameType(Level.Game).FinalWave) {
            kfsxri.survivedFinale= false;
        }
        if (Killer == Killed) {
            itemName= selfDeathKey;
        } else if (Killer.PlayerReplicationInfo != none && Killer.PlayerReplicationInfo.Team == Killed.PlayerReplicationInfo.Team) { 
            itemName= teammateDeathKey;
        } else if (KFMonsterController(Killer) != none) {
            itemName= Killer.Pawn.MenuName;
        } else {
            log("KFSXGameRules.ScoreKill - Cannot determine Killer:" @Killer);
            itemName= kfsxri.unknownKiller;
        }

        //kfsxri points to the killed controller
        deaths.getStatsMap(KFPlayerReplicationInfo(Killed.PlayerReplicationInfo).ClientVeteranSkill)
                .accum(itemName,1);
        kfsxri.deaths.accum(itemName, 1);

        //Here kfsxri now points to the killer controller
        kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Killer.PlayerReplicationInfo);
        //< IF killer doesn't have a kfsxRepInfo, don't increment the wave kill count
        if (kfsxri != none) {
            kfsxri.kills.accum(itemName, 1);
            kills.getStatsMap(KFPlayerReplicationInfo(Killer.PlayerReplicationInfo).ClientVeteranSkill)
                    .accum(ItemName,1);
        }
    } else if (KFMonsterController(Killed) != none && PlayerController(Killer) != none) {
        kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Killer.PlayerReplicationInfo);
        kfsxri.kills.accum(Killed.Pawn.MenuName, 1);
        kills.getStatsMap(KFPlayerReplicationInfo(Killer.PlayerReplicationInfo).ClientVeteranSkill)
                .accum(Killed.Pawn.MenuName,1);
    }
}

defaultproperties {
    envDeathKey= "Environment"
    selfDeathKey= "Self"
    teammateDeathKey= "Teammate"
    swattedCrawler= "Swatted Crawler"
    deathKey= "Deaths"
    scrakesStunned= "Scrakes Stunned"
    scrakesRaged= "Scrakes Raged"
    backstabs= "Backstabs"
    decapitations= "Decapitations"
    damageKey= "Damage"
    husksStunned= "Husks Stunned"
}
