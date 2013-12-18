class WaveData extends Info;

struct Data {
    var class<KFVeterancyTypes> perk;
    var SortedMap stats;
};

var int wave;
var string category;
var array<Data> perkData;

function SortedMap getStatsMap(class<KFVeterancyTypes> perk) {
    local int i;

    for(i= 0; i < perkData.Length; i++) {
        if (perkData[i].perk == perk) {
            return perkData[i].stats;
        }
    }
    perkData.Length= perkData.Length + 1;
    perkData[i].stats= Spawn(class'SortedMap');
    perkData[i].perk= perk;
    return perkData[i].stats;
}

function reset() {
    local int i;

    for(i= 0; i < perkData.Length; i++) {
        perkData[i].stats.clear();
    }
}

defaultproperties {
    wave= 1
}
