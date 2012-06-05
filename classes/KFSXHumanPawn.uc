class KFSXHumanPawn extends KFHumanPawn;

var float oldPrimaryAmmo, oldSecondaryAmmo;

simulated function StopFiring() {
    local float newPrimaryAmmo, newSecondaryAmmo;
    local float primaryMax, secondaryMax;
    super.StopFiring();

    if (KFMeleeGun(Weapon) == none && Welder(Weapon) == none && Syringe(Weapon) == none) {
        Weapon.GetAmmoCount(primaryMax, newPrimaryAmmo);
        KFSXPlayerController(Controller).kfsxPRI.accum(GetItemName(string(Weapon.GetFireMode(0).class)),oldPrimaryAmmo-newPrimaryAmmo);
        oldPrimaryAmmo= newPrimaryAmmo;
        if (KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo) {
            KFWeapon(Weapon).GetSecondaryAmmoCount(secondaryMax, newSecondaryAmmo);
            KFSXPlayerController(Controller).kfsxPRI.accum(GetItemName(string(Weapon.GetFireMode(1).class)),oldSecondaryAmmo-newSecondaryAmmo);
            oldSecondaryAmmo= newSecondaryAmmo;
        }
    }
}

simulated function Fire(optional float F) {
    local float primaryMax;
    local float secondaryMax;

    super.Fire(F);
    Weapon.GetAmmoCount(primaryMax, oldPrimaryAmmo);
    if(KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo) {
        KFWeapon(Weapon).GetSecondaryAmmoCount(secondaryMax, oldSecondaryAmmo);
    }
}

simulated function AltFire(optional float F) {
    local float primaryMax;
    local float secondaryMax;

    super.AltFire(F);
    Weapon.GetAmmoCount(primaryMax, oldPrimaryAmmo);
    if(KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo) {
        KFWeapon(Weapon).GetSecondaryAmmoCount(secondaryMax, oldSecondaryAmmo);
    }
}


