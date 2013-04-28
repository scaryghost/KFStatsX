/**
 * Map that stores its keys in ascending order.  
 * This class is not templated and only supports 
 * string keys and float values
 * @author etsai (Scary Ghost)
 */
class SortedMap extends ReplicationInfo;

/**
 * Pairs the key with what array index its value is located at
 */
struct StatIndex {
    var string key;
    var int index;
};

/** Number of entries in the map */
var int maxStatIndex;
/** Values for each key */
var array<float> values[63];
/** Set of keys used by the map */
var array<string> keys[63];
/** List of key index pairs */
var array<StatIndex> indices;

replication {
    reliable if (bNetDirty && Role == ROLE_Authority)
        values, keys, maxStatIndex;
}

/**
 * Search the indices array for the given key using a binary search.
 * @param   key     The key to search for
 * @param   insert  The index the key should be inserted to is 
                    written to this parameter.  It is only used 
                    if the key was not found in indices
 * @return  Index of the key, or -1 if the key is not present
 */
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

/**
 * Returns true if the key is contained in the map
 * @param   key     Key to search for
 */
function bool contains(String key) {
    local int insert;
    return bsearch(key, insert) != -1;
}

/**
 * Retrieve the value of the key
 * @param   key     Key to search for
 * @return  Value for the given key, 0 if not key not present
 */
function float get(String key) {
    local int insert, index;

    index= bsearch(key, insert);
    if (index == -1) return 0;
    return values[indices[index].index];
}

/**
 * Assign the specified key the given value.  
 * This will overwrite the current value of 
 * the key is present.
 * @param   key     Key to write to
 * @param   value   Value to write
 */
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
    values[indices[index].index]= value;
}

/**
 * Accumulate the value stored for the given key.  
 * Will create a new entry if key is not present
 * @param   key     Key to accumulate
 * @param   value   Value to accumulate
 */
function accum(String key, float value) {
    local int insert, index;

    index= bsearch(key, insert);
    if (index == -1) {
        indices.insert(insert,1);
        indices[insert].key= key;
        indices[insert].index= maxStatIndex;
        index= insert;
        values[indices[insert].index]= 0;
        keys[maxStatIndex]= key;
        maxStatIndex++;
    }
    values[indices[index].index]+= value;
}

function clear() {
    maxStatIndex= 0;
    indices.Length= 0;
}
