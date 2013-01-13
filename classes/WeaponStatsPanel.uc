/**
 * Panel displaying stats from weaponInfo
 * @author etsai (Scary Ghost)
 */
class WeaponStatsPanel extends StatsPanelBase;

function InitComponent(GUIController MyController, GUIComponent MyComponent) {
    super.InitComponent(MyController, MyComponent);
    statsInfo= class'KFSXReplicationInfo'.static.findKFSXri(PlayerOwner().PlayerReplicationInfo).weapons;
}

function updateStatsInfo(KFSXReplicationInfo kfsxRI) {
    statsInfo= kfsxRI.weapons;
}
