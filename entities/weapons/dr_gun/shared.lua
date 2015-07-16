
if (SERVER) then
	resource.AddFile("deathrunexcl/crosshair.png");
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
	
	SWEP.Slot				= 1;
	SWEP.SlotPos			= 1;
end

SWEP.Primary.Automatic		= true

SWEP.Author			= "_NewBee";
SWEP.Contact		= "";
SWEP.Purpose		= "";
SWEP.Instructions	= "";
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.PrintName            = "AK-47"
SWEP.Category		= "_NewBee";

SWEP.ViewModel = "models/weapons/v_rif_ak47.mdl";
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl";

SWEP.Sound			= Sound( "Weapon_AK47.Single" );
SWEP.Recoil			= 1.2;
SWEP.Damage			= 40;
SWEP.NumShots		= 1;
SWEP.Cone			= 0.02;
SWEP.IronCone		= 0.01;
SWEP.MaxCone		= 0.05;
SWEP.ShootConeAdd	= 0.005;
SWEP.CrouchConeMul 	= 0.8;
SWEP.Primary.ClipSize		= 27;
SWEP.Delay			= 0.11;
SWEP.DefaultClip	= 27;
SWEP.Primary.Ammo			= "SMG1";
SWEP.ReloadSequenceTime = 1.85;

SWEP.OriginsPos = Vector (3.7641, -4.5592, 1.8507);
SWEP.OriginsAng = Vector (0.9193, -0.2032, 0.9484);

SWEP.AimPos = Vector (6.1008, -5.4248, 2.434)
SWEP.AimAng = Vector (1.62, -0.0844, -0.8102)

SWEP.RunPos =  Vector (-2.4782, -12.7939, 0.6039);
SWEP.RunAng = Vector (-37.786, -77.9068, 37.9085);

SWEP.IronCycleSpeed = 20;

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

function SWEP:SetupDataTables( )
	self:DTVar( "Int", 0, "Mode" );
	self:DTVar( "Float", 0, "LastShoot" );
end

function SWEP:Initialize()
	if IsValid(self) and self.SetWeaponHoldType then 
		self:SetWeaponHoldType("ar2");
		self:SetDTInt(0, 0);
		self:SetDTInt(0, 0);
	end
end

function SWEP:Deploy()
	if (self.Owner:Team() != TEAM_GOODIE and self.Owner:Team() != TEAM_BADDIE ) then return false end

	self:SendWeaponAnim(ACT_VM_DRAW);
	self:SetNextPrimaryFire(CurTime() + 1);
	
	if self.OldAmmo then
		self:SetClip1(self.OldAmmo);
	end
	
	timer.Destroy(self.Owner:SteamID().."ReloadTimer")
	
	return true;
end

function SWEP:Holster()
	self.OldAmmo = self:Clip1();
	self:SetClip1(1);
	
	self:SetDTInt(0, 0);
	
	if self.Owner.SteamID and self.Owner:SteamID() then
	timer.Destroy(self.Owner:SteamID().."ReloadTimer")
	end
	
	if SERVER then
		self.Owner:SetFOV(0,0.6)
	end
	return true;
end

SWEP.NextReload = CurTime();
function SWEP:Reload()	
	if self.NextReload > CurTime() or CLIENT or self:GetDTInt(0) == 2 then return end
	
	self.NextReload = CurTime()+4;
	
	self:SendWeaponAnim(ACT_VM_RELOAD);
	self.Owner:SetAnimation(PLAYER_RELOAD);
	
	if SERVER then
		self.Owner:SetFOV(0,0.6)
	end
	
	local clip = self:Clip1();
	local dur;
	if clip > 0 then
		self.Rechamber = false;
		self:SetClip1(1);
		
		dur = self.Owner:GetViewModel():SequenceDuration();
	else
		self.Rechamber = true;
		
		dur = self.ReloadSequenceTime or self.Owner:GetViewModel():SequenceDuration();
	end

	self:SetNextPrimaryFire(CurTime()+dur);
	timer.Create(self.Owner:SteamID().."ReloadTimer", dur,1,function()
		if not self.Owner or not IsValid(self.Owner) then return end
		local clip = self:Clip1();
		
		if not self.Rechamber then
			self:SetClip1(self.Primary.ClipSize+1);
		else
			self:SetClip1(self.Primary.ClipSize);
			self:SendWeaponAnim(ACT_VM_DRAW);
			self:SetNextPrimaryFire(CurTime()+1);	
		end	
	end)
		
	self:SetDTInt(0, 0)
end

