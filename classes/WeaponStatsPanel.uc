class WeaponStatsPanel extends StatsPanelBase;

function fillDescription() {
    ownerLRI= KFSXPlayerController(PlayerOwner()).weaponLRI;
    super.fillDescription();
}
