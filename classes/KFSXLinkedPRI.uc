class KFSXLinkedPRI extends LinkedReplicationInfo;

struct StatIndex {
    var string key;
    var int index;
};

var int maxStatIndex;
var array<float> stats[50];
var array<StatIndex> indices;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority)
        stats;
}

function int bsearch(string key, out int insert) {
    local int index, low, high, mid;

    low= 0;
    high= indices.Length - 1;
    index= -1;

    while(low <= high) {
        mid= (low+high)/2;
        if (indices[mid].key < key) {
            low= mid + 1;
        } else if (indices[mid].key > key) {
            high= mid - 1;
        } else {
            indexndex= mid;
            break;
        }
    }
    insert= mid+1;
    return index;
}

function bool contains(String key) {
    local int insert;
    return bsearch(key, insert) != -1;
}

function float get(String key) {
    local int insert, index;

    index= bsearch(key, insert);
    if (index= -1) return 0;
    return stats[indices[index].index];
}

function void put(String key, float value) {
    local int insert, index;

    index= bsearch(key, insert);
    if (index= -1) indices.insert(insert,1);
    stats[indices[index].index]= value;
}

function void accum(String key, float value) {
    local int insert, index;

    index= bsearch(key, insert);
    if (index= -1) {
        indices.insert(insert,1);
        stats[indices[index].index]= 0;
    }
    stats[indices[index].index]+= value;
}
