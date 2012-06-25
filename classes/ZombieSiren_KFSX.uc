/**
 * Custom siren that tracks decapitations, backstabs, 
 * and how many players' explosives she disintegrated
 * @author etsai (Scary Ghost)
 */
class ZombieSiren_KFSX extends KFChar.ZombieSiren;

var String explosivesDisintegrated;
var KFSXReplicationInfo instigatorRI;
var float tempHealth;
var bool decapCounted;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, 
        class<DamageType> damageType, optional int HitIndex) {
    local float prevHealth, diffHealth;

    prevHealth= Health;
    if (InstigatedBy != none) {
        instigatorRI= class'KFSXReplicationInfo'.static.findKFSXri(InstigatedBy.PlayerReplicationInfo);
    }
    if (instigatorRI != none && tempHealth == 0 && bBackstabbed) {
        instigatorRI.actions.accum(instigatorRI.backstabs, 1);
    }

    super.TakeDamage(Damage, InstigatedBy, Hitlocation, Momentum, damageType, HitIndex);

    diffHealth= prevHealth - fmax(Health, 0);
    if (decapCounted) {
        diffHealth-= tempHealth;
        tempHealth= 0;
    }
    if (instigatorRI != none) {
        if (!decapCounted && bDecapitated) {
            instigatorRI.actions.accum(instigatorRI.decapitations, 1);
            decapCounted= true;
        }
    }
    if (instigatorRI != none) {
        instigatorRI.player.accum(instigatorRI.damage, diffHealth);
    }
}

function RemoveHead() {
    tempHealth= Health;
    super.RemoveHead();
    tempHealth-= fmax(Health, 0);
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, 
        float Momentum, vector HitLocation ) {
    local KFSXReplicationInfo kfsxri;
    local actor Victims;
    local float damageScale, dist;
    local vector dir;
    local float UsedDamageAmount, usedMomentum;

    if( bHurtEntry )
        return;

    bHurtEntry = true;
    foreach VisibleCollidingActors(class 'Actor', Victims, DamageRadius, HitLocation) {
        // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
        // Or Karma actors in this case. Self inflicted Death due to flying chairs is uncool for a zombie of your stature.
        if( (Victims != self) && !Victims.IsA('FluidSurfaceInfo') && !Victims.IsA('KFMonster') 
                && !Victims.IsA('ExtendedZCollision') ) {
            dir = Victims.Location - HitLocation;
            dist = FMax(1,VSize(dir));
            dir = dir/dist;
            damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

//KFStats - 1
            /**
             * Changed if statement because momentum woulud be fixed to 0 for any 
             * actors hit after a non human pawn
             */
            if (!Victims.IsA('KFHumanPawn')) // If it aint human, don't pull the vortex crap on it.
                usedMomentum= 0;
            else {
                usedMomentum= Momentum;
            }
//KFStats - 1 End

            if (Victims.IsA('KFGlassMover')) {  // Hack for shattering in interesting ways.
                UsedDamageAmount = 100000; // Siren always shatters glass
            }
            else {
                UsedDamageAmount = DamageAmount;
            }

            Victims.TakeDamage(damageScale * UsedDamageAmount,Instigator, 
                    Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                    (damageScale * usedMomentum * dir),DamageType);

//KFStats - 2
            /**
             * Check if the projectile was disintegrated
             * FlameNade derives from Nade
             * M32 and M203 derive from M79
             * Huskgun derives from Law
             */
            if (Nade(Victims) != none && Nade(Victims).bDisintegrated || 
                LAWProj(Victims) != none && LAWProj(Victims).bDisintegrated || 
                PipeBombProjectile(Victims) != none && PipeBombProjectile(Victims).bDisintegrated ||
                M79GrenadeProjectile(Victims) != none && M79GrenadeProjectile(Victims).bDisintegrated) {
                kfsxri= class'KFSXReplicationInfo'.static.findKFSXri(Projectile(Victims).Instigator.PlayerReplicationInfo);
                kfsxri.actions.accum(explosivesDisintegrated, 1);
            }
//KFStats - 2 End
            if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
                Vehicle(Victims).DriverRadiusDamage(UsedDamageAmount, DamageRadius, Instigator.Controller, 
                    DamageType, usedMomentum, HitLocation);
        }
    }
    bHurtEntry = false;
}

defaultproperties {
    explosivesDisintegrated= "Explosives Disintegrated"
}
