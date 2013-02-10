class KFSXInteraction extends Interaction;

var GUI.GUITabItem newTab;

event NotifyLevelChange() {
    Master.RemoveInteraction(self);
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta ) {
    local string alias;
    local MidGamePanel panel;

    alias= ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key));
    if (Action == IST_Press && alias ~= "showmenu") {
        if (KFGUIController(ViewportOwner.GUIController).ActivePage == None) {
            ViewportOwner.Actor.ShowMenu();
        }
        if (KFInvasionLoginMenu(KFGUIController(ViewportOwner.GUIController).ActivePage) != none && 
                KFInvasionLoginMenu(KFGUIController(ViewportOwner.GUIController).ActivePage).c_Main.TabIndex(newTab.caption) == -1) {
            panel= MidGamePanel(KFInvasionLoginMenu(KFGUIController(ViewportOwner.GUIController).ActivePage).c_Main.AddTabItem(newTab));
            if (panel != none) {
                panel.ModifiedChatRestriction= KFInvasionLoginMenu(KFGUIController(ViewportOwner.GUIController).ActivePage).UpdateChatRestriction;
            }
        }
    }
    return false;
}

defaultproperties {
    bActive= true
    newTab=(ClassName="KFStatsX.KFSXPanel",Caption="KFStatsX",Hint="View stats about your current game")
}
