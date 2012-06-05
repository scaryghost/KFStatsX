class KFSXPlayerController extends KFPlayerController;

var KFSXLinkedPRI kfsxPRI;

event PostBeginPlay() {
    local LinkedReplicationInfo lri;

    super.PostBeginPlay();
    for(lri= PlayerReplicationInfo.CustomReplicationInfo; lri != none; lri= lri.NextReplicationInfo) {
        if (KFSXLinkedPRI(lri) != none) {
            kfsxPRI= KFSXLinkedPRI(lri);
            break;
        }
    }
}

function SetPawnClass(string inClass, string inCharacter) {
    super.SetPawnClass(inClass, inCharacter);
    PawnClass = Class'KFSXHumanPawn';
}

exec function Fire(optional float F) {
    local float primaryMax;

    super.Fire(F);
    Pawn.Weapon.GetAmmoCount(primaryMax, KFSXHumanPawn(Pawn).oldPrimaryAmmo);
}

exec function AltFire(optional float F) {
    local float secondaryMax;

    super.AltFire(F);

    if(KFWeapon(Pawn.Weapon) != none && KFWeapon(Pawn.Weapon).bHasSecondaryAmmo) {
        KFWeapon(Pawn.Weapon).GetSecondaryAmmoCount(secondaryMax, KFSXHumanPawn(Pawn).oldSecondaryAmmo);
    }
}
