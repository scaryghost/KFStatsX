/**
 * Custom fleshpound controller for the mutator
 * @author etsai (Scary Ghost)
 */
class FleshpoundZombieController_KFSX extends KFChar.FleshpoundZombieController;

state ZombieCharge {
    function EndState() {
        local KFSXReplicationInfo targetRI;

        if (ZombieFleshPound(pawn) != none && ZombieFleshPound(pawn).bFrustrated) {
            targetRI= class'KFSXReplicationInfo'.static.findKFSXri(Pawn(Target).PlayerReplicationInfo);
            if (targetRI != none) {
                targetRI.actions.accum(targetRI.fleshpoundsRaged, 1);
            }
        }
    }
}
