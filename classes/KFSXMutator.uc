/**
 * Mutator to load in the KFStatsX modifications
 * @author etsai (Scary Ghost)
 */
class KFSXMutator extends Mutator
    dependson(Auxiliary);

/** Reference to the KFGameType object */
var KFGameType gametype;
/** Player controller class to use for KFStatsX */
var class<PlayerController> kfsxPC;
/** Linked replication info classes to attach to PRI */
var array<class<LinkedReplicationInfo> > lriList;
/** Stores the pairs of default monsters with their stats counterparts */
var array<Auxiliary.ReplacementPair> monsterReplacement;
/** End game boss and the fall back monster class */
var string endGameBossClass, fallbackMonsterClass;
/** Reference to the auxiliary class */
var class<Auxiliary> auxiliaryRef;
/** Reference to the game rules used by KFStatsX */
var class<GameRules> kfStatsXRules;

function PostBeginPlay() {
    gameType= KFGameType(Level.Game);
    if (gameType == none) {
        Destroy();
        return;
    }
    
    Spawn(kfStatsXRules);
    gameType.PlayerControllerClass= kfsxPC;
    gameType.PlayerControllerClassName= string(kfsxPC);

    //Replace all instances of the old specimens with the new ones 
    auxiliaryRef.static.replaceStandardMonsterClasses(gameType.StandardMonsterClasses, 
            monsterReplacement);

    //Replace the special squad arrays
    auxiliaryRef.static.replaceSpecialSquad(gameType.ShortSpecialSquads, monsterReplacement);
    auxiliaryRef.static.replaceSpecialSquad(gameType.NormalSpecialSquads, monsterReplacement);
    auxiliaryRef.static.replaceSpecialSquad(gameType.LongSpecialSquads, monsterReplacement);
    auxiliaryRef.static.replaceSpecialSquad(gameType.FinalSquads, monsterReplacement);

    gameType.EndGameBossClass= endGameBossClass;
    gameType.FallbackMonsterClass= fallbackMonsterClass;

}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local int i;
    local PlayerReplicationInfo pri;
    local LinkedReplicationInfo lri;

    if (PlayerReplicationInfo(Other) != none && 
        PlayerReplicationInfo(Other).Owner != none) {
        
        pri= PlayerReplicationInfo(Other);
        for(i= 0; i < lriList.Length; i++) {
            lri= pri.spawn(lriList[i], pri.Owner);
            lri.NextReplicationInfo= pri.CustomReplicationInfo;
            pri.CustomReplicationInfo= lri;
        }
        return true;
    } else if (Frag(Other) != none) {
        Frag(Other).FireModeClass[0]= class'FragFire_KFSX';
        return true;
    } else if (Huskgun(Other) != none) {
        Huskgun(Other).FireModeClass[0]= class'HuskGunFire_KFSX';
    } else if (Welder(Other) != none) {
        Welder(Other).FireModeClass[0]= class'WeldFire_KFSX';
        Welder(Other).FireModeClass[1]= class'UnWeldFire_KFSX';
        return true;
    }

    return super.CheckReplacement(Other, bSuperRelevant);
}

defaultproperties {
    GroupName="KFStatX"
    FriendlyName="KFStatsX v1.0"
    Description="Tracks statistics for each player"

    bAddToServerPackages=true
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true

    auxiliaryRef= class'Auxiliary'
    kfStatsXRules= class'KFSXGameRules'

    endGameBossClass= "KFStatsX.ZombieBoss_KFSX"
    fallbackMonsterClass= "KFStatsX.ZombieStalker_KFSX"
    monsterReplacement(0)=(oldClass=class'KFChar.ZombieBloat',newClass=class'KFStatsX.ZombieBloat_KFSX')
    monsterReplacement(1)=(oldClass=class'KFChar.ZombieClot',newClass=class'KFStatsX.ZombieClot_KFSX')
    monsterReplacement(2)=(oldClass=class'KFChar.ZombieCrawler',newClass=class'KFStatsX.ZombieCrawler_KFSX')
    monsterReplacement(3)=(oldClass=class'KFChar.ZombieFleshPound',newClass=class'KFStatsX.ZombieFleshpound_KFSX')
    monsterReplacement(4)=(oldClass=class'KFChar.ZombieGorefast',newClass=class'KFStatsX.ZombieGorefast_KFSX')
    monsterReplacement(5)=(oldClass=class'KFChar.ZombieHusk',newClass=class'KFStatsX.ZombieHusk_KFSX')
    monsterReplacement(6)=(oldClass=class'KFChar.ZombieScrake',newClass=class'KFStatsX.ZombieScrake_KFSX')
    monsterReplacement(7)=(oldClass=class'KFChar.ZombieSiren',newClass=class'KFStatsX.ZombieSiren_KFSX')
    monsterReplacement(8)=(oldClass=class'KFChar.ZombieStalker',newClass=class'KFStatsX.ZombieStalker_KFSX')

    kfsxPC= class'KFSXPlayerController'
    lriList(0)= class'WeaponLRI'
    lriList(1)= class'PlayerLRI'
    lriList(2)= class'KillsLRI'
}
