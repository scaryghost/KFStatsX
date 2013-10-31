/**
 * Custom controller used by the KFStatsX mutator
 * @author etsai (Scary Ghost)
 */
class KFSXPlayerController extends KFPlayerController_Story;

var bool addedInteraction;
var string interactionName;

simulated event PostBeginPlay() {
    if (KF_StoryGRI(Level.GRI) == None) {
        LobbyMenuClassString= class'KFMod.KFPlayerController'.default.LobbyMenuClassString;
        PlayerReplicationInfoClass= class'KFMod.KFPlayerController'.default.PlayerReplicationInfoClass;
    }
    Super.PostBeginPlay();
}

simulated function UpdateHintManagement(bool bUseHints) {
    if (KF_StoryGRI(Level.GRI) != None) {
        Super.UpdateHintManagement(bUseHints);
    } else {
        Super(KFPlayerController).UpdateHintManagement(bUseHints);
    }
}

function ShowBuyMenu(string wlTag,float maxweight) {
    if (KF_StoryGRI(Level.GRI) != None) {
        Super.ShowBuyMenu(wlTag, maxweight);
    } else {
        Super(KFPlayerController).ShowBuyMenu(wlTag, maxweight);
    }
}

function SelectVeterancy(class<KFVeterancyTypes> VetSkill, optional bool bForceChange) {
    if (KF_StoryGRI(Level.GRI) != None) {
        Super.SelectVeterancy(VetSkill, bForceChange);
    } else {
        Super(KFPlayerController).SelectVeterancy(VetSkill, bForceChange);
    }
}

function SetPawnClass(string inClass, string inCharacter) {
    super.SetPawnClass(inClass, inCharacter);
    PawnClass= Class'KFSXHumanPawn';
}

simulated event PlayerTick(float DeltaTime) {
    super.PlayerTick(DeltaTime);
    if (!addedInteraction && (Level.NetMode == NM_DedicatedServer && Role < ROLE_Authority || Level.NetMode != NM_DedicatedServer)) {
        Player.InteractionMaster.AddInteraction(interactionName, Player);
        addedInteraction= true;
    }
}

defaultproperties {
    interactionName= "KFStatsX.KFSXInteraction"
}
