-- weapons
local CSSWeps = {"weapon_ak47",
"weapon_aug",
"weapon_awp",
"weapon_c4",
"weapon_deagle",
"weapon_elite",
"weapon_famas",
"weapon_fiveseven",
"weapon_g3sg1",
"weapon_galil",
"weapon_glock",
"weapon_m249",
"weapon_m3",
"weapon_m4a1",
"weapon_mac10",
"weapon_mp5navy",
"weapon_p228",
"weapon_p90",
"weapon_scout",
"weapon_sg550",
"weapon_sg552",
"weapon_tmp",
"weapon_ump45",
"weapon_usp",
"weapon_xm1014",
};
hook.Add("Initialize","drInitCSSWeps",function()
	for _,v in pairs(CSSWeps)do
		weapons.Register( {Base = "dr_gun", GetClass = function() return "dr_gun" end}, string.lower(v), false);
	end
	weapons.Register( {Base = "weapon_knife"}, "weapon_knife", false);
	weapons.Register( {Base = "weapon_grenade"}, "weapon_hegrenade", false);
	weapons.Register( {Base = "weapon_grenade"}, "weapon_smokegrenade", false);
	weapons.Register( {Base = "weapon_grenade"}, "weapon_flashbang", false);
end);

