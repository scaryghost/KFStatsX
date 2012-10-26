/**
 * Custom kill and death rules for KFStatsX
 * @author etsai (Scary Ghost)
 */
class KFSXGameRules extends GameRules;

var array<Pawn> decappedPawns, ragedScrakes;
/** Record of deaths from all players */
var SortedMap deaths;
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
    deaths= Spawn(class'SortedMap');
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

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, 
        out vector Momentum, class<DamageType> DamageType ) {
    local KFSXReplicationInfo instigatorRI;
    local ZombieFleshPound zfp;
    local ZombieScrake zsc;
    local int newDamage;

    newDamage= super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation,  Momentum, DamageType);
    if (instigatedBy != none) {
        instigatorRI= class'KFSXReplicationInfo'.static.findKFSXri(instigatedBy.PlayerReplicationInfo);
        if (instigatorRI != none) {
            instigatorRI.player.accum(damageKey, min(injured.Health, newDamage));
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
            if (zfp != none && newDamage < injured.Health && (!injured.IsInState('BeginRaging') && !injured.IsInState('RageCharging')) && 
                    zfp.TwoSecondDamageTotal + newDamage > zfp.RageDamageThreshold) {
                instigatorRI.actions.accum(instigatorRI.fleshpoundsRaged, 1);
            } else if (zsc != none) {
                if (newDamage < injured.Health && !contains(ragedScrakes, injured) && !zsc.bDecapitated && 
                        (Level.Game.GameDifficulty < 5.0 && (zsc.Health - newDamage) / zsc.HealthMax < 0.5 || (zsc.Health - newDamage) / zsc.HealthMax < 0.75)) {
                    instigatorRi.actions.accum(scrakesRaged, 1);
                    ragedScrakes[ragedScrakes.length]= injured;
                }
                if (newDamage < injured.Health && newDamage * 1.5 >float(injured.default.Health)) {
                    instigatorRI.actions.accum(scrakesStunned, 1);
                }
            } else if (ZombieHusk(injured) != none && newDamage < injured.Health && (newDamage * 1.5 >float(injured.default.Health) || 
                    (damageType == class'DamTypeCrossbow' || damageType == class'DamTypeCrossbowHeadShot' ||
                    damageType == class'DamTypeWinchester' || damageType == class'DamTypeM14EBR'
                    || damageType == class'DamTypeM99HeadShot' || damageType == class'DamTypeM99SniperRifle' ) && newDamage > 200)) {
                    instigatorRI.actions.accum(husksStunned, 1);
            }
        }

    }
    
    return newDamage;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
    local KFSXReplicationInfo kfsxri;

    if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        if(KFHumanPawn(Killed) != none && 
                (damageType == class'Engine.Fell' || damageType == class'Gameplay.Burned')) {
            deaths.accum(envDeathKey,1);
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
    if (KFMonsterController(Killer) != none && PlayerController(Killed) != none) {
        deaths.accum(Killer.Pawn.MenuName,1 );
        kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Killed.PlayerReplicationInfo);
        kfsxri.player.accum(deathKey, 1);
    } else if (PlayerController(Killer) != none) {
        if (Killed.PlayerReplicationInfo == none || 
            Killer.PlayerReplicationInfo.Team != Killed.PlayerReplicationInfo.Team) {
            itemName= Killed.Pawn.MenuName;
        } else if (Killer == Killed) {
            deaths.accum(selfDeathKey, 1);
            itemName= selfDeathKey;
        } else if (Killer.PlayerReplicationInfo.Team == Killed.PlayerReplicationInfo.Team) { 
            deaths.accum(teammateDeathKey, 1);
            itemName= teammateDeathKey;
        }
        if (itemName != "") {
            kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Killer.PlayerReplicationInfo);
            kfsxri.kills.accum(itemName, 1);
        }
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
