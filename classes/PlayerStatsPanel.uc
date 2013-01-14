/**
 * Displays general player info
 * @author etsai (Scary Ghost)
 */
class PlayerStatsPanel extends StatsPanelBase;

function InitComponent(GUIController MyController, GUIComponent MyComponent) {
    super.InitComponent(MyController, MyComponent);
    statsInfo= class'KFSXReplicationInfo'.static.findKFSXri(PlayerOwner().PlayerReplicationInfo).player;
}

function updateStatsInfo(KFSXReplicationInfo kfsxRI) {
    statsInfo= kfsxRI.player;
    super.updateStatsInfo(kfsxRI);
}
