/**
 * Dummy LRI class for player related information
 * @author etsai (Scary Ghost)
 */
class PlayerLRI extends KFSXLinkedReplicationInfo;

enum StatKeys {
    Time_Alive, Cash_Spent, Welding, Damage_Dealt,
    Received_Heal, Healed_Self, Healed_Teammates,
    Damage_Taken, Armor_Lost, Backstabs, 
    Decapitations, Shot_By_Husk, Husks_Stunned, 
    Scrakes_Raged, Scrakes_Stunned, Fleshpounds_Raged
};

event PostBeginPlay() {
    local int i;

    super.PostBeginPlay();

    for(i= 0; i < StatKeys.EnumCount; i++)
        stats.put(getKey(i), 0);

}

function string getKey(int index) {
    return Repl(string(GetEnum(enum'StatKeys', index)), "_", " ");
}
