/**
 * Displays stats from killsInfo
 * @author etsai (Scary Ghost)
 */
class KillStatsPanel extends StatsPanelBase;

function InitComponent(GUIController MyController, GUIComponent MyComponent) {
    super.InitComponent(MyController, MyComponent);
    statsInfo= class'KFSXReplicationInfo'.static.findKFSXri(PlayerOwner().PlayerReplicationInfo).kills;
}

function updateStatsInfo(KFSXReplicationInfo kfsxRI) {
    statsInfo= kfsxRI.kills;
    super.updateStatsInfo(kfsxRI);
}
