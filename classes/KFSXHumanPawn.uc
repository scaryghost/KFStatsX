class KFSXHumanPawn extends KFHumanPawn;

var float oldPrimaryAmmo, oldSecondaryAmmo;

simulated function StartFiringX(bool bAltFire, bool bRapid) {
    if (KFMeleeGun(Weapon) != none && Syringe(Weapon) == none && Welder(Weapon) == none) {
        KFSXPlayerController(Controller).kfsxPRI.accum(Weapon.ItemName, 1);
    }
}

simulated function StopFiring() {
    local float newPrimaryAmmo, newSecondaryAmmo;
    local float primaryMax, secondaryMax;
    super.StopFiring();

    if (KFMeleeGun(Weapon) == none) {
        Weapon.GetAmmoCount(primaryMax, newPrimaryAmmo);
        KFSXPlayerController(Controller).kfsxPRI.accum(Weapon.ItemName,oldPrimaryAmmo-newPrimaryAmmo);
        oldPrimaryAmmo= newPrimaryAmmo;
        if (KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo) {
            KFWeapon(Weapon).GetSecondaryAmmoCount(secondaryMax, newSecondaryAmmo);
            KFSXPlayerController(Controller).kfsxPRI.accum(Weapon.ItemName$" Alt",oldSecondaryAmmo-newSecondaryAmmo);
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

