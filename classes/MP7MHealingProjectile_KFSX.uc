/** 
 * Custom projectile that increments Healed_Teammates
 * Heal_Darts_Landed
 * @author etsai (Scary Ghost)
 */
class MP7MHealingProjectile_KFSX extends MP7MHealinglProjectile;

simulated function ProcessTouch(Actor Other, Vector HitLocation) {
    local KFSXReplicationInfo lri;

    super.ProcessTouch(Other, HitLocation);
    if (KFPawn(Other) != none) {
        lri= class'KFSXReplicationInfo'.static.findKFSXlri(KFPawn(Other).PlayerReplicationInfo);
        lri.actions.accum(lri.healDartsConnected, 1);
        lri.actions.accum(lri.healedTeammates, 1);
    }
}
