/**
 * Custom crossbow arrow that tracks how many times a player picked it up
 * @author etsai (Scary Ghost)
 */
class CrossbowArrow_KFSX extends KFMod.CrossbowArrow;

var string statKey;

simulated state OnWall {
    /**  Copied from KFMod.CrossbowArrow, added bolts retrieved stat */
    function ProcessTouch (Actor Other, vector HitLocation) {
        local Inventory inv;
        local KFSXReplicationInfo kfsxri;

        if( Pawn(Other)!=None && Pawn(Other).Inventory!=None ) {
            for( inv=Pawn(Other).Inventory; inv!=None; inv=inv.Inventory ) {
                if( Crossbow(Inv)!=None && Weapon(inv).AmmoAmount(0)<Weapon(inv).MaxAmmo(0) ) {
                    KFweapon(Inv).AddAmmo(1,0) ;
                    PlaySound(Sound'KF_InventorySnd.Ammo_GenericPickup', SLOT_Pain,2*TransientSoundVolume,,400);
                    if(PlayerController(Pawn(Other).Controller) !=none) {
                        PlayerController(Pawn(Other).Controller).ReceiveLocalizedMessage(class'KFmod.ProjectilePickupMessage',0);
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
    statKey= "Bolts Retrieved"
}
