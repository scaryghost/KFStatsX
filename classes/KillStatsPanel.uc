/**
 * Displays stats from KillsLRI
 * @author etsai (Scary Ghost)
 */
class KillStatsPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    ownerLRI= KFSXPlayerController(PlayerOwner()).killsLRI;
    super.ShowPanel(bShow);
}
