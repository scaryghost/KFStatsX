class PlayerStatsPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    ownerLRI= KFSXPlayerController(PlayerOwner()).playerLRI;
    super.ShowPanel(bShow);
}
