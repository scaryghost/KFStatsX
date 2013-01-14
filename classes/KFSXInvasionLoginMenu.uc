/**
 * Custom login menu for KFStatsX.  The only change needed is to add an 
 * extra entry in the Panel variable
 * @author etsai (Scary Ghost)
 */
class KFSXInvasionLoginMenu extends KFGui.KFInvasionLoginMenu;

defaultproperties {
    Panels(4)=(ClassName="KFStatsX.KFSXPanel",Caption="KFStatsX",Hint="View stats about your current game")
}

