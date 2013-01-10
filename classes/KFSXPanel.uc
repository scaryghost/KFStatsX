class KFSXPanel extends MidGamePanel;

var automated moComboBox categories;
var automated GUISectionBackground i_BGStats, i_bgFilters, i_bgSettings;
var automated StatListBox lb_StatSelect;
var array<SortedMap> statsInfo;
var automated moSlider sl_bgR, sl_bgG, sl_bgB,
        sl_txtR, sl_txtG, sl_txtB, sl_alpha, sl_txtScale;
var() noexport transient int bgR, bgG, bgB, txtR, txtG, txtB, alpha;
var() noexport float txtScale;

var string setProp, getProp;

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

    i_bgStats.ManageComponent(lb_StatSelect);
    i_bgFilters.ManageComponent(categories);
    i_bgSettings.ManageComponent(sl_bgR);
    i_bgSettings.ManageComponent(sl_bgG);
    i_bgSettings.ManageComponent(sl_bgB);
    i_bgSettings.ManageComponent(sl_txtR);
    i_bgSettings.ManageComponent(sl_txtG);
    i_bgSettings.ManageComponent(sl_txtB);
    i_bgSettings.ManageComponent(sl_alpha);
    i_bgSettings.ManageComponent(sl_txtScale);

    categories.AddItem("Player");
    categories.AddItem("Actions");
    categories.AddItem("Weapons");
    categories.AddItem("Kills");

    kfsxRI= class'KFSXReplicationInfo'.static.findKFSXri(PlayerOwner().PlayerReplicationInfo);
    statsInfo[0]= kfsxRi.player;
    statsInfo[1]= kfsxRi.actions;
    statsInfo[2]= kfsxRi.weapons;
    statsInfo[3]= kfsxRi.kills;
}

function InternalOnLoadINI(GUIComponent Sender, string s) {
    local PlayerController PC;

    PC= PlayerOwner();
    switch (Sender) {
        case sl_bgR:
            bgR= int(PC.ConsoleCommand(getProp$" bgR "));
            sl_bgR.SetComponentValue(bgR, true);
            break;
        case sl_bgG:
            bgG= int(PC.ConsoleCommand(getProp$" bgG "));
            sl_bgG.SetComponentValue(bgG, true);
            break;
        case sl_bgB:
            bgB= int(PC.ConsoleCommand(getProp$" bgB "));
            sl_bgB.SetComponentValue(bgB, true);
            break;
        case sl_txtR:
            txtR= int(PC.ConsoleCommand(getProp$" txtR "));
            sl_txtR.SetComponentValue(txtR, true);
            break;
        case sl_txtG:
            txtG= int(PC.ConsoleCommand(getProp$" txtG "));
            sl_txtG.SetComponentValue(txtG, true);
            break;
        case sl_txtB:
            txtB= int(PC.ConsoleCommand(getProp$" txtB "));
            sl_txtB.SetComponentValue(txtB, true);
            break;
        case sl_alpha:
            alpha= int(PC.ConsoleCommand(getProp$" alpha "));
            sl_alpha.SetComponentValue(alpha, true);
            break;
        case sl_txtScale:
            txtScale= float(PC.ConsoleCommand(getProp$" txtScale "));
            sl_txtScale.SetComponentValue(txtScale, true);
            break;
    }
}

function InternalOnChange(GUIComponent sender) {
        local PlayerController PC;
    if (sender == categories) {
        ShowPanel(true);
    }

    PC= PlayerOwner();
    switch (Sender) {
        case sl_bgR:
            bgR= sl_bgR.GetValue();
            PC.ConsoleCommand(setProp$" bgR "$bgR);
            break;
        case sl_bgG:
            bgG= sl_bgG.GetValue();
            PC.ConsoleCommand(setProp$" bgG "$bgG);
            break;
        case sl_bgB:
            bgB= sl_bgB.GetValue();
            PC.ConsoleCommand(setProp$" bgB "$bgB);
            break;
        case sl_txtR:
            txtR= sl_txtR.GetValue();
            PC.ConsoleCommand(setProp$" txtR "$txtR);
            break;
        case sl_txtG:
            txtG= sl_txtG.GetValue();
            PC.ConsoleCommand(setProp$" txtG "$txtG);
            break;
        case sl_txtB:
            txtB= sl_txtB.GetValue();
            PC.ConsoleCommand(setProp$" txtB "$txtB);
            break;
        case sl_alpha:
            alpha= sl_alpha.GetValue();
            PC.ConsoleCommand(setProp$" alpha "$alpha);
            break;
        case sl_txtScale:
            txtScale= sl_txtScale.GetValue();
            PC.ConsoleCommand(setProp$" txtScale "$txtScale);
            break;
    }

}

