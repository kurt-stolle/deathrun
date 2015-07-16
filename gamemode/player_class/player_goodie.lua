DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName = "Goodie"
PLAYER.WalkSpeed 			= 250;
PLAYER.RunSpeed				= 250;
PLAYER.CrouchedWalkSpeed 	= (85/250)
PLAYER.JumpPower 			= 280
PLAYER.CanUseFlashlight 	= true;
PLAYER.TeammateNoCollide	= false;		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= false;

local count = 1;
local models = {
	Model("models/player/group01/male_09.mdl"),
	Model("models/player/group01/male_08.mdl"),
	Model("models/player/group01/male_07.mdl"),
	Model("models/player/group01/male_06.mdl"),
	Model("models/player/group01/male_05.mdl"),
	Model("models/player/group01/male_04.mdl"),
	Model("models/player/group01/male_02.mdl"),
	Model("models/player/group01/female_06.mdl"),
	Model("models/player/group01/female_04.mdl"),
	Model("models/player/group01/female_02.mdl"),
	Model("models/player/group01/female_01.mdl"),
}
function PLAYER:SelectModel()
	self.Player:ESSetModelToActive()
	self.Player:SetPlayerColor(Vector(0,1,0));
end
function PLAYER:Loadout()
	self.Player:RemoveAllAmmo();
	self.Player:Give(self.Player:ESGetMeleeWeaponClass());
	self.Player:Give( "weapon_nothing" );
	self.Player:SelectWeapon("weapon_nothing");

	self.Player:SetupHull()
end
player_manager.RegisterClass( "player_goodie", PLAYER, "player_default" )
