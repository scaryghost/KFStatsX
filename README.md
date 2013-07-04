KFStatsX
========
Visit the project page to see the README in a formatted view:  
https://github.com/scaryghost/KFStatsX

## Author
Scary Ghost

## Release Notes
https://github.com/scaryghost/KFStatsX/wiki/Release-KFStatsX-3.0.1

## About
Provides advanced statistics about a player's performance and tracks game information for each match.  This started out 
as enhancements to Game Stats Tab but I did not like how static everything was.  Eventually, I decided to rebuild the 
mutator from ground up and new features have made the mutator more resemble HLStatsX.

## Version
3.0.1

## Check Sum
The check sum for the package is generated with the following command from the system folder:

    ucc.exe Editor.CheckSumPackageCommandlet KFStatsX.u

If the output does not match any of the hashes in this README, you do not have an official version from me.

    3.0.1   502be92059f1d2e0eb94741a3cdc9cbb
    3.0     d7520254a097dde029b5cda01ce5536f
    2.1     ba25d3a9f7c7c5264ed1051b22d8a8c0
    2.0.1   2c0c4657258b2857d5d8c70b4c659cd6  
    2.0     9c0505e858678cb184f42f5bb18fab48  
    1.0.1   dbe26bdd5e126251acfa8cec82f9cc82  
    1.0     6ea3bd489c574ab046a431cfaf391aa3  

## Install
Copy the contents of the system folder to your Killing Floor system folder.  To enable stats broadcasting, check the box 
for "Broadcast Statistics" and fill in the server address, port, and password for the remote server.  If the server is a 
listened server or a solo game, enter in the steamid64 number of the local host.  This extra step is needed because the 
game will not properly retrieve the local hosts' steamid64.  Your steamid64 number can be converted from your community 
url at http://steamidconverter.com/.

See the TWI thread for information on accumulating statistics:  
http://forums.tripwireinteractive.com/showthread.php?t=83045

## Usage
An extra tab will be present in the ESC menu titled "KFStatsX".  The tab's panel will provide a statistical summary for 
all players on the server.  

## Special Thanks
    Marco - ServerPerks was instrumental in helping me understand how to setup 
            a vertical list and utilize the UDPLink class to broadcast to a remote server.
