#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;


/*
	This is all for PreCache + Ensuring the Title and Emblems appear.
*/

init_color_stuff()
{
	level.antiga_colors = [];
	level.antiga_colors["colorID"] = [];
	addcolor_killcam("(0,0,0)");
	addcolor_killcam("(1,0,0)");
	addcolor_killcam("(0,1,0)");
	addcolor_killcam("(0,0,1)");
	addcolor_killcam("(0,1,1)");
	addcolor_killcam("(1,1,0)");
	addcolor_killcam("(1,0,1)");
	addcolor_killcam("(1,1,1)");
}

addcolor_killcam(colorID)
{
	F = level.antiga_colors["colorID"].size;
	level.antiga_colors["colorID"][F] = colorID;
}

init_title_stuff()
{
	level.antiga_titles = [];
	level.antiga_titles["titleID"] = [];
	addtitle_killcam("weapon_missing_image"); //Clear
	/* Start of Gradient Styles */
	addtitle_killcam("gradient");
	addtitle_killcam("gradient_bottom");
	addtitle_killcam("gradient_center");
	addtitle_killcam("gradient_fadein");
	addtitle_killcam("gradient_left");
	addtitle_killcam("gradient_top");
	/* End of Gradient Styles */
	addtitle_killcam("black");
	addtitle_killcam("caulk_shadow"); //Corrupt Image
}

addtitle_killcam(titleID)
{
	F = level.antiga_titles["titleID"].size;
	level.antiga_titles["titleID"][F] = titleID;
}

init_emblem_stuff()
{
	level.antiga_emblems = [];
	level.antiga_emblems["emblemID"] = [];
    addemblem_killcam("weapon_missing_image"); //Clear
	for(i=1;i<11;i++)
	{
		addemblem_killcam(tableLookup("mp/rankIconTable.csv",0,0,i+1)); //Prestige Icons
	}
	/* Start of Perk Icons */
	addemblem_killcam("specialty_locked");
	addemblem_killcam("specialty_specialgrenade");
	addemblem_killcam("specialty_weapon_bouncing_betty");
	addemblem_killcam("specialty_fraggrenade");
	addemblem_killcam("specialty_extraammo");
	addemblem_killcam("specialty_detectexplosive");
	addemblem_killcam("specialty_weapon_flamethrower");
	addemblem_killcam("specialty_weapon_bazooka");
	addemblem_killcam("specialty_weapon_satchel_charge");
	addemblem_killcam("specialty_bulletdamage");
	addemblem_killcam("specialty_armorvest");
	addemblem_killcam("specialty_fastreload");
	addemblem_killcam("specialty_rof");
	addemblem_killcam("specialty_twoprimaries");
	addemblem_killcam("specialty_gpsjammer");	
	addemblem_killcam("specialty_explosivedamage");
	addemblem_killcam("specialty_flakjacket");
	addemblem_killcam("specialty_shades");
	addemblem_killcam("specialty_gas_mask");
	addemblem_killcam("specialty_longersprint");
	addemblem_killcam("specialty_bulletaccuracy");
	addemblem_killcam("specialty_pistoldeath");
	addemblem_killcam("specialty_grenadepulldeath");
	addemblem_killcam("specialty_bulletpenetration");
	addemblem_killcam("specialty_holdbreath");
	addemblem_killcam("specialty_quieter");
	addemblem_killcam("specialty_fireproof");
	addemblem_killcam("specialty_reconnaissance");
	addemblem_killcam("specialty_pin_back");
	addemblem_killcam("specialty_water_cooled");
	addemblem_killcam("specialty_greased_barrings");
	addemblem_killcam("specialty_ordinance");
	addemblem_killcam("specialty_boost");
	addemblem_killcam("specialty_leadfoot");
	/* End of Perk Icons */
	addemblem_killcam("map_squad_command");
	addemblem_killcam("hud_momentum");
	addemblem_killcam("hud_momentum_bonus");
	addemblem_killcam("hud_momentum_bonus_detail");
	addemblem_killcam("hud_momentum_blitzkrieg");
	addemblem_killcam("hud_momentum_notification_bonus");
	addemblem_killcam("hud_momentum_notification_blitzkrieg");
	addemblem_killcam("hudicon_japanese_war");
	addemblem_killcam("hudicon_japanese_war_grey");
	addemblem_killcam("hudicon_german_war");
	addemblem_killcam("hudicon_german_war_grey");
	addemblem_killcam("hudicon_russian_war");
	addemblem_killcam("hudicon_russian_war_grey");
	addemblem_killcam("hudicon_american_war");
	addemblem_killcam("hudicon_american_war_grey");
	addemblem_killcam("waypoint_bomb");
	addemblem_killcam("hud_suitcase_bomb");
	addemblem_killcam("voice_on");
	addemblem_killcam("voice_off");
	addemblem_killcam("hudstopwatch");
	addemblem_killcam("killiconcar");
	addemblem_killcam("killiconcrush");
	addemblem_killcam("killicondied");
	addemblem_killcam("killiconfalling");
	addemblem_killcam("killiconheadshot");
	addemblem_killcam("killiconimpact");
	addemblem_killcam("killiconmelee");
	addemblem_killcam("hud_squad_symbol");
	addemblem_killcam("hud_status_connecting");
	addemblem_killcam("hud_status_dead");
	addemblem_killcam("hud_teamcaret");
	addemblem_killcam("damage_feedback");
	addemblem_killcam("damage_feedback_j");
	addemblem_killcam("compassping_friendly_mp");
	addemblem_killcam("compassping_squad_mp");
	addemblem_killcam("field_radio");
}

