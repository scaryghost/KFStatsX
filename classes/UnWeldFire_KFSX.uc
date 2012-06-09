class UnWeldFire_KFSX extends KFMod.UnWeldFire;

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
        playerLRI.accum(playerLRI.getKey(playerLRI.StatKeys.Welding), 
                oldWeldStrength - targetDoor.MyTrigger.WeldStrength);
    }
}
