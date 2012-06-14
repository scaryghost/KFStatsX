/**
 * Auxiliary functions used by the various classes
 * @author etsai (Scary Ghost)
 */
class Auxiliary extends Object;

/**
 * Pair that ties which class should be replaced
 */
struct ReplacementPair {
    var string oldClass;
    var string newClass;
};

/**
 * Replaces the zombies in the given squad array
 * @param   squadArray          Squad array to replace.  This parameter will 
 *                              be overwritten with the new monsters
 * @param   replacementArray    List of replacement monsters
 */
static function replaceSpecialSquad(out array<KFGameType.SpecialSquad> squadArray, 
        array<ReplacementPair> replacementArray) {
    local int i,j,k;
    local ReplacementPair pair;
    for(j=0; j<squadArray.Length; j++) {
        for(i=0;i<squadArray[j].ZedClass.Length; i++) {
            for(k=0; k<replacementArray.Length; k++) {
                pair= replacementArray[k];
                if(squadArray[j].ZedClass[i] ~= pair.oldClass) {
                    squadArray[j].ZedClass[i]=  pair.newClass;
                }
            }
        }
    }
}

/**
 * Replace the stanard monster classes
 * @param   monsterClasses      List of monster class types.  This parameter will 
 *                              be overwritten with the new monsters
 * @param   replacementArray    List of replacement specimens
 */
static function replaceStandardMonsterClasses(out array<KFGameType.MClassTypes> monsterClasses, 
        array<ReplacementPair> replacementArray) {
    local int i, k;
    local ReplacementPair pair;

    for( i=0; i<monsterClasses.Length; i++) {
        for(k=0; k<replacementArray.Length; k++) {
            pair= replacementArray[k];
            //Use ~= for case insensitive compare
            if (monsterClasses[i].MClassName ~= pair.oldClass) {
                monsterClasses[i].MClassName= pair.newClass;
            }
        }
    }

}

/**
 * Converts seconds into HH:MM:SS format
 * @param   seconds     Number of seconds
 */
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
