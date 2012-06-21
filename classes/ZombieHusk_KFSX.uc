/**
 * Custom husk that tracks decapitations, backstabs, 
 * and how many times you stunned it
 * @author etsai (Scary Ghost)
 */
class ZombieHusk_KFSX extends KFChar.ZombieHusk;

var class<Projectile> huskProjectile;
var String husksStunned;
var KFSXLinkedReplicationInfo instigatorLRI;
var float tempHealth;
var bool decapCounted;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, 
        class<DamageType> damageType, optional int HitIndex) {
    local float prevHealth, diffHealth;

    prevHealth= Health;
    if (InstigatedBy != none) {
        instigatorLRI= class'KFSXLinkedReplicationInfo'.static.findKFSXlri(InstigatedBy.PlayerReplicationInfo);
    }
    if (instigatorLRI != none && tempHealth == 0 && bBackstabbed) {
        instigatorLRI.actions.accum(instigatorLRI.backstabs, 1);
    }

    super.TakeDamage(Damage, InstigatedBy, Hitlocation, Momentum, damageType, HitIndex);

    diffHealth= prevHealth - fmax(Health, 0);
    if (decapCounted) {
        diffHealth-= tempHealth;
        tempHealth= 0;
    }
    if (instigatorLRI != none) {
        if (!decapCounted && bDecapitated) {
            instigatorLRI.actions.accum(instigatorLRI.decapitations, 1);
            decapCounted= true;
        }
    }
    if (instigatorLRI != none) {
        instigatorLRI.player.accum(instigatorLRI.damage, diffHealth);
    }
}

function RemoveHead() {
    tempHealth= Health;
    super.RemoveHead();
    tempHealth-= fmax(Health, 0);
}

function bool FlipOver() {
    if (super.FlipOver()) {
        if (Health > 0 && instigatorLRI != none) {
            instigatorLRI.actions.accum(husksStunned, 1);
        }
        return true;
    }

    return false;
}

/**
 * Copied from ZombieHusk.SpawnTwoShots()
 * Changed projectile to use KFStatsX Version
 */
function SpawnTwoShots() {
	local vector X,Y,Z, FireStart;
	local rotator FireRotation;
	local KFMonsterController KFMonstControl;

	if( Controller!=None && KFDoorMover(Controller.Target)!=None ) {
		Controller.Target.TakeDamage(22,Self,Location,vect(0,0,0),Class'DamTypeVomit');
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	FireStart = GetBoneCoords('Barrel').Origin;
	if ( !SavedFireProperties.bInitialized ) {
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
//KFStatsX - 1
		SavedFireProperties.ProjectileClass = huskProjectile;
//KFSTatsX - 1 End
		SavedFireProperties.WarnTargetPct = 1;
		SavedFireProperties.MaxRange = 65535;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = true;
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = False;
		SavedFireProperties.bInitialized = True;
	}

    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);

	FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);

	foreach DynamicActors(class'KFMonsterController', KFMonstControl) {
        if( KFMonstControl != Controller ) {
            if( PointDistToLine(KFMonstControl.Pawn.Location, vector(FireRotation), FireStart) < 75 ) {
                KFMonstControl.GetOutOfTheWayOfShot(vector(FireRotation),FireStart);
            }
        }
	}
//KFStatsX - 2
    Spawn(huskProjectile,,,FireStart,FireRotation);
//KFSTatsX - 2 End

	// Turn extra collision back on
	ToggleAuxCollision(true);
}

defaultproperties {
    huskProjectile= class'HuskFireProjectile_KFSX'
    husksStunned= "Husks Stunned"
}