defaultproperties {
    setProp= "set KFStatsX.StatList"
    getProp= "get KFStatsX.StatList"

    Begin Object Class=moComboBox Name=CategoryComboBox
        bReadOnly=True
        ComponentJustification=TXTA_Left
        Caption="Category"
        OnCreateComponent=OnlineNetSpeed.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="Player"
        Hint="KFStatsX stat categories"
        WinTop=0.0222944
        WinLeft=0.25
        WinWidth=0.419297
        TabOrder=3
        OnChange=KFSXPanel.InternalOnChange
    End Object
    categories=moComboBox'KFSXPanel.CategoryComboBox'

    Begin Object Class=StatListBox Name=StatSelectList
        OnCreateComponent=StatSelectList.InternalOnCreateComponent
        WinTop=0.070063
        WinLeft=0.029240
        WinWidth=0.941520
        WinHeight=0.792836
    End Object
    lb_StatSelect=StatListBox'KFSXPanel.StatSelectList'

    Begin Object Class=AltSectionBackground Name=PlayersBackground
        Caption="Stats"
        LeftPadding=0.000000
        RightPadding=0.000000
        TopPadding=0.000000
        BottomPadding=0.000000
        WinTop=0.029674
        WinLeft=0.019240
        WinWidth=0.457166
        WinHeight=0.798982
        bBoundToParent=True
        bScaleToParent=True
        OnPreDraw=PlayersBackground.InternalPreDraw
    End Object
    i_bgStats=PlayersBackground

    Begin Object Class=AltSectionBackground Name=SpecBackground
        Caption="Filters"
        LeftPadding=0.000000
        RightPadding=0.000000
        TopPadding=0.000000
        BottomPadding=0.000000
        WinTop=0.029674
        WinLeft=0.486700
        WinWidth=0.491566
        WinHeight=0.369766
        bBoundToParent=True
        bScaleToParent=True
        OnPreDraw=SpecBackground.InternalPreDraw
    End Object
    i_bgFilters=SpecBackground

    Begin Object Class=AltSectionBackground Name=OptionBackground
        Caption="Settings"
        TopPadding=0.040000
        BottomPadding=0.000000
        WinTop=0.413209
        WinLeft=0.486700
        WinWidth=0.490282
        WinHeight=0.415466
        bBoundToParent=True
        bScaleToParent=True
        OnPreDraw=OptionBackground.InternalPreDraw
    End Object
    i_bgSettings=OptionBackground

    Begin Object Class=moSlider Name=BackgroundRedSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="BG Red"
        OnCreateComponent=BackgroundRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="0"
        Hint="Adjust the red value of the stat background color"
        WinTop=0.15
        WinLeft=0.712188
        WinWidth=0.291445
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_bgR=moSlider'KFSXPanel.BackgroundRedSlider'

    Begin Object Class=moSlider Name=BackgroundGreenSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="BG Green"
        OnCreateComponent=BackgroundRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="0"
        Hint="Adjust the green value of the stat background color"
        WinTop=0.175
        WinLeft=0.712188
        WinWidth=0.291445
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_bgG=moSlider'KFSXPanel.BackgroundGreenSlider'

    Begin Object Class=moSlider Name=BackgroundBlueSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="BG Blue"
        OnCreateComponent=BackgroundRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="0"
        Hint="Adjust the blue value of the stat background color"
        WinTop=0.20
        WinLeft=0.712188
        WinWidth=0.291445
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_bgB=moSlider'KFSXPanel.BackgroundBlueSlider'

    Begin Object Class=moSlider Name=TextRedSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Text Red"
        OnCreateComponent=TextRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust the red value of the stat text color"
        WinTop=0.225
        WinLeft=0.712188
        WinWidth=0.291445
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_txtR=moSlider'KFSXPanel.TextRedSlider'

    Begin Object Class=moSlider Name=TextGreenSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Text Green"
        OnCreateComponent=TextRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust the green value of the stat text color"
        WinTop=0.25
        WinLeft=0.712188
        WinWidth=0.291445
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_txtG=moSlider'KFSXPanel.TextGreenSlider'

    Begin Object Class=moSlider Name=TextBlueSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Text Blue"
        OnCreateComponent=TextRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust the blue value of the stat text color"
        WinTop=0.275
        WinLeft=0.712188
        WinWidth=0.291445
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_txtB=moSlider'KFSXPanel.TextBlueSlider'

    Begin Object Class=moSlider Name=AlphaSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Alpha"
        OnCreateComponent=TextRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust alpha of the stat panel"
        WinTop=0.3
        WinLeft=0.712188
        WinWidth=0.291445
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_alpha=moSlider'KFSXPanel.AlphaSlider'

    Begin Object Class=moSlider Name=TextScale
        MaxValue=1
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Text Scale"
        OnCreateComponent=TextRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="1"
        Hint="Adjust text size of the stat panel"
        WinTop=0.325
        WinLeft=0.712188
        WinWidth=0.291445
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_txtScale=moSlider'KFSXPanel.TextScale'

}
