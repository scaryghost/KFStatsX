/**
 * Custom controller used by the KFStatsX mutator
 * @author etsai (Scary Ghost)
 */
class KFSXPlayerController extends KFPlayerController;

function SetPawnClass(string inClass, string inCharacter) {
    super.SetPawnClass(inClass, inCharacter);
    PawnClass= Class'KFSXHumanPawn';
}

/**
 * Custom console command to bring up the stats menu
 */
exec function InGameStats() {
    ClientOpenMenu("KFStatsX.StatsMenu");
}
