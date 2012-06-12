/**
 * GUI box containing the stat list
 * @author etsai (Scary Ghost)
 */
class StatListBox extends GUIListBoxBase;

var StatList statListObj;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
    Super.InitComponent(MyController,MyOwner);
    statListObj = StatList(AddComponent(DefaultListClass));
    if (statListObj == None) {
        Warn(Class$".InitComponent - Could not create default list ["$DefaultListClass$"]");
        return;
    }
    InitBaseList(statListObj);
}

function int GetIndex() {
    return statListObj.Index;
}

defaultproperties {
    DefaultListClass="KFStatsX.StatList"
}
