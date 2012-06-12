/**
 * Displays the sliders controller text and background color/transparency
 * @author etsai (Scary Ghost)
 */
class PanelSettings extends MidGamePanel;

var automated GUISectionBackground i_BGText, i_BGBackground;
var automated moSlider sl_bgR, sl_bgG, sl_bgB, 
        sl_txtR, sl_txtG, sl_txtB, sl_alpha, sl_txtScale;

var() noexport transient int bgR, bgG, bgB, txtR, txtG, txtB, alpha;
var() noexport float txtScale;

var string setProp, getProp;

function ShowPanel(bool bShow) {
    super.ShowPanel(bShow);

    EnableComponent(sl_bgR);
    EnableComponent(sl_bgG);
    EnableComponent(sl_bgB);
    EnableComponent(sl_txtR);
    EnableComponent(sl_txtG);
    EnableComponent(sl_txtB);
    EnableComponent(sl_alpha);
    EnableComponent(sl_txtScale);
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

function InternalOnChange(GUIComponent Sender) {
    local PlayerController PC;

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

    Begin Object Class=GUISectionBackground Name=BGBackground
        bFillClient=True
        Caption="Background"
        WinTop=0.012063
        WinLeft=0.02
        WinWidth=0.45
        WinHeight=0.250
        OnPreDraw=BGBackground.InternalPreDraw
    End Object
    i_BGBackground=GUISectionBackground'PanelSettings.BGBackground'

    Begin Object Class=GUISectionBackground Name=BGText
        bFillClient=True
        Caption="Text"
        WinTop=0.012063
        WinLeft=0.53
        WinWidth=0.45
        WinHeight=0.250
        OnPreDraw=BGText.InternalPreDraw
    End Object
    i_BGText=GUISectionBackground'PanelSettings.BGText'

    Begin Object Class=moSlider Name=BackgroundRedSlider
        MaxValue=255
        MinValue=1
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Red"
        OnCreateComponent=BackgroundRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="0"
        Hint="Adjust the red value of the stat background color"
        WinTop=0.06
        WinLeft=0.045
        WinWidth=0.40
        TabOrder=2
        OnChange=PanelSettings.InternalOnChange
        OnLoadINI=PanelSettings.InternalOnLoadINI
    End Object
    sl_bgR=moSlider'PanelSettings.BackgroundRedSlider'

    Begin Object Class=moSlider Name=BackgroundGreenSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Green"
        OnCreateComponent=BackgroundRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="0"
        Hint="Adjust the green value of the stat background color"
        WinTop=0.09
        WinLeft=0.045
        WinWidth=0.40
        TabOrder=2
        OnChange=PanelSettings.InternalOnChange
        OnLoadINI=PanelSettings.InternalOnLoadINI
    End Object
    sl_bgG=moSlider'PanelSettings.BackgroundGreenSlider'

    Begin Object Class=moSlider Name=BackgroundBlueSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Blue"
        OnCreateComponent=BackgroundRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="0"
        Hint="Adjust the blue value of the stat background color"
        WinTop=0.12
        WinLeft=0.045
        WinWidth=0.40
        TabOrder=2
        OnChange=PanelSettings.InternalOnChange
        OnLoadINI=PanelSettings.InternalOnLoadINI
    End Object
    sl_bgB=moSlider'PanelSettings.BackgroundBlueSlider'

    Begin Object Class=moSlider Name=TextRedSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Red"
        OnCreateComponent=TextRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust the red value of the stat text color"
        WinTop=0.06
        WinLeft=0.555
        WinWidth=0.40
        TabOrder=2
        OnChange=PanelSettings.InternalOnChange
        OnLoadINI=PanelSettings.InternalOnLoadINI
    End Object
    sl_txtR=moSlider'PanelSettings.TextRedSlider'

    Begin Object Class=moSlider Name=TextGreenSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Green"
        OnCreateComponent=TextRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust the green value of the stat text color"
        WinTop=0.09
        WinLeft=0.555
        WinWidth=0.40
        TabOrder=2
        OnChange=PanelSettings.InternalOnChange
        OnLoadINI=PanelSettings.InternalOnLoadINI
    End Object
    sl_txtG=moSlider'PanelSettings.TextGreenSlider'

    Begin Object Class=moSlider Name=TextBlueSlider
        MaxValue=255
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Blue"
        OnCreateComponent=TextRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="255"
        Hint="Adjust the blue value of the stat text color"
        WinTop=0.12
        WinLeft=0.555
        WinWidth=0.40
        TabOrder=2
        OnChange=PanelSettings.InternalOnChange
        OnLoadINI=PanelSettings.InternalOnLoadINI
    End Object
    sl_txtB=moSlider'PanelSettings.TextBlueSlider'

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
        WinTop=0.15
        WinLeft=0.045
        WinWidth=0.40
        TabOrder=2
        OnChange=PanelSettings.InternalOnChange
        OnLoadINI=PanelSettings.InternalOnLoadINI
    End Object
    sl_alpha=moSlider'PanelSettings.AlphaSlider'

    Begin Object Class=moSlider Name=TextScale
        MaxValue=1
        MinValue=0
        SliderCaptionStyleName=""
        CaptionWidth=0.550000
        Caption="Scale"
        OnCreateComponent=TextRedSlider.InternalOnCreateComponent
        IniOption="@Internal"
        IniDefault="1"
        Hint="Adjust text size of the stat panel"
        WinTop=0.15
        WinLeft=0.555
        WinWidth=0.40
        TabOrder=2
        OnChange=PanelSettings.InternalOnChange
        OnLoadINI=PanelSettings.InternalOnLoadINI
    End Object
    sl_txtScale=moSlider'PanelSettings.TextScale'
}
