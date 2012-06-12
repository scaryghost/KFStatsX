/**
 * Custom fleshpound controller for the mutator
 * @author etsai (Scary Ghost)
 */
class FleshpoundZombieController_KFSX extends KFChar.FleshpoundZombieController;

state ZombieCharge {
    /**
     * Copied from KFChar.FleshpoundZombieController
     * Set bFrustrated to true before calling StartCharging
     */
    function Tick( float Delta ) {
        local ZombieFleshPound ZFP;
        Global.Tick(Delta);

        if( RageFrustrationTimer < RageFrustrationThreshhold ) {
            RageFrustrationTimer += Delta;

            if( RageFrustrationTimer >= RageFrustrationThreshhold ) {
                ZFP = ZombieFleshPound(Pawn);

                if( ZFP != none && !ZFP.bChargingPlayer ) {
//KFStatsX - 1
                    ZFP.bFrustrated = true;
                    ZFP.StartCharging();
//KFStatsX - 1 End
                }
            }
        }
    }
}
