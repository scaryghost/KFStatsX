class KillStatsPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    ownerLRI= KFSXPlayerController(PlayerOwner()).killsLRI;
    super.ShowPanel(bShow);
}
