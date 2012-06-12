/**
 * Based class for the custom linked replication information 
 * used by each stat group
 * @author etsai (Scary Ghost)
 */
class KFSXLinkedReplicationInfo extends LinkedReplicationInfo
    dependson(SortedMap);

/** Map of values stored by this LRI */
var SortedMap stats;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority)
        stats;
}

event PostBeginPlay() {
    super.PostBeginPlay();
    stats= Spawn(class'SortedMap');
}