addemblem_killcam(emblemID)
{
	F = level.antiga_emblems["emblemID"].size;
	level.antiga_emblems["emblemID"][F] = emblemID;
}

/*
	Toggles for Killcam Timer, Title and Emblems, Gradient Colour, Emblem Flashing, and Gradient Flashing
*/

toggleKCTimer()
{
	if(!self.kcTimer)
	{
		self.kcTimer = true;
		self iPrintLn("Killcam Timer: [^2On^7]");
	} else {
		self.kcTimer = false;
		self iPrintLn("Killcam Timer: [^1Off^7]");
	}
}

toggleTitleEmblem()
{
	if(!self.CustomKCEM)
	{
		self.CustomKCEM = true;
		self iPrintLn("Title and Emblems: [^2On^7]");
	} else {
		self.CustomKCEM = false;
		self iPrintLn("Title and Emblems: [^1Off^7]");
	}
}

toggleGrad()
{
	if(!self.coloredgradientBox)
	{
		self.coloredgradientBox = true;
		self iPrintLn("Colored Gradient: [^2On^7]");
	} else {
		self.coloredgradientBox = false;
		self iPrintLn("Colored Gradient: [^1Off^7]");
	}
}

toggleEmbFlash()
{
	if(!self.breathingEmb)
	{
		self.breathingEmb = true;
		self iPrintLn("Emblem Flash: [^2On^7]");
	} else {
		self.breathingEmb = false;
		self iPrintLn("Emblem Flash: [^1Off^7]");
		self.customEmb notify("endEmbBre");
	}
}

toggleGradientFlash()
{
	if(!self.flashingGrad)
	{
		self.flashingGrad = true;
		self iPrintLn("Gradient Flash: [^2On^7]");
	}
	else
	{
		self.flashingGrad = false;
		self iPrintLn("Gradient Flash: [^1Off^7]");
		self.coloredgradientBoxE notify("end_gradFlash");
		self.coloredgradientBoxE.color = self.pers["gradColour"];
	}
}

/*
	Animated Title and Emblem Functions
*/

doFlashingGrad()
{
	self endon("end_gradFlash");
	self endon("disconnect");
	gradElem = self;
	r = randomInt(255);
	r_bigger = true;
	g = randomInt(255);
	g_bigger = false;
	b = randomInt(255);
	b_bigger = true;
	for(;;)
	{
		if(r_bigger==true){
			r+=10;
			if(r>254){
				r_bigger = false;}}
		else{
			r-=10;
			if(r<2){
				r_bigger = true;}}
		if(g_bigger==true){
			g+=10;
			if(g>254){
				g_bigger = false;}}
		else{
			g-=10;
			if(g<2){
				g_bigger = true;}}
		if(b_bigger==true){
			b+=10;
			if(b>254){
				b_bigger = false;}}
		else{
			b-=10;
			if(b<2){
				b_bigger = true;}}
		gradElem.color = ((r/255),(g/255),(b/255));
		wait 0.01;
	}
}

doBreathingEmb()
{
	self endon("endEmbBre");
	self endon("disconnect");
	embBre = self;
	a = randomInt(255);
	a_bigger = true;
	for(;;)
	{
		if(a_bigger==true){
			a+=10;
			if(a>255){
				a_bigger = false;}}
		else{
			a-=10;
			if(a<1){
				a_bigger = true;}}
		embBre.alpha = (a/255);
		wait 0.01;
	}
}

/*
	Setting this set's the title and emblem
*/

updateGradColour(colorID)
{
	self.pers["gradColour"] = colorID;
	self iPrintLn("Gradient Colour Set To: ^2" +self.pers["gradColour"]);
}

emblemChoice(myEmblem)
{
	self.pers["myEmblemChoice"] = myEmblem;
    self iPrintLn("Killcam Emblem Set To: ^2" +self.pers["myEmblemChoice"]);
}

titleChoice(myTitle)
{
    self.pers["myTitleChoice"] = myTitle;
    self iPrintLn("Killcam Title Set To: ^2" +self.pers["myTitleChoice"]);
}