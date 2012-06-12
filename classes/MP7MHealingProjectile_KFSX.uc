/** 
 * Custom projectile that increments Healed_Teammates
 * Heal_Darts_Landed
 * @author etsai (Scary Ghost)
 */
class MP7MHealingProjectile_KFSX extends MP7MHealinglProjectile;

simulated function ProcessTouch(Actor Other, Vector HitLocation) {
    local PlayerLRI playerLRI;

    super.ProcessTouch(Other, HitLocation);
    if (KFPawn(Other) != none) {
        playerLRI= KFSXHumanPawn(Instigator).playerLRI;
        playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Heal_Darts_Landed), 1);
        playerLRI.stats.accum(playerLRI.getKey(playerLRI.StatKeys.Healed_Teammates), 1);
    }
}
