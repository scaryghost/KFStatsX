/**
 * Special fire mode for welding that tracks door hp
 * @author etsai (Scary Ghost)
 */
class WeldFire_KFSX extends KFMod.WeldFire;

simulated Function timer() {
    local KFDoorMover targetDoor;
    local float oldWeldStrength;
    local PlayerLRI playerLRI;

    targetDoor= GetDoor();
    playerLRI= KFSXPlayerController(Instigator.Controller).playerLRI;
    if (targetDoor != none) {
        oldWeldStrength= targetDoor.MyTrigger.WeldStrength;
    }
    super.timer();
    if (targetDoor != none && playerLRI != none) {
        playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Welding), 
                targetDoor.MyTrigger.WeldStrength - oldWeldStrength);
    }
}
