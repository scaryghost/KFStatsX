class KFSXLinkedReplicationInfo extends LinkedReplicationInfo
    dependson(SortedMap);

var SortedMap stats;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority)
        stats;
}

event PostBeginPlay() {
    super.PostBeginPlay();
    stats= Spawn(class'SortedMap');
}
