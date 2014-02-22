/**
 * Mutator to load in the KFStatsX modifications
 * @author etsai (Scary Ghost)
 */
class KFSXMutator extends Mutator
    dependson(PacketCreator)
    config(KFStatsX);

struct ReplacePair {
    var class<Object> oldClass;
    var class<Object> newClass;
};

/** True if the player and match stats should be saved remotely */
var() config bool broadcastStats;
/** True if version 3 of the stat packets should be used */
var() config bool useV3Packets;
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
var KFGameType gameType;
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

var array<ZombieFleshPound> passiveFPs, frustratedFPs;
var PacketCreator.WaveSummary summary;
var bool broadcastedWaveEnd, broadcastedFinalWave;

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
        AddToPackageMap();
        if (gameType.PlayerControllerClass != class'KFSXPlayerController') {
            AddToPackageMap(string(gameType.PlayerControllerClass.Outer.name));
        }
    }

    if (broadcastStats) {
        serverLink= Spawn(serverLinkClass);
        if (useV3Packets) {
            serverLink.packetCreator= Spawn(class'V3PacketCreator');
        } else {
            serverLink.packetCreator= Spawn(class'V2PacketCreator');
        }
        serverLink.packetCreator.password= serverPwd;
        summary.perks= Spawn(class'SortedMap');
        SetTimer(1, true);
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
            targetRI= kfsxRIClass.static.findKFSXri(Pawn(passiveFPs[i].Controller.Target).PlayerReplicationInfo);
            targetRI.actions.accum(targetRI.fleshpoundsRaged, 1);
            frustratedFPs[frustratedFPs.length]= passiveFPs[i];
            passiveFPs.remove(i, 1);
            end--;
        } else {
            i++;
        }
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
        } else {
            i++;
        }
    }
}

function ServerTraveling(string URL, bool bItems) {
    if (broadcastStats && shouldBroadcast() && !broadcastedFinalWave) {
        if (KFStoryGameInfo(gameType) == none) {
            broadcastWaveStats(gameType.WaveNum + 1);
        }
        serverLink.broadcastMatchResults();
        SetTimer(0, false);
    }
    super.ServerTraveling(URL, bItems);
}

function broadcastWaveStats(int wave) {
    gameRules.setWave(wave);
    summary.end= Level.GRI.ElapsedTime;
    if (summary.start == -1) {
        summary.end= summary.start - 1;
    }
    summary.wave= wave;
    summary.result= byte(KFGameReplicationInfo(gameType.GameReplicationInfo).EndGameType != 1 && 
        (xVotingHandler(gameType.VotingHandler) == none || 
        (!xVotingHandler(gameType.VotingHandler).bLevelSwitchPending)));
    
    serverLink.broadcastWaveSummary(summary);
    gameRules.sendWaveData(serverLink);
    summary.start= -1;
}

function bool shouldBroadcast() {
    local bool waveModeCheck, storyModeCheck;

    waveModeCheck= (KFStoryGameInfo(gameType) == none && (gameType.WaveNum != gameType.InitialWave || gameType.bWaveInProgress));
    storyModeCheck= KFStoryGameInfo(gameType) != none &&  KFStoryGameInfo(gameType).CurrentObjectiveIdx != -1;
    return  waveModeCheck || storyModeCheck;
}