SWEP.AddCone = 0;
SWEP.LastShoot = CurTime();
SWEP.oldMul = 1;
function SWEP:Think()	
	if not SERVER then return end;
	
	local mul = 1;
	if self.Owner:Crouching() then
		mul = self.CrouchConeMul;
	elseif self.Owner:GetVelocity():Length() > 150 then
		mul = mul+1
	end
	self.oldMul = Lerp(0.5,self.oldMul,mul);
	
	if self.LastShoot+0.2 < CurTime() then 
		self.AddCone = self.AddCone-(self.ShootConeAdd/5);
		if self.AddCone < 0 then
			self.AddCone=0;
		end
	end
	
	if self:GetDTInt(0) == 1 then
		self:SetDTFloat(1, math.Clamp((self.IronCone+self.AddCone)*self.oldMul, 0.002, 0.12));
	elseif self:GetDTInt(0) == 2 then
		self:SetDTFloat(1, math.Clamp((self.Cone+self.AddCone+0.5)*self.oldMul, 0.002, 0.12));
	else
		self:SetDTFloat(1, math.Clamp((self.Cone+self.AddCone)*self.oldMul, 0.002, 0.12));
	end
	
	if not self.Owner.FOVRate or not type(self.Owner.FOVRate) == "number" then 
		self.Owner.FOVRate = 0; 
	end
		
	local dt = self:GetDTInt(0);
		
	if dt == 1 then
		self.Owner.FOVRate = 0; --(GetConVarNumber("fov_desired")-20); garry broke FOV
	else
		self.Owner.FOVRate = 0;
	end
	self.Owner:SetFOV(self.Owner.FOVRate,0.5)

	if self.Owner:KeyDown(IN_SPEED) and self.Owner:OnGround() and self.Owner:GetVelocity():Length() > self.Owner:GetRunSpeed()-100 then
		self:SetDTInt(0, 2)
		if SERVER then
			self.Owner:DrawViewModel(true)
		end
		return;
	elseif self:GetDTInt(0) > 1 then
		self:SetDTInt(0,0);
		return;
	end
end

function SWEP:PrimaryAttack()

	local ct = CurTime();

	if self:GetDTInt(0) > 1 then
		self:SetNextPrimaryFire(ct+self.Delay);
		return;
	elseif self:Clip1() <= 0 then
		self:SetNextPrimaryFire(ct+self.Delay);
		self:EmitSound( "Weapon_Pistol.Empty" )
		return;
	end
	
	self:SetNextPrimaryFire(ct+self.Delay);
	
	if self:GetDTInt(0) ~= 1 then
		self:CSShootBullet( self.Damage, self.Recoil * 1.5, self.NumShots, self:GetDTFloat(1))
	else
		self:CSShootBullet( self.Damage, self.Recoil * 0.75, self.NumShots, self:GetDTFloat(1))
	end
	
	self.AddCone = math.Clamp(self.AddCone+self.ShootConeAdd,0,self.MaxCone)
	self.LastShoot = ct;
	
	if SERVER then
		self.Owner:EmitSound(self.Sound, 100, math.random(95, 105))
	end

	self:TakePrimaryAmmo(1);
end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )
	numbul 	= numbul 	or 1;
	cone 	= cone 		or 0.01;
		
	local bullet = {}
	bullet.Num 		= numbul;
	bullet.Src 		= self.Owner:GetShootPos();
	bullet.Dir 		= ( self.Owner:EyeAngles() + self.Owner:GetPunchAngle() ):Forward();
	bullet.Spread 	= Vector( cone, cone, 0 );
	bullet.Tracer	= 4;
	bullet.Force	= self.Damage;
	bullet.Damage	= self.Damage;
	
	self.Owner:FireBullets(bullet);
	--if self:GetDTInt(0,0) != 1 then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	--end
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self.Owner:MuzzleFlash();
	
	
	if ( CLIENT and IsFirstTimePredicted() ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - (recoil * 1 * 0.3)
		eyeang.yaw = eyeang.yaw - (recoil * math.random(-1, 1) * 0.3)
		self.Owner:SetEyeAngles( eyeang )
	
	end
end

local CurMove = -2;
local AmntToMove = 0.4;
local MoveCycle = 0;
local Ironsights_Time = 0.1;
local CurShakeA = 0.03;
local CurShakeB = 0.03;
local randomdir = 0;
local randomdir2 = 0;
local timetorandom = 0;
local BlendPos = Vector(0, 0, 0);
local BlendAng = Vector(0, 0, 0);
local ApproachRate = 0.2;
local RollModSprint = 0;

function SWEP:GetViewModelPosition(pos, ang)
	local t = FrameTime();
	local dt = self:GetDTInt(0);
	if dt == 2 then
		TargetPos = self.RunPos
		TargetAng = self.RunAng
	elseif dt == 1 then
		TargetPos = self.AimPos
		TargetAng = self.AimAng
	else
		TargetPos = self.OriginsPos
		TargetAng = self.OriginsAng
	end
	
	if self:GetDTInt(0) == 1 then
		ApproachRate = t * 15
	else
		ApproachRate = t * 10
	end
	
	BlendPos = LerpVector(ApproachRate, BlendPos, TargetPos)
	BlendAng = LerpVector(ApproachRate, BlendAng, TargetAng)
		
	CurShakeA = math.Approach(CurShakeA, randomdir, 0.01)
	CurShakeB = math.Approach(CurShakeB, randomdir2, 0.01)
		
	if CurTime() > timetorandom then
		randomdir = math.Rand(-0.1, 0.1)
		randomdir2 = math.Rand(-0.1, 0.1)
		timetorandom = CurTime() + 0.2
	end
	
	if dt == 1 then -- stop the Sway when we are in ironsights
		self.SwayScale 	= 0.1
		self.BobScale 	= 0
	elseif dt == 2  then
		self.SwayScale 	= 2
		self.BobScale 	= 2
	else
		self.SwayScale 	= 1.5
		self.BobScale 	= 0.4
	end

	if CurMove == -2 then
		MoveCycle = 1
	elseif CurMove == 2 then
		MoveCycle = 2
	end
	
	if MoveCycle == 1 then
		CurMove = math.Approach(CurMove, 2, 0.11 - CurMove * 0.05)
	elseif MoveCycle == 2 then
		CurMove = math.Approach(CurMove, -2, 0.11 - CurMove * 0.05)
	end

	if self.AimAng then
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		BlendAng.x + CurShakeB * self.BobScale )
		ang:RotateAroundAxis( ang:Up(), 		BlendAng.y + CurShakeA * self.BobScale)
		ang:RotateAroundAxis( ang:Forward(), 	BlendAng.z + CurShakeA * self.BobScale)
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()	
	
	pos = pos + BlendPos.x * Right 
	pos = pos + BlendPos.y * Forward
	pos = pos + BlendPos.z * Up
	
	return pos, ang
