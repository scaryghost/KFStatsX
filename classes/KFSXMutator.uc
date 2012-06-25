/**
 * Mutator to load in the KFStatsX modifications
 * @author etsai (Scary Ghost)
 */
class KFSXMutator extends Mutator
    config(KFStatsX)
    dependson(Auxiliary);

/** True if the player and match stats should be saved remotely */
var() config bool broadcastStats;
/** Port of the remote server */
var() config int serverPort;
/** Remote server address */
var() config string serverAddress;
/** Remote server password */
var() config string serverPwd;
/** Steam id of the local host */
var() config string localHostSteamId;
/** Player controller to be used by the game in ${package}.${class} format */
var() config string playerController;
/** Semi colon separated list of available, supported custom controllers */
var() config array<string> compatibleControllers;

/** Reference to the KFGameType object */
var KFGameType gametype;
/** Linked replication info class to attach to PRI */
var class<KFSXReplicationInfo> kfsxRIClass;
/** Stores the pairs of default monsters with their stats counterparts */
var array<Auxiliary.ReplacementPair> monsterReplacement;
/** End game boss and the fall back monster class */
var string endGameBossClass, fallbackMonsterClass;
/** Reference to the auxiliary class */
var class<Auxiliary> auxiliaryRef;
/** KFStatsX game rules object */
var KFSXGameRules gameRules;
/** Reference to the game rules used by KFStatsX */
var class<KFSXGameRules> kfStatsXRules;

/** Remote server link class */
var class<RemoteServerLink> serverLinkClass;
/** Link to the remote tracking server */
var transient RemoteServerLink serverLink;

/** List of fire modes to replace */
var array<Auxiliary.ReplacementPair> fireModeReplacement;

function PostBeginPlay() {

    gameType= KFGameType(Level.Game);
    if (gameType == none) {
        Destroy();
        return;
    }

    gameRules= Spawn(kfStatsXRules);
    gameType.PlayerControllerClass= class<PlayerController>(DynamicLoadObject(playerController, class'Class'));
    gameType.PlayerControllerClassName= playerController;
    if (Level.NetMode != NM_Standalone) {
        AddToPackageMap("KFStatsX");
        if (gameType.PlayerControllerClass != class'KFSXPlayerController') {
            AddToPackageMap(string(gameType.PlayerControllerClass.Outer.name));
        }
    }

    //Replace all instances of the old specimens with the new ones 
    auxiliaryRef.static.replaceStandardMonsterClasses(gameType.StandardMonsterClasses, 
            monsterReplacement);

    //Replace the special squad arrays
    auxiliaryRef.static.replaceSpecialSquad(gameType.ShortSpecialSquads, monsterReplacement);
    auxiliaryRef.static.replaceSpecialSquad(gameType.NormalSpecialSquads, monsterReplacement);
    auxiliaryRef.static.replaceSpecialSquad(gameType.LongSpecialSquads, monsterReplacement);
    auxiliaryRef.static.replaceSpecialSquad(gameType.FinalSquads, monsterReplacement);

    //Replace the boss class and fallback monster
    gameType.EndGameBossClass= endGameBossClass;
    gameType.FallbackMonsterClass= fallbackMonsterClass;

    if (broadcastStats) {
        serverLink= spawn(serverLinkClass);
        SetTimer(1,true);
    }

}

function Timer() {
    if (KFGameReplicationInfo(Level.Game.GameReplicationInfo).EndGameType != 0 &&
        (gameType.WaveNum != gameType.InitialWave || gameType.bWaveInProgress)) {
        serverLink.broadcastMatchResults(gameRules.deaths);
        if (broadcastStats && Level.NetMode != NM_DedicatedServer) {
            serverLink.broadcastPlayerStats(Level.GetLocalPlayerController().PlayerReplicationInfo);
        }
        SetTimer(0,false);
    }
}

function NotifyLogout(Controller Exiting) {
    if (broadcastStats && gameType.GameReplicationInfo.bMatchHasBegun && 
        (gameType.WaveNum != gameType.InitialWave || gameType.bWaveInProgress) &&
        Exiting != Level.GetLocalPlayerController()) {
        serverLink.broadcastPlayerStats(Exiting.PlayerReplicationInfo);
    }
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local int i, j;
    local PlayerReplicationInfo pri;
    local KFSXReplicationInfo kfsxri;

    if (PlayerReplicationInfo(Other) != none && 
            PlayerReplicationInfo(Other).Owner != none) {
        pri= PlayerReplicationInfo(Other);
        kfsxri= spawn(kfsxRIClass, pri.Owner);
        kfsxri.ownerPRI= pri;
    } else if (Weapon(Other) != none) {
        for(i= 0; i < ArrayCount(Weapon(Other).FireModeClass); i++) {
            for(j= 0; j < fireModeReplacement.Length; j++) {
                if (string(Weapon(Other).FireModeClass[i]) ~= fireModeReplacement[j].oldClass)
                    Weapon(Other).FireModeClass[i]= 
                            class<WeaponFire>(DynamicLoadObject(fireModeReplacement[j].newClass, class'Class'));
            }
        }
    }

    return true;
}

