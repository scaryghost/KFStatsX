KFStatsX
========

## Author
Scary Ghost

## About
Provides advanced statistics about a player's performance and tracks game information for each match.  This started out 
as enhancements to Game Stats Tab but I did not like how static everything was.  Eventually, I decided to rebuild the 
mutator from ground up and new features have made the mutator more resemble HLStatsX.

## Version
2.0.1

## Check Sum
The check sum for the package is generated with the following command from the system folder:

    ucc.exe Editor.CheckSumPackageCommandlet KFStatsX.u

If the output does not match any of the hashes in this README, you do not have an official version from me.

    2.0.1   2c0c4657258b2857d5d8c70b4c659cd6  
    2.0     9c0505e858678cb184f42f5bb18fab48  
    1.0.1   dbe26bdd5e126251acfa8cec82f9cc82  
    1.0     6ea3bd489c574ab046a431cfaf391aa3  

## Install
Copy the contents of the system folder to your Killing Floor system folder.  By default, mutator will provide an 
in game panel of statistics for each player but will not braodcast the accumulated stats to a remote server.  The panel 
can be opened with the console command "ingamestats".  For convenience, a button can be bound in the "Controls" menu, 
under the KFStatsX section or directly to the command:

    set input ${key} ingamestats

To enable stats broadcasting, check the box for "Broadcast Statistics" and fill in the server address, port, and 
password for the remote server.  If the server is a listened server or a solo game, enter in the steamid64 number  
of the local host.  This extra step is needed because the  game will not properly retrieve the steam id of the local 
host.  Your steamid64 number can be converted from your community url at http://steamidconverter.com/.

For clients, it is recommended to only copy the .int file to the system folder, and d/l the .u file from the server.  
This will prevent conflicts with future updates to the mod.

## Special Thanks
Marco - ServerPerks was instrumental in helping me understand how to setup 
        a vertical list and utilize the UDPLink class to broadcast to a 
        remote server.