end

if CLIENT then
	local matCrosshair = Material("deathrunexcl/crosshair.png");
	function SWEP:FireAnimationEvent(pos, ang, ev)
		if ev == 5001 then
			if not self.Owner:ShouldDrawLocalPlayer() then
				local vm = self.Owner:GetViewModel();
				local muz = vm:GetAttachment("1");
				
				if not self.Em then
					self.Em = ParticleEmitter(muz.Pos);
				end
				
				local par = self.Em:Add("particle/smokesprites_000" .. math.random(1, 9), muz.Pos);
				par:SetStartSize(math.random(0.5, 1));
				par:SetStartAlpha(120);
				par:SetEndAlpha(0);
				par:SetEndSize(math.random(5, 5.5));
				par:SetDieTime(1.5 + math.Rand(-0.3, 0.3));
				par:SetRoll(math.Rand(0.2, 1));
				par:SetRollDelta(0.8 + math.Rand(-0.3, 0.3));
				par:SetColor(120,120,120,255);
				par:SetGravity(Vector(0, 0, 5));
				local mup = (muz.Ang:Up()*-20);
				par:SetVelocity(Vector(0, 0,7)+Vector(mup.x,mup.y,0));
				
				local par = self.Em:Add("sprites/heatwave", muz.Pos);
				par:SetStartSize(8);
				par:SetEndSize(0);
				par:SetDieTime(0.3);
				par:SetGravity(Vector(0, 0, 2));
				par:SetVelocity(Vector(0, 0, 20));				
			end
		end
	end

	function SWEP:AdjustMouseSensitivity()
		if self:GetDTInt(0) == 1 then
			return 0.8;
		else
			return 1
		end
	end
	
	local gap = 5
	local gap2 = 0
	local CurAlpha_Weapon = 255
	local x2 = (ScrW() - 1024) / 2
	local y2 = (ScrH() - 1024) / 2
	local x3 = ScrW() - x2
	local y3 = ScrH() - y2
	function SWEP:DrawHUD()
		local FT = FrameTime();

		x, y = ScrW() / 2, ScrH() / 2;
		
		local scale = (10 * self.Cone)* (2 - math.Clamp( (CurTime() - self:GetDTFloat(1)) * 5, 0.0, 1.0 ))
		
		if self:GetDTInt(0) > 0 then
			CurAlpha_Weapon = math.Approach(CurAlpha_Weapon, 0, FT / 0.0017)
		else
			CurAlpha_Weapon = math.Approach(CurAlpha_Weapon, 230, FT / 0.001)
		end
		
		gap = math.Approach(gap, 50 * ((10 / (self.Owner:GetFOV() / 90)) * self:GetDTFloat(1)), 1.5 + gap * 0.1)
		
		local pos=LocalPlayer():GetEyeTrace().HitPos:ToScreen()
		x,y=pos.x,pos.y

		size=18

		-- Draw the crosshair
		surface.SetDrawColor( ES.Color["#FFFFFFEE"] )

		surface.DrawRect( x - gap/2 - size	, y-1, size, 2 )
		surface.DrawRect( x + gap/2					, y-1, size, 2 )

		surface.DrawRect( x-1, y - gap/2 - size	, 2, size)
		surface.DrawRect( x-1, y + gap/2				, 2, size)
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end

	local dt = self:GetDTInt(0);
	
	if dt == 2 then
		return;
	elseif dt == 1 then
		self:SetDTInt(0,0);	
		self.Owner:SetFOV(0,0.6)

	else
		self:SetDTInt(0,1);	
		self.Owner:SetFOV(GetConVarNumber("fov_desired")-17,0.3)

	end
end

function SWEP:OnRestore()
end
