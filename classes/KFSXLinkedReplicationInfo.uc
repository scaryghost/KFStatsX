class KFSXLinkedReplicationInfo extends LinkedReplicationInfo;

struct StatIndex {
    var string key;
    var int index;
};

var int maxStatIndex;
var array<float> stats[50];
var array<string> keys[50];
var array<StatIndex> indices;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority)
        stats, keys, maxStatIndex;
}

function int bsearch(string key, out int insert) {
    local int index, low, high, mid;

    low= 0;
    high= indices.Length - 1;
    index= -1;
    mid= -1;

    while(low <= high) {
        mid= (low+high)/2;
        if (indices[mid].key < key) {
            low= mid + 1;
        } else if (indices[mid].key > key) {
            high= mid - 1;
        } else {
            index= mid;
            break;
        }
    }
    insert= low;
    return index;
}

function bool contains(String key) {
    local int insert;
    return bsearch(key, insert) != -1;
}

function float get(String key) {
    local int insert, index;

    index= bsearch(key, insert);
    if (index == -1) return 0;
    return stats[indices[index].index];
}

function put(String key, float value) {
    local int insert, index;

    index= bsearch(key, insert);
    if (index == -1) {
        indices.insert(insert,1);
        indices[insert].key= key;
        indices[insert].index= maxStatIndex;
        index= insert;
        keys[maxStatIndex]= key;
        maxStatIndex++;
    }
    stats[indices[index].index]= value;
}

function accum(String key, float value) {
    local int insert, index;

    index= bsearch(key, insert);
    if (index == -1) {
        indices.insert(insert,1);
        indices[insert].key= key;
        indices[insert].index= maxStatIndex;
        index= insert;
        stats[indices[insert].index]= 0;
        keys[maxStatIndex]= key;
        maxStatIndex++;
    }
    stats[indices[index].index]+= value;
}
