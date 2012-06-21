/**
 * Panel displaying perk stats
 * @author etsai (Scary Ghost)
 */
class PerksPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    if (statsInfo == none) {
        statsInfo= class'KFSXLinkedReplicationInfo'.static
                .findKFSXlri(PlayerOwner().PlayerReplicationInfo).perks;
    }
    super.ShowPanel(bShow);
}
