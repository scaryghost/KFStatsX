/**
 * Panel displaying action counts
 * @author etsai (Scary Ghost)
 */
class ActionPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    if (statsInfo == none) {
        statsInfo= class'KFSXReplicationInfo'.static
                .findKFSXlri(PlayerOwner().PlayerReplicationInfo).actions;
    }
    super.ShowPanel(bShow);
}
