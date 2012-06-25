/**
 * Panel displaying perk stats
 * @author etsai (Scary Ghost)
 */
class PerksPanel extends StatsPanelBase;

function ShowPanel(bool bShow) {
    if (statsInfo == none) {
        statsInfo= class'KFSXReplicationInfo'.static
                .findKFSXri(PlayerOwner().PlayerReplicationInfo).perks;
    }
    super.ShowPanel(bShow);
}
