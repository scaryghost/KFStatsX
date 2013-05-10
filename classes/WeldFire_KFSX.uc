/**
 * Special fire mode for welding that tracks door hp
 * @author etsai (Scary Ghost)
 */
class WeldFire_KFSX extends KFMod.WeldFire;

simulated Function timer() {
    local KFDoorMover targetDoor;
    local float oldWeldStrength;
    local KFSXReplicationInfo kfsxri;

    targetDoor= GetDoor();
    kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Instigator.PlayerReplicationInfo);
    if (targetDoor != none) {
        oldWeldStrength= targetDoor.MyTrigger.WeldStrength;
    }
    super.timer();
    if (targetDoor != none && kfsxri != none) {
        kfsxri.summary.accum(kfsxri.welding, targetDoor.MyTrigger.WeldStrength - oldWeldStrength);
    }
}
