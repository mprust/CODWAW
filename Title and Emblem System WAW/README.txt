/*
    Thanks for Downloading my custom title and emblem system in COD WAW!
    
    Credits: 
        Matrix for Final Killcam (OG MOD)
        Myself for implementing and creating this system.

    Any bugs that occur, please let me know! However, if you choose to make any edits yourself, please use the proper credits when releasing.

    | ------------------ INSTRUCTIONS: ------------------ |

	Extract both files into the gametypes folder, you may make a backup of your _finalkills.gsc file before replacing it with mine.

	Include these @ the top of your file to avoid errors:
		#include maps\mp\gametypes\_emblemSupport;

	In _rank or any other initiating file, do this under init
	level thread init_title_stuff();
	level thread init_emblem_stuff();
	level thread init_color_stuff();
	for(i=0;i<10;i++)
	{
		precacheShader(tableLookup("mp/rankIconTable.csv",0,0,i+1));
	}
	for(i=0;i<level.antiga_titles["titleID"].size;i++)
	{
		precacheShader(level.antiga_titles["titleID"][i]);
	}
	for(i=0;i<level.antiga_emblems["emblemID"].size;i++)
	{
		precacheShader(level.antiga_emblems["emblemID"][i]);
	}
	for(i=0;i<level.antiga_colors["colorID"].size;i++)
	{
		precacheShader(level.antiga_colors["colorID"][i]);
	}

	OnPlayerConnect or OnPlayerSpawn, please parse these variables:
		self.breathingEmb = false;
		self.coloredgradientBox = false;
		self.CustomKCEM = false;
		self.kcTimer = false;
		self.flashingGrad = false;

	How do I use this in a menu?

	// Example for phen6m's menu \\
	self addOption("Main Menu","Title Emblem Menu",2,::drawMenu,"Title Emblem Menu",0);
	self addMenu("Title Emblem Menu","Main Menu",0);
	self addOption("Title Emblem Menu","Toggle Custom Title/Emblem",0,::toggleTitleEmblem); //toggles the use of title and emblem in killcam
	self addOption("Title Emblem Menu","Toggle Killcam Timer",0,::toggleKCTimer); //toggles killcam timer
	self addOption("Title Emblem Menu","Toggle Breathing Emblem Animation",0,::toggleEmbFlash); //toggles breathing emblem animation
	self addOption("Title Emblem Menu","Toggle Gradient Colours",0,::toggleGrad); //toggles gradient colors
	self addOption("Title Emblem Menu","Toggle Flashing Gradient Colours",0,::toggleGradientFlash); //toggles flashing gradient colors (title)
	self addOption("Title Emblem Menu","Gradient Color Menu",2,::drawMenu,"Gradient Color Menu",0);
	self addMenu("Gradient Color Menu","Title Emblem Menu",0);
	for(i=0;i<level.antiga_colors["colorID"].size;i++)
	{
		self addOption("Gradient Color Menu",level.antiga_colors["colorID"][i],0,::updateGradColour,level.antiga_colors["colorID"][i]); //selects and lists colors for gradients
	}	
	self addOption("Title Emblem Menu","Title Selection Menu",2,::drawMenu,"Title Selection Menu",0);
	self addMenu("Title Selection Menu","Title Emblem Menu",0);
	for(i=0;i<level.antiga_titles["titleID"].size;i++)
	{
		self addOption("Title Selection Menu",level.antiga_titles["titleID"][i],0,::titleChoice,level.antiga_titles["titleID"][i]); //selects title with name
	}
	self addOption("Title Emblem Menu","Emblem Selection Menu",2,::drawMenu,"Emblem Selection Menu",0);
	self addMenu("Emblem Selection Menu","Title Emblem Menu",0);
	for(i=0;i<level.antiga_emblems["emblemID"].size;i++)
	{
		self addOption("Emblem Selection Menu",level.antiga_emblems["emblemID"][i],0,::emblemChoice,level.antiga_emblems["emblemID"][i]); //selects emblem
	}

	You can list out the images + colours too within your menu via images, but your menu must have a proper overflow support fix for it.
		- I will not assist with this (unfortunately).
	
	Titles/Emblem/Color Gradient Selection saves through rounds, you can also do that for the toggles, but I did not do that.
*/