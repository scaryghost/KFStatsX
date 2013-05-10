/**
 * Special fire mode for unwelding to track door hp
 * @author etsai (Scary Ghost)
 */
class UnWeldFire_KFSX extends KFMod.UnWeldFire;

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
        kfsxri.summary.accum(kfsxri.welding, oldWeldStrength - targetDoor.MyTrigger.WeldStrength);
    }
}
