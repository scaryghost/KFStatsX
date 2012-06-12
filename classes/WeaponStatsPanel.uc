/**
 * Panel displaying stats from WeaponLRI
 * @author etsai (Scary Ghost)
 */
class WeaponStatsPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    ownerLRI= KFSXPlayerController(PlayerOwner()).weaponLRI;
    super.ShowPanel(bShow);
}
