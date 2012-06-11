class StatsMenu extends KFInvasionLoginMenu;

function InitComponent(GUIController MyController, GUIComponent MyComponent) {
    Panels.remove(4,Panels.Length-4);
    super(UT2K4PlayerLoginMenu).InitComponent(MyController, MyComponent);
}

function SetTitle() {
    WindowName= default.WindowName;
}

defaultproperties {
    Begin Object Class=GUITabControl Name=StatsMenuTC
        bDockPanels=True
        BackgroundStyleName="TabBackground"
        WinTop=0.026336
        WinLeft=0.012500
        WinWidth=0.974999
        WinHeight=0.055000
        bScaleToParent=True
        bAcceptsInput=True
        OnActivate=LoginMenuTC.InternalOnActivate
    End Object
    c_Main=GUITabControl'StatsMenu.StatsMenuTC'

    WinHeight=0.8125
    Panels(0)=(ClassName="KFStatsX.PlayerStatsPanel",Caption="Player",Hint="Player related stats")
    Panels(1)=(ClassName="KFStatsX.WeaponStatsPanel",Caption="Weapon",Hint="Stats about weapon usage")
    Panels(2)=(ClassName="KFStatsX.KillStatsPanel",Caption="Kills",Hint="Breakdown of the kill count")
    Panels(3)=(ClassName="KFStatsX.PanelSettings",Caption="Settings",Hint="Adjust settings for the stat panels")
    WindowName="KFStatsX v1.0"
}
