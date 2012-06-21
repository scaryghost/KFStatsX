/**
 * Displays stats from killsInfo
 * @author etsai (Scary Ghost)
 */
class KillStatsPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    if (statsInfo == none) {
        statsInfo= class'KFSXLinkedReplicationInfo'.static
                .findKFSXlri(PlayerOwner().PlayerReplicationInfo).kills;
    }
    super.ShowPanel(bShow);
}
