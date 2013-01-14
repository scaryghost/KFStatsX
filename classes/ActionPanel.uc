/**
 * Panel displaying action counts
 * @author etsai (Scary Ghost)
 */
class ActionPanel extends StatsPanelBase;

function InitComponent(GUIController MyController, GUIComponent MyComponent) {
    super.InitComponent(MyController, MyComponent);
    statsInfo= class'KFSXReplicationInfo'.static.findKFSXri(PlayerOwner().PlayerReplicationInfo).actions;
}

function updateStatsInfo(KFSXReplicationInfo kfsxRI) {
    statsInfo= kfsxRI.actions;
    super.updateStatsInfo(kfsxRI);
}
