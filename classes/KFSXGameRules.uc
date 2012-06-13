/**
 * Custom kill and death rules for KFStatsX
 * @author etsai (Scary Ghost)
 */
class KFSXGameRules extends GameRules
    dependson(KillsLRI);

/** Record of deaths from all players */
var SortedMap deaths;
/** Key for environment death (fall or world fire) */
var String envDeathKey;
/** Key for self inflicted death */
var String selfDeathKey;
/** Key for teammate death */
var String teammateDeathKey;

function PostBeginPlay() {
    NextGameRules = Level.Game.GameRulesModifiers;
    Level.Game.GameRulesModifiers = Self;
    deaths= Spawn(class'SortedMap');
}


function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
    if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        if(KFHumanPawn(Killed) != none && 
                (damageType == class'Engine.Fell' || damageType == class'Gameplay.Burned')) {
            deaths.accum(envDeathKey,1);
        }
        return false;
    }
    return true;
}


function ScoreKill(Controller Killer, Controller Killed) {
    local string itemName;

    Super.ScoreKill(Killer,Killed);
    if (KFMonsterController(Killer) != none && PlayerController(Killed) != none) {
        deaths.accum(Killer.Pawn.MenuName,1 );
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
        if (itemName != "") 
            KFSXPlayerController(Killer).killsLRI.stats.accum(itemName, 1);
    }
}

defaultproperties {
    envDeathKey= "Environment"
    selfDeathKey= "Self"
    teammateDeathKey= "Teammate"
}
