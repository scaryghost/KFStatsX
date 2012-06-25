/**
 * Panel displaying stats from weaponInfo
 * @author etsai (Scary Ghost)
 */
class WeaponStatsPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    if (statsInfo == none) {
        statsInfo= class'KFSXReplicationInfo'.static
                .findKFSXlri(PlayerOwner().PlayerReplicationInfo).weapons;
    }
    super.ShowPanel(bShow);
}
