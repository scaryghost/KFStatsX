/**
 * Displays general player info
 * @author etsai (Scary Ghost)
 */
class PlayerStatsPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    if (statsInfo == none) {
        statsInfo= class'KFSXReplicationInfo'.static
                .findKFSXri(PlayerOwner().PlayerReplicationInfo).player;
    }
    super.ShowPanel(bShow);
}
