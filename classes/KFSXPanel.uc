class KFSXPanel extends MidGamePanel;

var automated moComboBox categories;
var automated GUISectionBackground i_BGStats;
var automated StatListBox lb_StatSelect;
var array<SortedMap> statsInfo;

function ShowPanel(bool bShow) {
    super.ShowPanel(bShow);

    EnableComponent(categories);

    if (bShow) {
        lb_StatSelect.statListObj.InitList(statsInfo[categories.GetIndex()]);
    }
}

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
    local KFSXReplicationInfo kfsxRI;
    super.InitComponent(MyController, MyOwner);

    categories.AddItem("Player");
    categories.AddItem("Actions");
    categories.AddItem("Weapons");
    categories.AddItem("Kills");
    i_BGStats.ManageComponent(lb_StatSelect.statListObj);

    kfsxRI= class'KFSXReplicationInfo'.static.findKFSXri(PlayerOwner().PlayerReplicationInfo);
    statsInfo[0]= kfsxRi.player;
    statsInfo[1]= kfsxRi.actions;
    statsInfo[2]= kfsxRi.weapons;
    statsInfo[3]= kfsxRi.kills;
}

function InternalOnChange(GUIComponent sender) {
    if (sender == categories) {
        ShowPanel(true);
    }
}

defaultproperties {
    Begin Object Class=moComboBox Name=CategoryComboBox
        bReadOnly=True
        ComponentJustification=TXTA_Left
        Caption="Category"
        OnCreateComponent=OnlineNetSpeed.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="Player"
        Hint="KFStatsX stat categories"
        WinTop=0.0222944
        WinLeft=0.528997
        WinWidth=0.419297
        TabOrder=3
        OnChange=KFSXPanel.InternalOnChange
    End Object
    categories=moComboBox'KFSXPanel.CategoryComboBox'

    Begin Object Class=GUISectionBackground Name=BGStats
        bFillClient=True
        Caption="Stats"
        WinTop=0.014063
        WinLeft=0.019240
        WinWidth=0.961520
        WinHeight=0.946032
        OnPreDraw=BGStats.InternalPreDraw
    End Object
    i_BGStats=GUISectionBackground'KFSXPanel.BGStats'

    Begin Object Class=StatListBox Name=StatSelectList
        OnCreateComponent=StatSelectList.InternalOnCreateComponent
        WinTop=0.157760
        WinLeft=0.029240
        WinWidth=0.941520
        WinHeight=0.792836
    End Object
    lb_StatSelect=StatListBox'KFSXPanel.StatSelectList'
}
