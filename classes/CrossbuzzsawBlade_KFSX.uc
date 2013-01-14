class CrossbuzzsawBlade_KFSX extends KFMod.CrossbuzzsawBlade;

var string statKey;

simulated state OnWall {
    Ignores HitWall;

    function ProcessTouch (Actor Other, vector HitLocation) {
        local Inventory inv;
        local KFSXReplicationInfo kfsxri;

        if( Pawn(Other)!=None && Pawn(Other).Inventory!=None ) {
            for( inv=Pawn(Other).Inventory; inv!=None; inv=inv.Inventory ) {
                if( Crossbuzzsaw(Inv)!=None && Weapon(inv).AmmoAmount(0)<Weapon(inv).MaxAmmo(0) ) {
                    KFweapon(Inv).AddAmmo(1,0) ;
                    PlaySound(Sound'KF_InventorySnd.Ammo_GenericPickup', SLOT_Pain,2*TransientSoundVolume,,400);
                    if( PlayerController(Pawn(Other).Controller)!=none ) {
                        PlayerController(Pawn(Other).Controller).ReceiveLocalizedMessage(class'KFmod.ProjectilePickupMessage',1);
                        kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Pawn(Other).PlayerReplicationInfo);
                        kfsxri.actions.accum(statKey, 1.0);
                    }
                    Destroy();
                }
            }
        }
    }
}

defaultproperties {
    statKey= "Blades Retrieved"
}
