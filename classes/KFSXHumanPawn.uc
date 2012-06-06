class KFSXHumanPawn extends KFHumanPawn;

var float currHuskGunAmmo;

function DeactivateSpawnProtection() {
    local int mode;
    local string itemName;
    local float load;
    super.DeactivateSpawnProtection();

    if (Weapon.isFiring() && Syringe(Weapon) == none && Welder(Weapon) == none) {
        itemName= Weapon.ItemName;
        if (Weapon.GetFireMode(1).bIsFiring)
            mode= 1;

        if (KFMeleeGun(Weapon) != none || (mode == 1 && MP7MMedicGun(Weapon) != none)) {
            load= 1;
        } else if (Huskgun(Weapon) != none) {
            load= currHuskGunAmmo - Weapon.AmmoAmount(0);
        } else {
            load= Weapon.GetFireMode(mode).Load;
        }

        if (mode == 1 && (MP7MMedicGun(Weapon) != none || 
                (KFWeapon(Weapon) != none && KFWeapon(Weapon).bHasSecondaryAmmo))) {
            itemName$= " Alt";
        }

        KFSXPlayerController(Controller).kfsxPRI.accum(itemName, load);
    }
}

simulated function Fire(optional float F) {
    if (Role == ROLE_Authority && Huskgun(Weapon) != none) {
        currHuskGunAmmo= Weapon.AmmoAmount(0);
    }
    super.Fire(F);
}
