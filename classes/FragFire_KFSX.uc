/**
 * Special fire mode for tossing frags.  Logs which type of 
 * nade was tossed
 * @author etsai (Scary Ghost)
 */
class FragFire_KFSX extends FragFire;

function projectile SpawnProjectile(Vector Start, Rotator Dir) {
    local class<Projectile> g;
    local KFSXReplicationInfo lri;

    /** Copied from FragFire.SpawnProjectile */
    if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && 
        KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none ) {
        g= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo)
            .ClientVeteranSkill.Static.GetNadeType(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo));
    }
    else {
        g= class'Nade';
    }
    lri= class'KFSXReplicationInfo'.static.findKFSXlri(Instigator.PlayerReplicationInfo);
    lri.weapons.accum(GetItemName(string(g)), 1);

    return super.SpawnProjectile(Start,Dir);
}