function Timer() {
    local Controller cIt;
    local Inventory invIt;
    local SortedMap perkInventory;

    if (broadcastStats && !broadcastedWaveEnd && !gameType.bWaveInProgress) {
        broadcastWaveStats(gameType.WaveNum);

        gameRules.resetWaveData();
        summary.perks.clear();

        broadcastedWaveEnd= !broadcastedWaveEnd;
    } else if (broadcastStats && broadcastedWaveEnd && gameType.bWaveInProgress) {
        summary.start= Level.GRI.ElapsedTime;
        for(cIt= Level.ControllerList; cIt != none; cIt= cIt.NextController) {
            if (cIt.bIsPlayer && cIt.Pawn != none && KFPlayerReplicationInfo(cIt.PlayerReplicationInfo) != none) {
                summary.perks.accum(GetItemName(string(KFPlayerReplicationInfo(cIt.PlayerReplicationInfo).ClientVeteranSkill)), 1);
                perkInventory= gameRules.weapons.getStatsMap(KFPlayerReplicationInfo(cIt.PlayerReplicationInfo).ClientVeteranSkill);
                for(invIt= cIt.Pawn.Inventory; invIt != none; invIt= invIt.Inventory) {
                    if (invIt.IsA('Weapon')) {
                        perkInventory.accum(Weapon(invIt).ItemName, 1);
                    }
                }
            }
        }
        broadcastedWaveEnd= !broadcastedWaveEnd;
    }
    if (broadcastStats && KFGameReplicationInfo(gameType.GameReplicationInfo).EndGameType != 0 && shouldBroadcast() ) {
        if (KFGameReplicationInfo(gameType.GameReplicationInfo).EndGameType == 1 && KFStoryGameInfo(gameType) == none) {
            broadcastWaveStats(gameType.WaveNum + 1);
        }
        broadcastedFinalWave= true;
        serverLink.broadcastMatchResults();
        if (Level.NetMode != NM_DedicatedServer) {
            serverLink.broadcastPlayerStats(Level.GetLocalPlayerController().PlayerReplicationInfo);
        }
        SetTimer(0,false);
    }
}

function NotifyLogout(Controller Exiting) {
    if (broadcastStats && gameType.GameReplicationInfo.bMatchHasBegun && shouldBroadcast() &&
        Exiting != Level.GetLocalPlayerController()) {
        serverLink.broadcastPlayerStats(Exiting.PlayerReplicationInfo);
    }
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local PlayerReplicationInfo pri;
    local KFSXReplicationInfo kfsxri;

    if (PlayerReplicationInfo(Other) != none && 
            PlayerReplicationInfo(Other).Owner != none) {
        pri= PlayerReplicationInfo(Other);
        kfsxri= spawn(kfsxRIClass, pri.Owner);
        kfsxri.ownerPRI= pri;
        kfsxri.joinedDuringFinale= gameType.bWaveInProgress && 
                (gameType.GetCurrentWaveNum() == gameType.getFinalWaveNum() + 1);
    } else if (ZombieFleshPound(Other) != none) {
        passiveFPs[passiveFPs.length]= ZombieFleshPound(Other);
    }

    return true;
}

static function FillPlayInfo(PlayInfo PlayInfo) {
    local string controllers;
    
    Super.FillPlayInfo(PlayInfo);
    controllers= class'PacketCreator'.static.join(default.compatibleControllers, ";");

    PlayInfo.AddSetting(default.GroupName, "playerController", "Compatability", 0, 1, "Select", controllers, "Xb",,true);
    PlayInfo.AddSetting(default.GroupName, "broadcastStats", "Broadcast Statistics", 0, 0, "Check");
    PlayInfo.AddSetting(default.GroupName, "useV3Packets", "Use V3 Packet Format", 0, 0, "Check",,,,true);
    PlayInfo.AddSetting(default.GroupName, "localHostSteamId", "Local Host Steam ID", 0, 0, "Text", "128",,,true);
    PlayInfo.AddSetting(default.GroupName, "serverAddress", "Remote Server Address", 0, 0, "Text", "128");
    PlayInfo.AddSetting(default.GroupName, "serverPort", "Remote Server Port", 0, 0, "Text");
    PlayInfo.AddSetting(default.GroupName, "serverPwd", "Remote Server Password", 0, 0, "Text", "128");
}

static event string GetDescriptionText(string property) {
    switch(property) {
        case "broadcastStats":
            return "Select if the mutator should broadcast the stats to a remote server";
        case "useV3Packets":
            return "Select to use Version 3 of the UDP packet format";
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
    FriendlyName="KFStatsX v3.2.1"
    Description="Tracks player and match statistics"

    kfStatsXRules= class'KFSXGameRules'
    serverLinkClass= class'RemoteServerLink'

    kfsxRIClass= class'KFSXReplicationInfo'
    playerController= "KFStatsX.KFSXPlayerController"
    compatibleControllers(0)= "KFStatsX.KFSXPlayerController;Vanilla KF"

    broadcastedWaveEnd= true
}
