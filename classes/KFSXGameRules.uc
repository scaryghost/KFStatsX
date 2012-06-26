/**
 * Custom kill and death rules for KFStatsX
 * @author etsai (Scary Ghost)
 */
class KFSXGameRules extends GameRules;

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

function PostBeginPlay() {
    NextGameRules = Level.Game.GameRulesModifiers;
    Level.Game.GameRulesModifiers = Self;
    deaths= Spawn(class'SortedMap');
}


function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
    local KFSXReplicationInfo kfsxri;

    if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        if(KFHumanPawn(Killed) != none && 
                (damageType == class'Engine.Fell' || damageType == class'Gameplay.Burned')) {
            deaths.accum(envDeathKey,1);
        } else if (Killed.Physics == PHYS_Falling && class<DamTypeMelee>(damageType) != none ) {
            kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Killer.PlayerReplicationInfo);
            kfsxri.actions.accum(swattedCrawler, 1);
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
}
