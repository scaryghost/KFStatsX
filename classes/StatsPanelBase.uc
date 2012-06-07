class StatsPanelBase extends MidGamePanel
    dependson(StatList)
    abstract;

var automated GUISectionBackground i_BGStats;
var automated StatListBox lb_StatSelect;
var array<StatList.DescripInfo> descriptions;
var KFSXLinkedReplicationInfo ownerLRI;

function fillDescription() {
    local int i;

    descriptions.Length= ownerLRI.maxStatIndex;

    for(i= 0; i < ownerLRI.maxStatIndex; i++) {
        descriptions[i].description=ownerLRI.keys[i];
    }
}


function ShowPanel(bool bShow) {
    super.ShowPanel(bShow);

    if ( bShow ) {
        if (ownerLRI == none || descriptions.Length != ownerLRI.maxStatIndex) {
            fillDescription();
        }
        lb_StatSelect.statListObj.InitList(ownerLRI.stats,descriptions);
    }
}

defaultproperties {
    Begin Object Class=GUISectionBackground Name=BGStats
        bFillClient=True
        Caption="Stats"
        WinTop=0.014063
        WinLeft=0.019240
        WinWidth=0.961520
        WinHeight=0.946032
        OnPreDraw=BGPerks.InternalPreDraw
    End Object
    i_BGStats=GUISectionBackground'StatsPanelBase.BGStats'

    Begin Object Class=StatListBox Name=StatSelectList
        OnCreateComponent=StatSelectList.InternalOnCreateComponent
        WinTop=0.057760
        WinLeft=0.029240
        WinWidth=0.941520
        WinHeight=0.892836
    End Object
    lb_StatSelect=StatListBox'StatsPanelBase.StatSelectList'
}
