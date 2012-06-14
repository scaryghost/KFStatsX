/**
 * Displays the stats from playerInfo
 * @author etsai (Scary Ghost)
 */
class PlayerStatsPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    if (statsInfo == none) {
        statsInfo= class'KFSXLinkedReplicationInfo'.static
                .findKFSXlri(PlayerOwner().PlayerReplicationInfo).playerInfo;
    }
    super.ShowPanel(bShow);
}
