/**
 * Special fire mode for the husk gun that tracks the ammo usage
 * @author etsai (Sacry Ghost)
 */
class HuskGunFire_KFSX extends HuskGunFire;

function DoFireEffect() {
    local int fuelAmount;
    local KFSXReplicationInfo kfsxri;

    super.DoFireEffect();
    /** Use the same ammo formula as in HuskGunFire.ModeDoFire() */
    if (HoldTime < MaxChargeTime) {
        fuelAmount= 1.0 + (HoldTime/(MaxChargeTime/9.0));
    } else {
        fuelAmount= 10;
    }
    if( Weapon.AmmoAmount(ThisModeNum) < fuelAmount ) {
        fuelAmount= Weapon.AmmoAmount(ThisModeNum);
    }
    kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Instigator.PlayerReplicationInfo);
    kfsxri.weapons.accum(Weapon.ItemName, fuelAmount);
}
