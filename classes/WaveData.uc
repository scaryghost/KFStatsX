class WaveData extends Info;

struct Data {
    var class<KFVeterancyTypes> perk;
    var SortedMap stats;
};

var int wave;
var string category;
var array<Data> dataCollection;

function SortedMap getStatsMap(class<KFVeterancyTypes> perk) {
    local int i;

    for(i= 0; i < dataCollection.Length; i++) {
        if (dataCollection[i].perk == perk) {
            return dataCollection[i].stats;
        }
    }
    dataCollection.Length= dataCollection.Length + 1;
    dataCollection[i].stats= Spawn(class'SortedMap');
    dataCollection[i].perk= perk;
    return dataCollection[i].stats;
}

function reset() {
    local int i;

    for(i= 0; i < dataCollection.Length; i++) {
        dataCollection[i].stats.clear();
    }
}

defaultproperties {
    wave= 1
}
