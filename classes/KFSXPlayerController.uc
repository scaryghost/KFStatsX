/**
 * Custom controller used by the KFStatsX mutator
 * @author etsai (Scary Ghost)
 */
class KFSXPlayerController extends KFPlayerController;

var bool addedInteraction;
var string interactionName;

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

/**
 * Custom console command to bring up the stats menu
 */
exec function InGameStats() {
    ClientOpenMenu("KFStatsX.StatsMenu");
}

defaultproperties {
    interactionName= "KFStatsX.KFSXInteraction"
}
