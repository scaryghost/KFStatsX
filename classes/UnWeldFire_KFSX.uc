/**
 * Special fire mode for unwelding to track door hp
 * @author etsai (Scary Ghost)
 */
class UnWeldFire_KFSX extends KFMod.UnWeldFire;

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
        lri.player.accum(lri.welding, oldWeldStrength - targetDoor.MyTrigger.WeldStrength);
    }
}
