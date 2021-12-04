#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

#include maps\mp\gametypes\_emblemSupport;

init()
{
    level.killcam_style = 0;
    level.fk = false;
    level.showFinalKillcam = false;
    level.waypoint = false;
	level.doingFinalKillcamFx = undefined;
    
    level.doFK["axis"] = false;
    level.doFK["allies"] = false;
    
    level.slowmotstart = undefined;
    OnPlayerConnect();
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread beginFK();
    }
}    
        
beginFK()
{
    self endon("disconnect");
    
    for(;;)
    {
        self waittill("beginFK", winner);
        
        self notify ( "reset_outcome" );
        
        if(level.TeamBased)
        {
            self finalkillcam(level.KillInfo[winner]["attacker"], level.KillInfo[winner]["attackerNumber"], level.KillInfo[winner]["deathTime"], level.KillInfo[winner]["victim"]);
        }
        else
        {
            self finalkillcam(winner.KillInfo["attacker"], winner.KillInfo["attackerNumber"], winner.KillInfo["deathTime"], winner.KillInfo["victim"]);
        }
    }
}

finalkillcam( attacker, attackerNum, deathtime, victim)
{
    self endon("disconnect");
    level endon("end_killcam");

    self SetClientDvar("ui_ShowMenuOnly", "none");
	maxtime = undefined;
    camtime = 4;
	self.isCamtime = camtime;
    predelay = getTime()/1000 - deathTime;
    postdelay = 3;
    killcamlength = camtime + postdelay;
    killcamoffset = camtime + predelay;

	if (isdefined(maxtime)) {
		if (camtime > maxtime)
			camtime = maxtime;
		if (camtime < .05)
			camtime = .05;
	}

	// don't let the killcam last past the end of the round.
	if (isdefined(maxtime) && killcamlength > maxtime)
	{
		// first trim postdelay down to a minimum of 1 second.
		// if that doesn't make it short enough, trim camtime down to a minimum of 1 second.
		// if that's still not short enough, cancel the killcam.
		if ( maxtime < 2 )
			return;

		if (maxtime - camtime >= 1) {
			// reduce postdelay so killcam ends at end of match
			postdelay = maxtime - camtime;
		}
		else {
			// distribute remaining time over postdelay and camtime
			postdelay = 1;
			camtime = maxtime - 1;
		}
		
		// recalc killcamlength
		killcamlength = camtime + postdelay;
	}

	thread doFinalKillCamFX( camtime );
    
    visionSetNaked( getdvar("mapname") );
    
    self notify ( "begin_killcam", getTime() );
    
    self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", true);
	self allowSpectateTeam("none", true);
    
    self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.killcamentity = -1;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = 0;
    
    self.killcam = true;
    
    wait 0.05;
    
    if(!isDefined(self.top_fk_shader))
    {
        self drawNewKCMenu(victim , attacker);
    }
    else
    {
        self.fk_title.alpha = 1;
        self.fk_title_low.alpha = 1;
        self.top_fk_shader.alpha = 0.5;
        self.bottom_fk_shader.alpha = 0.5;
        self.credits.alpha = 0.2;
    }
    
    self thread WaitEnd(killcamlength);
    
    wait 0.05;
    
    self waittill("end_killcam");
    
    self thread CleanFK();
    
    self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
    
    wait 0.05;
    
    self.sessionstate = "spectator";
	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	assert( spawnpoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	self spawn(spawnpoint.origin, spawnpoint.angles);

    wait 0.05;
    
    self.killcam = undefined;
    self thread maps\mp\gametypes\_spectating::setSpectatePermissions();

    level notify("end_killcam");

    level.fk = false;  
}

CleanFK()
{
    self.fk_title.alpha = 0;
    self.fk_title_low.alpha = 0;
    self.top_fk_shader.alpha = 0;
    self.bottom_fk_shader.alpha = 0;
    self.credits.alpha = 0;

	/* Cleans Title And Emblem Stuff */
	self.customEmb.alpha = 0;
	self.customCallbox.alpha = 0;
	self.rankTexyt.alpha = 0;
	self.rankICONLOL.alpha = 0;
	self.coloredgradientBoxE.alpha = 0;
	self.customEmb notify("endEmbBre");
	self.coloredgradientBoxE notify("end_gradFlash");
	self.kc_timer.alpha = 0;
	/* End of Cleaning Title and Emblem Stuff */

    self SetClientDvar("ui_ShowMenuOnly", "");
    
    visionSetNaked( "mpOutro", 1.0 );
}

WaitEnd( killcamlength )
{
    self endon("disconnect");
	self endon("end_killcam");
    
    wait killcamlength;
    
    self notify("end_killcam");
}

drawNewKCMenu(victim, attacker)
{
    self.fk_title_low = newClientHudElem(self);
    self.fk_title_low.archived = false;
    self.fk_title_low.x = -25;
    self.fk_title_low.y = -35;
    self.fk_title_low.alignX = "center";
    self.fk_title_low.alignY = "bottom";
    self.fk_title_low.horzAlign = "center_safearea";
    self.fk_title_low.vertAlign = "bottom";
    self.fk_title_low.sort = 1; // force to draw after the bars
    self.fk_title_low.font = "objective";
    self.fk_title_low.fontscale = 1;
    self.fk_title_low.foreground = true;
	self.fk_title_low setText(attacker.name);

	/* Title and Emblem Icons */
	rankIcon = self maps\mp\gametypes\_rank::getRankInfoIcon( self.pers["rank"], self.pers["prestige"] );

	self.rankICONLOL = newClientHudElem(self);
	self.rankICONLOL.archived = false;
	self.rankICONLOL.elemType = "shader";
	self.rankICONLOL.x = -25;
	self.rankICONLOL.y = -22;
	self.rankICONLOL.alignX = "center";
	self.rankICONLOL.alignY = "bottom";
	self.rankICONLOL.horzAlign = "center_safearea";
	self.rankICONLOL.vertAlign = "bottom";
	self.rankICONLOL.sort = 1; // force to draw after the bars
	self.rankICONLOL setShader(rankIcon, 13, 13);
	self.rankICONLOL.foreground = true;

	self.rankTexyt = newClientHudElem(self);
	self.rankTexyt.archived = false;
	self.rankTexyt.x = -13;
	self.rankTexyt.y = -22;
	self.rankTexyt.alignX = "center";
	self.rankTexyt.alignY = "bottom";
	self.rankTexyt.horzAlign = "center_safearea";
	self.rankTexyt.vertAlign = "bottom";
	self.rankTexyt.sort = 1; // force to draw after the bars
	self.rankTexyt.font = "objective";
	self.rankTexyt.fontscale = 1;
	self.rankTexyt.foreground = true;
	self.rankTexyt setText(self.pers["rank"]);

	self.customEmb = newClientHudElem(self);
	self.customEmb.archived = false;
	self.customEmb.elemType = "shader";
	self.customEmb.x = -65;
	self.customEmb.y = -23;
	self.customEmb.alignX = "center";
	self.customEmb.alignY = "bottom";
	self.customEmb.horzAlign = "center_safearea";
	self.customEmb.vertAlign = "bottom";
	self.customEmb.sort = 1; // force to draw after the bars
	self.customEmb setShader(self.pers["myEmblemChoice"], 30, 30);
	self.customEmb.foreground = true;

	self.customCallbox = newClientHudElem(self);
	self.customCallbox.archived = false;
	self.customCallbox.elemType = "shader";
	self.customCallbox.x = 0;
	self.customCallbox.y = -20;
	self.customCallbox.alignX = "center";
	self.customCallbox.alignY = "bottom";
	self.customCallbox.horzAlign = "center_safearea";
	self.customCallbox.vertAlign = "bottom";
	self.customCallbox.sort = 1; // force to draw after the bars
	self.customCallbox.foreground = true;
	self.customCallbox setShader(self.pers["myTitleChoice"], 185, 38);

	self.coloredgradientBoxE = newClientHudElem(self);
	self.coloredgradientBoxE.archived = false;
	self.coloredgradientBoxE.elemType = "shader";
	self.coloredgradientBoxE.x = 0;
	self.coloredgradientBoxE.y = -20;
	self.coloredgradientBoxE.alignX = "center";
	self.coloredgradientBoxE.alignY = "bottom";
	self.coloredgradientBoxE.horzAlign = "center_safearea";
	self.coloredgradientBoxE.vertAlign = "bottom";
	self.coloredgradientBoxE.sort = 1; // force to draw after the bars
	if(!self.flashingGrad)
	{
		self.coloredgradientBoxE.color = self.pers["gradColour"];
	} else {
		self.coloredgradientBoxE thread doFlashingGrad();
	}
	self.coloredgradientBoxE.foreground = true;
	self.coloredgradientBoxE setShader("white", 185, 38);

	/* End of Title and Emblem Icons */

    self.top_fk_shader = newClientHudElem(self);
    self.top_fk_shader.elemType = "shader";
    self.top_fk_shader.archived = false;
    self.top_fk_shader.horzAlign = "fullscreen";
    self.top_fk_shader.vertAlign = "fullscreen";
    self.top_fk_shader.sort = 0;
    self.top_fk_shader.foreground = true;
    self.top_fk_shader.color = (.15, .15, .15);
    self.top_fk_shader setShader("white",640,60);
    
    self.bottom_fk_shader = newClientHudElem(self);
    self.bottom_fk_shader.elemType = "shader";
    self.bottom_fk_shader.y = 420;
    self.bottom_fk_shader.archived = false;
    self.bottom_fk_shader.horzAlign = "fullscreen";
    self.bottom_fk_shader.vertAlign = "fullscreen";
    self.bottom_fk_shader.sort = 0; 
    self.bottom_fk_shader.foreground = true;
    self.bottom_fk_shader.color	= (.15, .15, .15);
    self.bottom_fk_shader setShader("white",640,60);
    
    self.fk_title = newClientHudElem(self);
    self.fk_title.archived = false;
    self.fk_title.y = 30;
    self.fk_title.alignX = "center";
    self.fk_title.alignY = "middle";
    self.fk_title.horzAlign = "center";
    self.fk_title.vertAlign = "top";
    self.fk_title.sort = 1; // force to draw after the bars
    self.fk_title.font = "objective";
    self.fk_title.fontscale = 2;
    self.fk_title.foreground = true;
    self.fk_title.shadown = 1;
    
    self.credits = newClientHudElem(self);
    self.credits.archived = false;
    self.credits.x = 0;
    self.credits.y = 0;
    self.credits.alignX = "left";
    self.credits.alignY = "bottom";
    self.credits.horzAlign = "left";
    self.credits.vertAlign = "bottom";
    self.credits.sort = 1; // force to draw after the bars
    self.credits.font = "default";
    self.credits.fontscale = 1.4;
    self.credits.foreground = true;

	/* KC Timer */
	self.kc_timer = newClientHudElem(self);
    self.kc_timer.archived = false;
	self.kc_timer.y = 48;
    self.kc_timer.alignX = "center";
    self.kc_timer.alignY = "middle";
    self.kc_timer.horzAlign = "center_safearea";
    self.kc_timer.vertAlign = "top_adjustable";
    self.kc_timer.sort = 1; // force to draw after the bars
    self.kc_timer.font = "objective";
    self.kc_timer.fontscale = 1.75;
    self.kc_timer.foreground = true;
    self.kc_timer.shadown = 1;	
	self.kc_timer setTenthsTimer(self.isCamtime);
	/* End of KC Timer */
        
    self.fk_title.alpha = 1;
    self.fk_title_low.alpha = 1;
    self.top_fk_shader.alpha = 0.5;
    self.bottom_fk_shader.alpha = 0.5;
    self.credits.alpha = 0.2;
	if(self.kcTimer)
	{
		self.kc_timer.alpha = 1;
	}

    self.credits setText("   ");
	/* Title and Emblem Alpha's */
	if(self.CustomKCEM)
	{
		if(!self.breathingEmb)
		{
			self.customEmb.alpha = 1;
		} else {
			self.customEmb thread doBreathingEmb();
		}
		if(!self.coloredgradientBox)
		{
			self.coloredgradientBoxE.alpha = 0;
		} else {
			self.coloredgradientBoxE.alpha = 0.55;
		}
		self.customCallbox.alpha = 1;
		self.rankTexyt.alpha = 1;
		self.rankICONLOL.alpha = 1;
	} else {
		self.customEmb.alpha = 0;
		self.customCallbox.alpha = 0;
		self.rankTexyt.alpha = 0;
		self.rankICONLOL.alpha = 0;	
		self.coloredgradientBoxE.alpha = 0;
		self.customEmb notify("endEmbBre");
		self.coloredgradientBoxE notify("end_gradFlash");
	}
    /* End of Title and Emblem Alpha's */

    if( !level.killcam_style )
        self.fk_title setText("FINAL KILLCAM");
    else
        self.fk_title setText("ROUND WINNING KILL");
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
    if(attacker != self)
    {
        level.showFinalKillcam = true;
        
        team = attacker.team;
        
        level.doFK[team] = true;
        
        if(level.teamBased)
        {
            level.KillInfo[team]["attacker"] = attacker;
            level.KillInfo[team]["attackerNumber"] = attacker getEntityNumber();
            level.KillInfo[team]["victim"] = self;
            level.KillInfo[team]["deathTime"] = GetTime()/1000;
        }
        else
        {
            attacker.KillInfo["attacker"] = attacker;
            attacker.KillInfo["attackerNumber"] = attacker getEntityNumber();
            attacker.KillInfo["victim"] = self;
            attacker.KillInfo["deathTime"] = GetTime()/1000;
        }
    }
}

endGame( winner, endReasonText )
{
	// return if already ending via host quit or victory
	if ( game["state"] == "postgame" || level.gameEnded )
		return;

	if ( isDefined( level.onEndGame ) )
		[[level.onEndGame]]( winner );

	visionSetNaked( "mpOutro", 2.0 );
	
	game["state"] = "postgame";
	level.gameEndTime = getTime();
	level.gameEnded = true;
	level.inGracePeriod = false;
	level notify ( "game_ended" );
    
    if ( isdefined( winner ) && level.gametype == "sd" )
		[[level._setTeamScore]]( winner, [[level._getTeamScore]]( winner ) + 1 );
	
	setGameEndTime( 0 ); // stop/hide the timers
	
	if ( level.rankedMatch )
	{
		maps\mp\gametypes\_globallogic::setXenonRanks();
		
		if ( maps\mp\gametypes\_globallogic::hostIdledOut() )
		{
			level.hostForcedEnd = true;
			logString( "host idled out" );
			endLobby();
		}
	}
	
	maps\mp\gametypes\_globallogic::updatePlacement();
	maps\mp\gametypes\_globallogic::updateMatchBonusScores( winner );
	maps\mp\gametypes\_globallogic::updateWinLossStats( winner );
	
	setdvar( "g_deadChat", 1 );
	
	// freeze players
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		if(player.toggleFloaters == false)
		{
			player maps\mp\gametypes\_globallogic::freezePlayerForRoundEnd();
		}
		
		player thread maps\mp\gametypes\_globallogic::roundEndDoF( 4.0 );
		
		player maps\mp\gametypes\_globallogic::freeGameplayHudElems();
		
		player setClientDvars( "cg_everyoneHearsEveryone", 1 );

		if( level.rankedMatch )
		{
			if ( isDefined( player.setPromotion ) )
				player setClientDvar( "ui_lobbypopup", "promotion" );
			else
				player setClientDvar( "ui_lobbypopup", "summary" );
		}
	}

    // end round
    if ( (level.roundLimit > 1 || (!level.roundLimit && level.scoreLimit != 1)) && !level.forcedEnd )
    {
		if ( level.displayRoundEndText )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];
				
				if ( level.teamBased )
					player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, true, endReasonText );
				else
					player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
		
				player setClientDvars( "ui_hud_hardcore", 1,
									   "cg_drawSpectatorMessages", 0,
									   "g_compassShowEnemies", 0 );
			}

			if ( level.teamBased && !(maps\mp\gametypes\_globallogic::hitRoundLimit() || maps\mp\gametypes\_globallogic::hitScoreLimit()) )
				thread maps\mp\gametypes\_globallogic::announceRoundWinner( winner, level.roundEndDelay / 4 );
			
			if ( maps\mp\gametypes\_globallogic::hitRoundLimit() || maps\mp\gametypes\_globallogic::hitScoreLimit() )
				maps\mp\gametypes\_globallogic::roundEndWait( level.roundEndDelay / 2, false );
			else
				maps\mp\gametypes\_globallogic::roundEndWait( level.roundEndDelay, true );
		}
        
		game["roundsplayed"]++;
		roundSwitching = false;
		if ( !maps\mp\gametypes\_globallogic::hitRoundLimit() && !maps\mp\gametypes\_globallogic::hitScoreLimit() )
			roundSwitching = maps\mp\gametypes\_globallogic::checkRoundSwitch();

		if ( roundSwitching && level.teamBased )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];
				
				if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
				{
					player [[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();
					continue;
				}
				
				switchType = level.halftimeType;
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
							switchType = "halftime";
						else
							switchType = "intermission";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
							switchType = "halftime";
						else
							switchType = "intermission";
					}
					else
					{
						switchType = "intermission";
					}
				}
				switch( switchType )
				{
					case "halftime":
						player maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "halftime" );
						break;
					case "overtime":
						player maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "overtime" );
						break;
					default:
						player maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "side_switch" );
						break;
				}
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, level.halftimeSubCaption );
				player setClientDvar( "ui_hud_hardcore", 1 );
			}
			
			maps\mp\gametypes\_globallogic::roundEndWait( level.halftimeRoundEndDelay, false );
		}
		else if ( !maps\mp\gametypes\_globallogic::hitRoundLimit() && !maps\mp\gametypes\_globallogic::hitScoreLimit() && !level.displayRoundEndText && level.teamBased )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];

				if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
				{
					player [[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();
					continue;
				}
				
				switchType = level.halftimeType;
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
							switchType = "halftime";
						else
							switchType = "roundend";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
							switchType = "halftime";
						else
							switchTime = "roundend";
					}
				}
				switch( switchType )
				{
					case "halftime":
						player maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "halftime" );
						break;
					case "overtime":
						player maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "overtime" );
						break;
				}
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, endReasonText );
				player setClientDvar( "ui_hud_hardcore", 1 );
			}			

			maps\mp\gametypes\_globallogic::roundEndWait( level.halftimeRoundEndDelay, !(maps\mp\gametypes\_globallogic::hitRoundLimit() || maps\mp\gametypes\_globallogic::hitScoreLimit()) );
		}
        
        if(level.players.size > 0 && level.gametype == "sd" && !maps\mp\gametypes\_globallogic::hitScoreLimit())
        {
            level.killcam_style = 1;
            thread startFK( winner );
        }
        
        if(level.fk)
            level waittill("end_killcam");

        if ( !maps\mp\gametypes\_globallogic::hitRoundLimit() && !maps\mp\gametypes\_globallogic::hitScoreLimit() )
        {
        	level notify ( "restarting" );
            game["state"] = "playing";
            map_restart( true );
            return;
        }
        
		if ( maps\mp\gametypes\_globallogic::hitRoundLimit() )
			endReasonText = game["strings"]["round_limit_reached"];
		else if ( maps\mp\gametypes\_globallogic::hitScoreLimit() )
			endReasonText = game["strings"]["score_limit_reached"];
		else
			endReasonText = game["strings"]["time_limit_reached"];
	}
	
	thread maps\mp\gametypes\_missions::roundEnd( winner );
	
	// catching gametype, since DM forceEnd sends winner as player entity, instead of string
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
		{
			player [[level.spawnIntermission]]();
			player closeMenu();
			player closeInGameMenu();
			continue;
		}
		
		if ( level.teamBased )
		{
			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, false, endReasonText );
		}
		else
		{
			player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
			
			if ( isDefined( winner ) && player == winner )
				player playLocalSound( game["music"]["victory_" + player.pers["team"] ] );
			else if ( !level.splitScreen )
				player playLocalSound( game["music"]["defeat"] );
		}
		
		player setClientDvars( "ui_hud_hardcore", 1,
							   "cg_drawSpectatorMessages", 0,
							   "g_compassShowEnemies", 0 );
	}
	
	if ( level.teamBased )
	{
		thread maps\mp\gametypes\_globallogic::announceGameWinner( winner, level.postRoundTime / 2 );
		
		if ( level.splitscreen )
		{
			if ( winner == "allies" )
				playSoundOnPlayers( game["music"]["victory_allies"], "allies" );
			else if ( winner == "axis" )
				playSoundOnPlayers( game["music"]["victory_axis"], "axis" );
			else
				playSoundOnPlayers( game["music"]["defeat"] );
		}
		else
		{
			if ( winner == "allies" )
			{
				playSoundOnPlayers( game["music"]["victory_allies"], "allies" );
				playSoundOnPlayers( game["music"]["defeat"], "axis" );
			}
			else if ( winner == "axis" )
			{
				playSoundOnPlayers( game["music"]["victory_axis"], "axis" );
				playSoundOnPlayers( game["music"]["defeat"], "allies" );
			}
			else
			{
				playSoundOnPlayers( game["music"]["defeat"] );
			}
		}
	}
    
    wait 9;
    
    if(level.players.size > 0 && level.gametype != "sd")
    {
        level.killcam_style = 0;
        thread startFK( winner );
    }
    
    if(level.gametype == "sd" && maps\mp\gametypes\_globallogic::hitScoreLimit() && level.players.size > 0)
    {
        level.killcam_style = 0;
        thread startFK( winner );
    }
    
    if(level.fk)
        level waittill("end_killcam");
	else
        maps\mp\gametypes\_globallogic::roundEndWait( level.postRoundTime, true );
	
	level.intermission = true;
	
	//regain players array since some might've disconnected during the wait above
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		player closeMenu();
		player closeInGameMenu();
		player notify ( "reset_outcome" );
		player thread maps\mp\gametypes\_globallogic::spawnIntermission();
		player setClientDvar( "ui_hud_hardcore", 0 );
		player setclientdvar( "g_scriptMainMenu", game["menu_eog_main"] );
	}
	
	logString( "game ended" );
	wait getDvarFloat( "scr_show_unlock_wait" );
	
	if( level.console )
	{
		exitLevel( false );
		return;
	}
	
	// popup for game summary
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		//iPrintLn( "opening eog summary!" );
		//player.sessionstate = "dead";
		player openMenu( game["menu_eog_unlock"] );
	}
	
	thread timeLimitClock_Intermission( getDvarFloat( "scr_intermission_time" ) );
	wait getDvarFloat( "scr_intermission_time" );
	
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		//iPrintLn( "closing eog summary!" );
		player closeMenu();
		player closeInGameMenu();
	}
	
	exitLevel( false );
}

timeLimitClock_Intermission( waitTime )
{
	setGameEndTime( getTime() + int(waitTime*1000) );
	clockObject = spawn( "script_origin", (0,0,0) );
	
	if ( waitTime >= 10.0 )
		wait ( waitTime - 10.0 );
		
	for ( ;; )
	{
		clockObject playSound( "ui_mp_timer_countdown" );
		wait ( 1.0 );
	}	
}

startFK( winner )
{
    level endon("end_killcam");

    if(!level.showFinalKillcam)
        return;
    
    if(!isPlayer(Winner) && !level.doFK[winner])
        return;
    
    level.fk = true;
    
    for( i = 0; i < level.players.size; i ++)
    {
        player = level.players[i];
        
        player notify("beginFK", winner);
    }
}

waitframe()
{
	wait 0.05;
}

doFinalKillCamFX( camTime )
{
	if ( isDefined( level.doingFinalKillcamFx ) )
		return;

	level.doingFinalKillcamFx = true;
	
	intoSlowMoTime = camTime;
	if ( intoSlowMoTime > 1.0 )
	{
		intoSlowMoTime = 1.0;
		wait( camTime - 1.0 );
	}

	wait( intoSlowMoTime - .05 );

	level.doingFinalKillcamFx = undefined;
}

