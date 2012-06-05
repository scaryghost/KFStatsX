class Auxiliary extends Object;

struct ReplacementPair {
    var class<Object> oldClass;
    var class<Object> newClass;
};

static function int binarySearch(String key, array<string> values) {
    local int replaceIndex;
    local int low, high, mid;

    low= 0;
    high= values.Length - 1;
    replaceIndex= -1;
    while(low <= high) {
        mid= (low+high)/2;
        if (values[mid] < key) {
            low= mid + 1;
        } else if (values[mid] > key) {
            high= mid - 1;
        } else {
            replaceIndex= mid;
            break;
        }
    }
    return replaceIndex;
}

static function int replaceClass(string className, array<ReplacementPair> replacementArray) {
    local int replaceIndex;
    local int low, high, mid;

    low= 0;
    high= replacementArray.Length - 1;
    replaceIndex= -1;
    while(low <= high) {
        mid= (low+high)/2;
        if (Caps(string(replacementArray[mid].oldClass)) < Caps(className)) {
            low= mid + 1;
        } else if (Caps(string(replacementArray[mid].oldClass)) > Caps(className)) {
            high= mid - 1;
        } else {
            replaceIndex= mid;
            break;
        }
    }
    return replaceIndex;
}

/**
 *  Replaces the zombies in the given squadArray
 */
static function replaceSpecialSquad(out array<KFGameType.SpecialSquad> squadArray, 
        array<ReplacementPair> replacementArray) {
    local int i,j,k;
    local ReplacementPair pair;
    for(j=0; j<squadArray.Length; j++) {
        for(i=0;i<squadArray[j].ZedClass.Length; i++) {
            for(k=0; k<replacementArray.Length; k++) {
                pair= replacementArray[k];
                if(squadArray[j].ZedClass[i] ~= string(pair.oldClass)) {
                    squadArray[j].ZedClass[i]=  string(pair.newClass);
                }
            }
        }
    }
}

static function replaceStandardMonsterClasses(out array<KFGameType.MClassTypes> monsterClasses, 
        array<ReplacementPair> replacementArray) {
    local int i, k;
    local ReplacementPair pair;

    for( i=0; i<monsterClasses.Length; i++) {
        for(k=0; k<replacementArray.Length; k++) {
            pair= replacementArray[k];
            //Use ~= for case insensitive compare
            if (monsterClasses[i].MClassName ~= string(pair.oldClass)) {
                monsterClasses[i].MClassName= string(pair.newClass);
            }
        }
    }

}

static function string formatTime(int seconds) {
    local string timeStr;
    local int i;
    local array<int> timeValues;
    
    timeValues.Length= 3;
    timeValues[0]= seconds / 3600;
    timeValues[1]= seconds / 60;
    timeValues[2]= seconds % 60;
    for(i= 0; i < timeValues.Length; i++) {
        if (timeValues[i] < 10) {
            timeStr= timeStr$"0"$timeValues[i];
        } else {
            timeStr= timeStr$timeValues[i];
        }
        if (i < timeValues.Length-1) {
            timeStr= timeStr$":";
        }
    }

    return timeStr;
}
