class KFSXPanel extends KFGui.KFTab_MidGameVoiceChat;

struct SliderStrPair {
    var moSlider slider;
    var String str;
};

var automated moComboBox categories, players;
var automated StatListBox lb_StatSelect;
var array<SortedMap> statsInfo;
var automated moSlider sl_bgR, sl_bgG, sl_bgB,
        sl_txtR, sl_txtG, sl_txtB, sl_alpha, sl_txtScale;
var array<SliderStrPair> sliders;
var String statListClass;

function ShowPanel(bool bShow) {
    super.ShowPanel(bShow);

    if (bShow) {
        lb_StatSelect.statListObj.InitList(statsInfo[categories.GetIndex()]);
    }
}

function fillStatsInfo(KFSXReplicationInfo kfsxRI) {
    statsInfo[0]= kfsxRi.player;
    statsInfo[1]= kfsxRi.actions;
    statsInfo[2]= kfsxRi.weapons;
    statsInfo[3]= kfsxRi.kills;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
    local int i;

    super.InitComponent(MyController, MyOwner);

    sliders.Length= 8;
    sliders[0].slider= sl_bgR;
    sliders[0].str= "bgR";
    sliders[1].slider= sl_bgG;
    sliders[1].str= "bgG";
    sliders[2].slider= sl_bgB;
    sliders[2].str= "bgB";
    sliders[3].slider= sl_alpha;
    sliders[3].str= "alpha";
    sliders[4].slider= sl_txtR;
    sliders[4].str= "txtR";
    sliders[5].slider= sl_txtG;
    sliders[5].str= "txtG";
    sliders[6].slider= sl_txtB;
    sliders[6].str= "txtB";
    sliders[7].slider= sl_txtScale;
    sliders[7].str= "txtScale";


    sb_Players.Caption= "Stats";
    sb_Players.ManageComponent(lb_StatSelect);

    sb_Specs.Caption= "Filters";
    sb_Specs.ManageComponent(categories);
    sb_Specs.ManageComponent(players);

    sb_Options.Caption= "Settings";
    for(i= 0; i < sliders.Length; i++) {
        sb_Options.ManageComponent(sliders[i].slider);
    }

    categories.AddItem("Player");
    categories.AddItem("Actions");
    categories.AddItem("Weapons");
    categories.AddItem("Kills");

    fillStatsInfo(class'KFSXReplicationInfo'.static.findKFSXri(PlayerOwner().PlayerReplicationInfo));
    for(i= 0; i < PlayerOwner().GameReplicationInfo.PRIArray.Length; i++) {
        players.AddItem(PlayerOwner().GameReplicationInfo.PRIArray[i].PlayerName);
        if (PlayerOwner().GameReplicationInfo.PRIArray[i] == PlayerOwner().PlayerReplicationInfo) {
            players.SetIndex(i);
        }
    }
}

function InternalOnLoadINI(GUIComponent sender, string s) {
    local int i;
    local String command;

    while(i < sliders.Length && sender != sliders[i].slider) {
        i++;
    }
    if (i < sliders.Length) {
        command= "get" @ statListClass @ sliders[i].str;
        sliders[i].slider.SetComponentValue(float(PlayerOwner().ConsoleCommand(command)), true);
    }
}

function InternalOnChange(GUIComponent sender) {
    local int i;
    local String command;

    if (sender == categories) {
        ShowPanel(true);
    } else if (sender == players) {
        fillStatsInfo(class'KFSXReplicationInfo'.static.findKFSXri(PlayerOwner().GameReplicationInfo.PRIArray[players.GetIndex()]));
        ShowPanel(true);
    } else {
        while(i < sliders.Length && sender != sliders[i].slider) {
            i++;
        }
        if (i < sliders.Length) {
            command= "set"@ statListClass @ sliders[i].str @ sliders[i].slider.GetValue();
            PlayerOwner().ConsoleCommand(command);
        }
    }
}

defaultproperties {
    statListClass= "KFStatsX.StatList"

    lb_Players= None
    lb_Specs= None
    ch_NoVoiceChat= None
    ch_NoSpeech= None
    ch_NoText= None
    ch_Ban= None

    Begin Object Class=moComboBox Name=CategoryComboBox
        bReadOnly=True
        ComponentJustification=TXTA_Left
        Caption="Category"
        IniOption="@Internal"
        IniDefault="Player"
        Hint="KFStatsX stat categories"
        TabOrder=3
        OnChange=KFSXPanel.InternalOnChange
    End Object
    categories=moComboBox'KFSXPanel.CategoryComboBox'

    Begin Object Class=moComboBox Name=PlayerComboBox
        bReadOnly=True
        ComponentJustification=TXTA_Left
        Caption="Player"
        IniOption="@Internal"
        Hint="View stats for all players"
        TabOrder=3
        OnChange=KFSXPanel.InternalOnChange
    End Object
    players=moComboBox'KFSXPanel.PlayerComboBox'

    Begin Object Class=StatListBox Name=StatSelectList
        WinTop=0.070063
        WinLeft=0.029240
        WinWidth=0.941520
        WinHeight=0.792836
    End Object
    lb_StatSelect=StatListBox'KFSXPanel.StatSelectList'

    Begin Object Class=moSlider Name=BackgroundRedSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="BG Red"
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
        CaptionWidth=0.550000
        Caption="BG Green"
        IniOption="@Internal"
        IniDefault="0"
        Hint="Adjust the green value of the stat background color"
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_bgG=moSlider'KFSXPanel.BackgroundGreenSlider'

    Begin Object Class=moSlider Name=BackgroundBlueSlider
        MaxValue=255
        MinValue=0
        CaptionWidth=0.550000
        Caption="BG Blue"
        IniOption="@Internal"
        IniDefault="0"
        Hint="Adjust the blue value of the stat background color"
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_bgB=moSlider'KFSXPanel.BackgroundBlueSlider'

    Begin Object Class=moSlider Name=TextRedSlider
        MaxValue=255
        MinValue=0
        CaptionWidth=0.550000
        Caption="Text Red"
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust the red value of the stat text color"
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_txtR=moSlider'KFSXPanel.TextRedSlider'

    Begin Object Class=moSlider Name=TextGreenSlider
        MaxValue=255
        MinValue=0
        CaptionWidth=0.550000
        Caption="Text Green"
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust the green value of the stat text color"
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_txtG=moSlider'KFSXPanel.TextGreenSlider'

    Begin Object Class=moSlider Name=TextBlueSlider
        MaxValue=255
        MinValue=0
        CaptionWidth=0.550000
        Caption="Text Blue"
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust the blue value of the stat text color"
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_txtB=moSlider'KFSXPanel.TextBlueSlider'

    Begin Object Class=moSlider Name=AlphaSlider
        MaxValue=255
        MinValue=0
        CaptionWidth=0.550000
        Caption="Alpha"
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust alpha of the stat panel"
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_alpha=moSlider'KFSXPanel.AlphaSlider'

    Begin Object Class=moSlider Name=TextScale
        MaxValue=1
        MinValue=0
        CaptionWidth=0.550000
        Caption="Text Scale"
        IniOption="@Internal"
        IniDefault="1"
        Hint="Adjust text size of the stat panel"
        TabOrder=2
        OnChange=KFSXPanel.InternalOnChange
        OnLoadINI=KFSXPanel.InternalOnLoadINI
    End Object
    sl_txtScale=moSlider'KFSXPanel.TextScale'

}
