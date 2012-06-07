class PlayerStatsPanel extends StatsPanelBase;

function fillDescription() {
    ownerLRI= KFSXPlayerController(PlayerOwner()).playerLRI;
    super.fillDescription();
}
