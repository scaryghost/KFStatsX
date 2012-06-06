class KFSXHumanPawn extends KFHumanPawn;

var float oldPrimaryAmmo, oldSecondaryAmmo;

simulated function StartFiringX(bool bAltFire, bool bRapid) {
    local float newPrimaryAmmo;

    if (KFMeleeGun(Weapon) != none && Syringe(Weapon) == none && Welder(Weapon) == none) {
        KFSXPlayerController(Controller).kfsxPRI.accum(Weapon.ItemName, 1);
    } else if (HuskGun(Weapon) != none) {
        newPrimaryAmmo= Weapon.AmmoAmount(0);
        KFSXPlayerController(Controller).kfsxPRI.accum(Weapon.itemName, oldPrimaryAmmo - newPrimaryAmmo);
        oldPrimaryAmmo= newPrimaryAmmo;
    }
}

simulated function StopFiring() {
    local float newPrimaryAmmo, newSecondaryAmmo;
    super.StopFiring();

    if (KFMeleeGun(Weapon) == none) {
        if (PipeBombExplosive(Weapon) != none) {
            KFSXPlayerController(Controller).kfsxPRI.accum(Weapon.ItemName,1);
            return;        
        }
        newPrimaryAmmo= Weapon.AmmoAmount(0);
        KFSXPlayerController(Controller).kfsxPRI.accum(Weapon.ItemName,oldPrimaryAmmo-newPrimaryAmmo);
        oldPrimaryAmmo= newPrimaryAmmo;
        if (MP7MMedicGun(Weapon) != none) {
            newSecondaryAmmo= Weapon.AmmoAmount(1);
            if (newSecondaryAmmo < oldSecondaryAmmo) {
                KFSXPlayerController(Controller).kfsxPRI.accum(Weapon.ItemName $ " Heal Dart", 1);
            }
        } else if (KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo) {
            newSecondaryAmmo= Weapon.AmmoAmount(1);
            KFSXPlayerController(Controller).kfsxPRI.accum(Weapon.ItemName$" Alt",oldSecondaryAmmo-newSecondaryAmmo);
            oldSecondaryAmmo= newSecondaryAmmo;
        }
    }
}

simulated function Fire(optional float F) {
    super.Fire(F);
    oldPrimaryAmmo= Weapon.AmmoAmount(0);
    if(KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo) {
        oldSecondaryAmmo= Weapon.AmmoAmount(1);
    }
}

simulated function AltFire(optional float F) {
    super.AltFire(F);
    oldPrimaryAmmo= Weapon.AmmoAmount(0);
    if(MP7MMedicGun(Weapon) != none || (KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo)) {
        oldSecondaryAmmo= Weapon.AmmoAmount(1);
    }
}

