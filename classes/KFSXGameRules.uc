class KFSXGameRules extends GameRules
    dependson(KillsLRI);

function PostBeginPlay() {
    NextGameRules = Level.Game.GameRulesModifiers;
    Level.Game.GameRulesModifiers = Self;
}

/*
function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
    local GSTGameReplicationInfo.DeathStat deathIndex;

    PlayerController(Killer).ClientMessage(damageType);
    if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        if(damageType == class'Engine.Fell' || damageType == class'Gameplay.Burned') {
            deathIndex= ENV_DEATH;
            GSTGameReplicationInfo(Level.Game.GameReplicationInfo).deathStats[deathIndex]+= 1;
        }
        return false;
    }
    return true;
}
*/

function ScoreKill(Controller Killer, Controller Killed) {
    local string killedName;

    Super.ScoreKill(Killer,Killed);
    if (KFMonsterController(Killer) != none && PlayerController(Killed) != none) {
/*
        index= class'GSTAuxiliary'.static.binarySearch(GetItemName(string(Killer.pawn)), zedNames);
        if (index > -1) GSTGameReplicationInfo(Level.Game.GameReplicationInfo).deathStats[index]+= 1;
*/
    } else if (PlayerController(Killer) != none) {
        if (Killed.PlayerReplicationInfo == none || 
            Killer.PlayerReplicationInfo.Team != Killed.PlayerReplicationInfo.Team) {
            killedName= Killed.Pawn.MenuName;
        } else if (Killer == Killed) {
//            GSTGameReplicationInfo(Level.Game.GameReplicationInfo).deathStats[index]+= 1;
            killedName= "Self";
        } else if (Killer.PlayerReplicationInfo.Team == Killed.PlayerReplicationInfo.Team) { 
//            GSTGameReplicationInfo(Level.Game.GameReplicationInfo).deathStats[index]+= 1;
            killedName= "Teammate";
        }
        if (killedName != "")
            KFSXPlayerController(Killer).killsLRI.stats.accum(killedName, 1);
    }
}
