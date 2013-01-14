/**
 * Menu panel for the ingamestats command
 * @author etsai (Scary Ghost)
 */
class StatsMenu extends KFInvasionLoginMenu;

var automated moComboBox players;
var PlayerReplicationInfo lastSelected;

function InitComponent(GUIController MyController, GUIComponent MyComponent) {
    super(UT2K4PlayerLoginMenu).InitComponent(MyController, MyComponent);
}

function SetTitle() {
    WindowName= default.WindowName;
}

function updateStats(PlayerReplicationInfo playerRI) {
    local int i;
    local KFSXReplicationInfo kfsxRI;

    kfsxRI= class'KFSXReplicationInfo'.static.findKFSXri(playerRI);
    if (kfsxRI != None) {
        for(i= 0; i < c_Main.TabStack.Length; i++) {
            if (StatsPanelBase(c_Main.TabStack[i].MyPanel) != None) {
                StatsPanelBase(c_Main.TabStack[i].MyPanel).updateStatsInfo(kfsxRI);
            }
        }
    }
}

function InternalOnChange(GUIComponent sender) {
    if (sender == players) {
        lastSelected= PlayerOwner().GameReplicationInfo.PRIArray[players.GetIndex()];
        updateStats(lastSelected);
    }
}

function InternalOnLoadINI(GUIComponent sender, string s) {
    local int i;

    if (sender == players) {
        if (lastSelected == None) {
            lastSelected= PlayerOwner().PlayerReplicationInfo;
        }
        players.ResetComponent();
        for(i= 0; i < PlayerOwner().GameReplicationInfo.PRIArray.Length; i++) {
            players.AddItem(PlayerOwner().GameReplicationInfo.PRIArray[i].PlayerName);
            if (PlayerOwner().GameReplicationInfo.PRIArray[i] == lastSelected) {
                players.SilentSetIndex(i);
            }
        }
        updateStats(lastSelected);
    }
}

defaultproperties {
    Begin Object Class=moComboBox Name=PlayerComboBox
        bReadOnly=True
        bAlwaysNotify=True
        ComponentJustification=TXTA_Left
        Caption="Player"
        IniOption="@Internal"
        Hint="View stats for all players"
        TabOrder=3
        WinTop= 0.085
        WinLeft=0.25
        OnChange=StatsMenu.InternalOnChange
        OnLoadINI=StatsMenu.InternalOnLoadINI
    End Object
    players=moComboBox'StatsMenu.PlayerComboBox'

    WinHeight=0.9
    Panels(0)=(ClassName="KFStatsX.PlayerStatsPanel",Caption="Player",Hint="General player information")
    Panels(1)=(ClassName="KFStatsX.ActionPanel",Caption="Actions",Hint="Player actions")
    Panels(2)=(ClassName="KFStatsX.WeaponStatsPanel",Caption="Weapons",Hint="Weapons usage")
    Panels(3)=(ClassName="KFStatsX.KillStatsPanel",Caption="Kills",Hint="Kill counts")
    Panels(4)=(ClassName="KFStatsX.PanelSettings",Caption="Settings",Hint="Adjust settings for the stat panels")
    WindowName="KFStatsX"
}
