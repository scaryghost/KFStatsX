/**
 * This class is deprecated and will be removed when version 4.0 is 
 * released.  The KFSXHumanPawn class extends from the story mode variant 
 * and manages all the different differences between wave and story mode.
 */
class KFSXPlayerController_Story extends KFStoryGame.KFPlayerController_Story;

var bool addedInteraction;
var string interactionName;

function SetPawnClass(string inClass, string inCharacter) {
    super.SetPawnClass(inClass, inCharacter);
    PawnClass= Class'KFSXHumanPawn_Story';
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
