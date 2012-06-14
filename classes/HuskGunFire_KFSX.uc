/**
 * Special fire mode for the husk gun that tracks the ammo usage
 * @author etsai (Sacry Ghost)
 */
class HuskGunFire_KFSX extends HuskGunFire;

function DoFireEffect() {
    local int fuelAmount;
    local KFSXLinkedReplicationInfo lri;

    super.DoFireEffect();
    /** Use the same ammo formula as in HuskGunFire.ModeDoFire() */
    if (HoldTime < MaxChargeTime) {
        fuelAmount= 1.0 + (HoldTime/(MaxChargeTime/9.0));
    } else {
        fuelAmount= 10;
    }
    lri= class'KFSXLinkedReplicationInfo'.static.findKFSXlri(Instigator.PlayerReplicationInfo);
    lri.weaponInfo.accum(Weapon.ItemName, fuelAmount);
}
