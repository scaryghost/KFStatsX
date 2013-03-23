/**
 * Mutator to load in the KFStatsX modifications
 * @author etsai (Scary Ghost)
 */
class KFSXMutator extends Mutator
    config(KFStatsX);

struct ReplacePair {
    var class<Object> oldClass;
    var class<Object> newClass;
};

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
/** KFStatsX game rules object */
var KFSXGameRules gameRules;
/** Reference to the game rules used by KFStatsX */
var class<KFSXGameRules> kfStatsXRules;

/** Remote server link class */
var class<RemoteServerLink> serverLinkClass;
/** Link to the remote tracking server */
var transient RemoteServerLink serverLink;

/** List of fire modes to replace */
var array<ReplacePair> fireModeReplacement;

var array<ZombieFleshPound> passiveFPs, frustratedFPs;

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

    if (broadcastStats) {
        serverLink= spawn(serverLinkClass);
        SetTimer(1,true);
    }

}

function Tick(float DeltaTime) {
    local int i, end;
    local KFSXReplicationInfo targetRI;

    end= passiveFPs.length;
    while(i < end) {
        if(passiveFPs[i] == None || passiveFPs[i].Controller == None) {
            passiveFPs.remove(i, 1);
            end--;
        } else if (passiveFPs[i].Controller.IsInState('WaitForAnim') && passiveFPs[i].bFrustrated) {
            targetRI= class'KFSXReplicationInfo'.static.findKFSXri(Pawn(passiveFPs[i].Controller.Target).PlayerReplicationInfo);
            targetRI.actions.accum(targetRI.fleshpoundsRaged, 1);
            frustratedFPs[frustratedFPs.length]= passiveFPs[i];
            passiveFPs.remove(i, 1);
            end--;
        }
        i++;
    }

    end= frustratedFPs.length;
    i= 0;
    while(i < end) {
        if (frustratedFPs[i] == none) {
            frustratedFPs.remove(i, 1);
            end--;
        } else if (!frustratedFPs[i].IsInState('BeginRaging') && !frustratedFPs[i].IsInState('RageCharging')) {
            passiveFPs[passiveFPs.length]= frustratedFPs[i];
            frustratedFPs.remove(i, 1);
            end--;
        }
        i++;
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
                if (Weapon(Other).FireModeClass[i] == class<WeaponFire>(fireModeReplacement[j].oldClass)) {
                    Weapon(Other).FireModeClass[i]= class<WeaponFire>(fireModeReplacement[j].newClass);
                }
            }
        }
    } else if (ZombieFleshPound(Other) != none) {
        passiveFPs[passiveFPs.length]= ZombieFleshPound(Other);
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
            return "Select if the mutator should broadcast the stats to a remote server";
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
    FriendlyName="KFStatsX v2.1"
    Description="Tracks statistics for each player, version 2.1"

    kfStatsXRules= class'KFSXGameRules'
    serverLinkClass= class'RemoteServerLink'

    fireModeReplacement(0)=(oldClass=class'HuskGunFire',NewClass=class'HuskGunFire_KFSX')
    fireModeReplacement(1)=(oldClass=class'WeldFire',NewClass=class'WeldFire_KFSX')
    fireModeReplacement(2)=(oldClass=class'UnWeldFire',NewClass=class'UnWeldFire_KFSX')
    fireModeReplacement(3)=(oldClass=class'CrossbowFire',NewClass=class'CrossbowFire_KFSX')
    fireModeReplacement(4)=(oldClass=class'CrossbuzzsawFire',NewClass=class'CrossbuzzsawFire_KFSX')

    kfsxRIClass= class'KFSXReplicationInfo'
    playerController= "KFStatsX.KFSXPlayerController"
    compatibleControllers(0)= "KFStatsX.KFSXPlayerController;Vanilla KF"
}
