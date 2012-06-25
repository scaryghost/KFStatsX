/** 
 * Custom projectile that increments Healed_Teammates
 * Heal_Darts_Landed
 * @author etsai (Scary Ghost)
 */
class MP5MHealingProjectile_KFSX extends MP5MHealinglProjectile;

simulated function ProcessTouch(Actor Other, Vector HitLocation) {
    local KFSXReplicationInfo kfsxri;

    super.ProcessTouch(Other, HitLocation);
    if (KFPawn(Other) != none) {
        kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(KFPawn(Other).PlayerReplicationInfo);
        kfsxri.actions.accum(kfsxri.healDartsConnected, 1);
        kfsxri.actions.accum(kfsxri.healedTeammates, 1);
    }
}
