class KFSXInvasionLoginMenu extends KFGui.KFInvasionLoginMenu;

// We want to get ride of this menu!
function bool NotifyLevelChange() {
    bPersistent = false;
    return true;
}

function InitComponent(GUIController MyController, GUIComponent MyComponent) {
    Super(UT2K4PlayerLoginMenu).InitComponent(MyController, MyComponent);
    c_Main.RemoveTab(Panels[0].Caption);
    c_Main.ActivateTabByName(Panels[1].Caption, true);
}

defaultproperties {
    Panels(4)=(ClassName="KFStatsX.KFSXPanel",Caption="KFStatsX",Hint="View stats about your current game")
}

