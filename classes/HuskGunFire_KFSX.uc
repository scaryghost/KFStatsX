/**
 * Special fire mode for the husk gun that tracks the ammo usage
 * @author etsai (Sacry Ghost)
 */
class HuskGunFire_KFSX extends HuskGunFire;

function DoFireEffect() {
    local int fuelAmount;

    super.DoFireEffect();
    /** Use the same ammo formula as in HuskGunFire.ModeDoFire() */
    if (HoldTime < MaxChargeTime) {
        fuelAmount= 1.0 + (HoldTime/(MaxChargeTime/9.0));
    } else {
        fuelAmount= 10;
    }
    KFSXPlayerController(Instigator.Controller).weaponLRI.stats.accum(Weapon.ItemName, fuelAmount);
}
