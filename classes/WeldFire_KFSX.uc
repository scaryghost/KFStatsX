/**
 * Special fire mode for welding that tracks door hp
 * @author etsai (Scary Ghost)
 */
class WeldFire_KFSX extends KFMod.WeldFire;

simulated Function timer() {
    local KFDoorMover targetDoor;
    local float oldWeldStrength;
    local KFSXReplicationInfo lri;

    targetDoor= GetDoor();
    lri= class'KFSXReplicationInfo'.static.findKFSXlri(Instigator.PlayerReplicationInfo);
    if (targetDoor != none) {
        oldWeldStrength= targetDoor.MyTrigger.WeldStrength;
    }
    super.timer();
    if (targetDoor != none && lri != none) {
        lri.player.accum(lri.welding, targetDoor.MyTrigger.WeldStrength - oldWeldStrength);
    }
}
