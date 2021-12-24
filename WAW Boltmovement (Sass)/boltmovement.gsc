#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

/* 
    Converted Sass's Bolt Movement on MW2 to WAW. Partial credits to Antiga for conversion.

    - On connect, call: self.pers["poscount"] = 0;
    - On spawn, call: self.boltSpeed = 5; and setDvar("cg_nopredict", 0);
    - Works on DPAD, but I did not convert them yet, going to use native system.
    
    Function Set:
    - saveBoltPos saves Bolt Movement points.
    - DeleteBoltPos deletes Bolt Movement points.
    - testBM executes actual Bolt Movement function.
    - WatchJumping monitors a button press to exit before Bolt Movement completion.
    - BoltSpeed allows for adjustment of speed.
        - use case in menu: ::boltspeed, 0.5, true) adds
        - use case in menu: ::boltspeed, 0.5) subtracts

*/

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

testBM()
{
    self endon("disconnect");
    for(;;)
    {
        if(self meleeButtonPressed() && !self.menuOpen && !self.isBolting)
        {
            self thread BoltStart();
        }
        wait 0.05;
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
    setDvar("cg_nopredict", 1); //Allows for ADS while bolting.
    wait 0.05;
    self linkTo(boltModel);
    self thread WatchJumping(boltModel);
    for(i=1 ; i < self.pers["poscount"] + 1 ; i++)
    {
        boltModel moveTo(self.pers["boltorigin"][i],self.boltSpeed/ self.pers["poscount"], 0, 0);
        wait(self.boltSpeed / self.pers["poscount"]);
    }
    self unlink();
    boltModel delete();
    self.isBolting = false;
    setDvar("cg_nopredict", 0);
}

WatchJumping(model)
{
	self endon("disconnect");
	if(self adsButtonPressed())
    {
        self Unlink();
        model delete();
        self.isBolting = false;
        setDvar("cg_nopredict", 0);
    }
}

BoltSpeed(amount, speed)
{
	value = self.boltSpeed;
	if(isDefined(speed))
	{
		value = value + amount;
		self.boltSpeed = value;
	}	
	else
	{
		value = value - amount;
		self.boltSpeed = value;
	}
	self iPrintLn("Bolt Speed Changed To: ^2" + value);
}
