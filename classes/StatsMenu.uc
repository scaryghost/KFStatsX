/**
 * Menu panel for the ingamestats command
 * @author etsai (Scary Ghost)
 */
class StatsMenu extends KFInvasionLoginMenu;

function InitComponent(GUIController MyController, GUIComponent MyComponent) {
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
    Panels(0)=(ClassName="KFStatsX.PlayerStatsPanel",Caption="Player",Hint="General player information")
    Panels(1)=(ClassName="KFStatsX.ActionPanel",Caption="Actions",Hint="Player actions")
    Panels(2)=(ClassName="KFStatsX.WeaponStatsPanel",Caption="Weapons",Hint="Weapons usage")
    Panels(3)=(ClassName="KFStatsX.KillStatsPanel",Caption="Kills",Hint="Kill counts")
    Panels(4)=(ClassName="KFStatsX.PanelSettings",Caption="Settings",Hint="Adjust settings for the stat panels")
    WindowName="KFStatsX v1.0"
}
