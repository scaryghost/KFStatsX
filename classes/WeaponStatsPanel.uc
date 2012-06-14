/**
 * Panel displaying stats from weaponInfo
 * @author etsai (Scary Ghost)
 */
class WeaponStatsPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    if (statsInfo == none) {
        statsInfo= class'KFSXLinkedReplicationInfo'.static.findKFSXlri(PlayerOwner().PlayerReplicationInfo).playerInfo;
    }
    super.ShowPanel(bShow);
}
