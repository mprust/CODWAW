#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/* 
    Converted Sass's Bolt Movement on MW2 to WAW. Partial credits to Antiga for conversion.

    - On connect, call: 
        if(!isDefined(player.pers["poscount"]))
			player.pers["poscount"] = 0;
    
    - On spawn, call: 
        setDvar("cg_nopredict", 0);
        self.boltbind = false;
    
    Actual Functons:
    - toggleBoltMovement toggles if bolt movement bind should be active.
    - saveBoltPos saves Bolt Movement points.
    - DeleteBoltPos deletes Bolt Movement points.
    - cycleBolt goes through all DPAD's for Bolt Movement.
    - BoltSpeed allows for adjustment of speed. This uses a DVAR so it will save throughout the game until you close out or load a new patch.
        - use case in menu: ::boltspeed, 0.5, true) adds
        - use case in menu: ::boltspeed, 0.5) subtracts
    - Bolt points save throughout the rounds.

*/

toggleBoltMovement()
{
    if(!self.boltbind)
    {
        self.boltbind = true;
        self thread testBM();
    } else {
        self.boltbind = false;
        self notify("stopboltbind");
    }
}

testBM()
{
    self endon("disconnect");
    self endon("stopboltbind");
    for(;;)
    {
        if(self meleeButtonPressed() && !self.MenuOpen && !self.isBolting)//meleeButtonPressed() Can Be Set to whatever for initiating.
        {
            self thread BoltStart();
        }
        wait 0.05;
    }
}

saveBoltPos()
{
    self.pers["poscount"] += 1;
    self.pers["boltorigin"][self.pers["poscount"]] = self GetOrigin();
    self iPrintLn("Position ^2#" + self.pers["poscount"] + " ^7saved: " + self.origin);
}

DeleteBoltPos()
{
    if(self.pers["poscount"] == 0)
    {
        self iPrintLn("^1There are no points to delete");
    }
    else
    {
        self.pers["boltorigin"][self.pers["poscount"]] = undefined;
        self iPrintLn("Position ^2#" + self.pers["poscount"] + " ^7deleted");
        self.pers["poscount"] -= 1;
    }
}

BoltStart()
{
    self endon("detachBolt");
    self endon("disconnect");
    if(self.pers["poscount"] == 0)
    {
        self iPrintLn("^1There aren't any points to move to...");
    }
    boltModel = spawn("script_model", self.origin);
    boltModel setModel("tag_origin");
    self.isBolting = true;
    setDvar("cg_nopredict", 1);
    wait 0.05;
    self linkTo(boltModel);
    self thread WatchJumping(boltModel);
    for(i=1; i < self.pers["poscount"] + 1 ; i++)
    {
        boltModel moveTo(self.pers["boltorigin"][i],getDvarInt("boltSpeed")/self.pers["poscount"], 0, 0);
        wait(getDvarInt("boltSpeed") / self.pers["poscount"]);
    }
    self unlink();
    boltModel delete();
    self.isBolting = false;
    setDvar("cg_nopredict", 0);
}

WatchJumping(model)
{
	self endon("disconnect");
    if(self attackButtonPressed())//Can Be Set to whatever for disconnect.
    {
        self Unlink();
        model delete();
        self.isBolting = false;
        self notify("detachBolt");
        setDvar("cg_nopredict", 0);
    }
}

BoltSpeed(amount, speed)
{
    value = getDvarInt("boltSpeed");
	if(isDefined(speed))
	{
		value = value + amount;
        setDvar("boltSpeed", value);
	}	
	else
	{
		value = value - amount;
        setDvar("boltSpeed", value);
	}
	self iPrintLn("Bolt Speed Changed To: ^2" + value);
}