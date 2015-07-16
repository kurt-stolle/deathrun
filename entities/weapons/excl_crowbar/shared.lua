
if SERVER then
   AddCSLuaFile( "shared.lua" )
   SWEP.Weight          = 5;
   SWEP.AutoSwitchTo    = false;
   SWEP.AutoSwitchFrom     = false;
   
end

SWEP.HoldType			= "melee"

if CLIENT then

   SWEP.DrawAmmo        = true;
   SWEP.DrawCrosshair      = true;
   SWEP.ViewModelFlip      = false;
   SWEP.DrawWeaponInfoBox  = false;

   SWEP.Slot          = 0;
   SWEP.SlotPos         = 0;

   SWEP.ViewModelFOV = 54
end

SWEP.Author       = "Excl";
SWEP.Contact      = "";
SWEP.Purpose      = "";
SWEP.Instructions = "";
SWEP.Spawnable       = false
SWEP.AdminSpawnable     = false
SWEP.PrintName            = "Melee"
SWEP.Category     = "Excl";

SWEP.ViewModel			= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"
SWEP.Weight			= 5
SWEP.DrawCrosshair		= false
SWEP.ViewModelFlip		= false
SWEP.Primary.Damage = 20
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay = 0.5
SWEP.Primary.Ammo		= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.Delay = 5
SWEP.HoldType = "melee"

local sound_single = Sound("Weapon_Crowbar.Single")
function SWEP:Initialize()
   self:SetWeaponHoldType(self.HoldType)
end
function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not IsValid(self.Owner) then return end

   if self.Owner.LagCompensation and SERVER then
      self.Owner:LagCompensation(true);
   end

   self.Owner:SetAnimation( PLAYER_ATTACK1 )

   local spos = self.Owner:GetShootPos()
   local sdest = spos + (self.Owner:GetAimVector() * 70)

   local tr_main = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
   local hitEnt = tr_main.Entity

   self.Weapon:EmitSound(sound_single)

   if IsValid(hitEnt) or tr_main.HitWorld then
      self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

      if not (CLIENT and (not IsFirstTimePredicted())) then
         local edata = EffectData()
         edata:SetStart(spos)
         edata:SetOrigin(tr_main.HitPos)
         edata:SetNormal(tr_main.Normal)
         edata:SetEntity(hitEnt)

         if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
            util.Effect("BloodImpact", edata)
            self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=0});
         else
            util.Effect("Impact", edata)
         end
      end
   else
      self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
   end


   if CLIENT then
      -- used to be some shit here
   else
      local tr_all = nil
      tr_all = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner})
      
      if hitEnt and hitEnt:IsValid() then
         local dmg = DamageInfo()
         dmg:SetDamage(self.Primary.Damage)
         dmg:SetAttacker(self.Owner)
         dmg:SetInflictor(self.Weapon)
         dmg:SetDamageForce(self.Owner:GetAimVector() * 1500)
         dmg:SetDamagePosition(self.Owner:GetPos())
         dmg:SetDamageType(DMG_CLUB)

         hitEnt:DispatchTraceAttack(dmg, spos + (self.Owner:GetAimVector() * 3), sdest)      
      end
   end

   if self.Owner.LagCompensation and SERVER then
      self.Owner:LagCompensation(false)
   end
end

function SWEP:SecondaryAttack()
end

function SWEP:GetClass()
	return "excl_crowbar"
end

function SWEP:OnDrop()
end
