/**
 * Vertical list of the stat values of the given 
 * KFSXReplicationInfo object
 * @author etsai (Scary Ghost)
 */
class StatList extends GUIList
    config;

// Display
var texture InfoBackground;

var() config int bgR, bgG, bgB;
var() config int txtR, txtG, txtB;
var() config int alpha;
var() config float txtScale;

static function string formatTime(int seconds) {
    local string timeStr;
    local int i;
    local array<int> timeValues;
    
    timeValues.Length= 3;
    timeValues[0]= seconds / 3600;
    timeValues[1]= seconds / 60;
    timeValues[2]= seconds % 60;
    for(i= 0; i < timeValues.Length; i++) {
        if (timeValues[i] < 10) {
            timeStr= timeStr$"0"$timeValues[i];
        } else {
            timeStr= timeStr$timeValues[i];
        }
        if (i < timeValues.Length-1) {
            timeStr= timeStr$":";
        }
    }

    return timeStr;
}

function bool PreDraw(Canvas Canvas) {
    return false;
}

function DrawStat(Canvas Canvas, int CurIndex, float X, float Y, 
        float Width, float Height, bool bSelected, bool bPending) {
    local float TempX, TempY;
    local float TempWidth, TempHeight;
    local string S;

    // Offset for the Background
    TempX = X;
    TempY = Y;

    // Initialize the Canvas
    Canvas.Style = 1;
    Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
    Canvas.FontScaleX= Canvas.default.FontScaleX * txtScale;
    Canvas.FontScaleY= Canvas.default.FontScaleY * txtScale;
    Canvas.SetDrawColor(bgR, bgG, bgB, alpha);

    // Draw Item Background
    Canvas.SetPos(TempX, TempY);
    Canvas.DrawTileStretched(InfoBackground, Width, Height);

    // Select Text Color
    Canvas.SetDrawColor(txtR, txtG, txtB, alpha);

    // Write stat name
    Canvas.TextSize(Elements[CurIndex].Item,TempWidth,TempHeight);
    TempX += Width*0.1f;
    TempY += (Height-TempHeight)*0.5f;
    Canvas.SetPos(TempX, TempY);
    Canvas.DrawText(Elements[CurIndex].Item);

    // Write stat value
    if (InStr(Elements[CurIndex].Item, "Time") != -1) {
        S= formatTime(int(Elements[CurIndex].ExtraStrData));
    } else if (InStr(Elements[CurIndex].Item, "Cash") != -1) {
        S= "£" $ Elements[CurIndex].ExtraStrData;
    } else {
        S = Elements[CurIndex].ExtraStrData;
    }
    Canvas.TextSize(S,TempWidth,TempHeight);
    Canvas.SetPos(X + Width*0.88f - TempWidth, TempY);
    Canvas.DrawText(S);
}

function float PerkHeight(Canvas c) {
    return ((MenuOwner.ActualHeight() / 14.0) - 1.0) * txtScale;
}

defaultproperties {
    InfoBackground=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar'
    GetItemHeight=StatList.PerkHeight
    OnDrawItem=StatList.DrawStat
    FontScale=FNS_Medium
    OnPreDraw=StatList.PreDraw

    bgR=255
    bgG=255
    bgB=255
    txtR=0
    txtG=0
    txtB=0
    alpha=255
    txtScale=1.000
}
