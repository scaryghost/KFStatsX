/**
 * Special fire mode for unwelding to track door hp
 * @author etsai (Scary Ghost)
 */
class UnWeldFire_KFSX extends KFMod.UnWeldFire;

simulated Function timer() {
    local KFDoorMover targetDoor;
    local float oldWeldStrength;
    local KFSXLinkedReplicationInfo lri;

    targetDoor= GetDoor();
    lri= class'KFSXLinkedReplicationInfo'.static.findKFSXlri(Instigator.PlayerReplicationInfo);
    if (targetDoor != none) {
        oldWeldStrength= targetDoor.MyTrigger.WeldStrength;
    }
    super.timer();
    if (targetDoor != none && lri != none) {
        lri.playerInfo.accum(lri.welding, oldWeldStrength - targetDoor.MyTrigger.WeldStrength);
    }
}
