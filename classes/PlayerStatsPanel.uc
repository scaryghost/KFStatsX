class PlayerStatsPanel extends StatsPanelBase;

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
        lb_StatSelect.statListObj.InitList(ownerLRI.stats,descriptions);
    }
}
