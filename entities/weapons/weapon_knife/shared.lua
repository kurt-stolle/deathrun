
if (SERVER) then

	AddCSLuaFile( "shared.lua" );
	SWEP.Weight				= 5;
	SWEP.AutoSwitchTo		= false;
	SWEP.AutoSwitchFrom		= false;
end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true;
	SWEP.DrawCrosshair		= false;
	SWEP.ViewModelFOV		= 70;
	SWEP.ViewModelFlip		= true;
	SWEP.CSMuzzleFlashes	= true;
	SWEP.DrawWeaponInfoBox  = true;
	
	SWEP.Slot				= 0;
	SWEP.SlotPos			= 1;
end

SWEP.Primary.Automatic		= true

SWEP.Author			= "_NewBee";
SWEP.Contact		= "";
SWEP.Purpose		= "";
SWEP.Instructions	= "";
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.PrintName            = "Knife"
SWEP.Category		= "_NewBee";



SWEP.ViewModel = "models/weapons/v_knife_t.mdl";
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"; 
-- for a pickaxe in ruben's and hammerperson's MC map we can override this in a map file



SWEP.Primary.ClipSize		= -1;
SWEP.Primary.DefaultClip	= -1;
SWEP.Primary.Automatic	= false;
SWEP.Primary.Ammo			= "none";

SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none";

SWEP.OriginsPos = Vector (3.7641, -4.5592, 1.8507);
SWEP.OriginsAng = Vector (0.9193, -0.2032, 0.9484);

SWEP.AimPos = Vector (6.1008, -5.4248, 2.434)
SWEP.AimAng = Vector (1.62, -0.0844, -0.8102)

SWEP.RunPos =  Vector (-2.4782, -12.7939, 0.6039);
SWEP.RunAng = Vector (-37.786, -77.9068, 37.9085);

function SWEP:Initialize()
	if IsValid(self) and self.SetWeaponHoldType then 
		self:SetWeaponHoldType("knife");
	end
end

function SWEP:Deploy()
	if (self.Owner:Team() != TEAM_GOODIE and self.Owner:Team() != TEAM_BADDIE ) then 
		return false
	end
	
	return true;
end

function SWEP:Holster()
	return true;
end

function SWEP:Reload()	
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:OnRestore()
end