static function FillPlayInfo(PlayInfo PlayInfo) {
    local string controllers;
    local int i;
    
    Super.FillPlayInfo(PlayInfo);
    for(i= 0; i < default.compatibleControllers.Length; i++) {
        if (i != 0) 
            controllers$= ";";
        controllers$= default.compatibleControllers[i];
    }
    PlayInfo.AddSetting("KFStatsX", "playerController", "Compatability", 0, 1, "Select", controllers, "Xb",,true);
    PlayInfo.AddSetting("KFStatsX", "broadcastStats", "Broadcast Statistics", 0, 0, "Check");
    PlayInfo.AddSetting("KFStatsX", "localHostSteamId", "Local Host Steam ID", 0, 0, "Text", "128",,,true);
    PlayInfo.AddSetting("KFStatsX", "serverAddress", "Remote Server Address", 0, 0, "Text", "128");
    PlayInfo.AddSetting("KFStatsX", "serverPort", "Remote Server Port", 0, 0, "Text");
    PlayInfo.AddSetting("KFStatsX", "serverPwd", "Remote Server Password", 0, 0, "Text", "128");
}

static event string GetDescriptionText(string property) {
    switch(property) {
        case "broadcastStats":
            return "Check if the mutator should broadcast the stats to a remote server";
        case "localHostSteamId":
            return "Local host's steamid64.  Only used for solo or listen server games by the host.";
        case "serverAddress":
            return "Address of tracking server";
        case "serverPort":
            return "Port number of tracking server";
        case "serverPwd":
            return "Password of tracking server";
        case "playerController":
            return "Set compatability mode.  Only used other mutators with custom controllers are also being loaded ";
        default:
            return Super.GetDescriptionText(property);
    }
}

defaultproperties {
    GroupName="KFStatX"
    FriendlyName="KFStatsX v1.0"
    Description="Tracks statistics for each player, version 1.0"

    auxiliaryRef= class'Auxiliary'
    kfStatsXRules= class'KFSXGameRules'
    serverLinkClass= class'RemoteServerLink'

    endGameBossClass= "KFStatsX.ZombieBoss_KFSX"
    fallbackMonsterClass= "KFStatsX.ZombieStalker_KFSX"
    monsterReplacement(0)=(oldClass="KFChar.ZombieBloat",newClass="KFStatsX.ZombieBloat_KFSX")
    monsterReplacement(1)=(oldClass="KFChar.ZombieClot",newClass="KFStatsX.ZombieClot_KFSX")
    monsterReplacement(2)=(oldClass="KFChar.ZombieCrawler",newClass="KFStatsX.ZombieCrawler_KFSX")
    monsterReplacement(3)=(oldClass="KFChar.ZombieFleshPound",newClass="KFStatsX.ZombieFleshpound_KFSX")
    monsterReplacement(4)=(oldClass="KFChar.ZombieGorefast",newClass="KFStatsX.ZombieGorefast_KFSX")
    monsterReplacement(5)=(oldClass="KFChar.ZombieHusk",newClass="KFStatsX.ZombieHusk_KFSX")
    monsterReplacement(6)=(oldClass="KFChar.ZombieScrake",newClass="KFStatsX.ZombieScrake_KFSX")
    monsterReplacement(7)=(oldClass="KFChar.ZombieSiren",newClass="KFStatsX.ZombieSiren_KFSX")
    monsterReplacement(8)=(oldClass="KFChar.ZombieStalker",newClass="KFStatsX.ZombieStalker_KFSX")

    fireModeReplacement(0)=(oldClass="KFMod.FragFire",NewClass="KFStatsX.FragFire_KFSX")
    fireModeReplacement(1)=(oldClass="KFMod.HuskGunFire",NewClass="KFStatsX.HuskGunFire_KFSX")
    fireModeReplacement(2)=(oldClass="KFMod.WeldFire",NewClass="KFStatsX.WeldFire_KFSX")
    fireModeReplacement(3)=(oldClass="KFMod.UnWeldFire",NewClass="KFStatsX.UnWeldFire_KFSX")
    fireModeReplacement(4)=(oldClass="KFMod.CrossbowFire",NewClass="KFStatsX.CrossbowFire_KFSX")

    kfsxRIClass= class'KFSXReplicationInfo'
    playerController= "KFStatsX.KFSXPlayerController"
    compatibleControllers(0)= "KFStatsX.KFSXPlayerController;Vanilla KF"
}
