class KFSXHumanPawn extends KFHumanPawn;

var float oldPrimaryAmmo, oldSecondaryAmmo;

simulated function StopFiring() {
    local float newPrimaryAmmo, newSecondaryAmmo;
    local float primaryMax, secondaryMax;
    super.StopFiring();

    Weapon.GetAmmoCount(primaryMax, newPrimaryAmmo);
    KFSXPlayerController(Controller).kfsxPRI.accum(string(Weapon.GetFireMode(0).class),oldPrimaryAmmo-newPrimaryAmmo);
    if (KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo) {
        KFWeapon(Weapon).GetSecondaryAmmoCount(secondaryMax, newSecondaryAmmo);
        KFSXPlayerController(Controller).kfsxPRI.accum(string(Weapon.GetFireMode(1).class),oldSecondaryAmmo-newSecondaryAmmo);
    }
}
