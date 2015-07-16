-- cl_help.lua
local help; -- not a help anymore....
local function ToggleHelp()
	if help and help:IsValid() then help:Remove() return end

	help = vgui.Create("esFrame");
	help:SetSize(400,205);
	help:Center()
	help:SetTitle("Settings & Actions")
	help.OnClose = function()
		help:Remove();
	end

	local chbox = help:Add("esToggleButton");
	chbox:SetTall(20)
	chbox:Dock(TOP)
	chbox:DockMargin(20,20,20,0)
	chbox:SetText("Spectator mode")
	chbox.DoClick = function(self)
		if self:GetChecked() then
			LocalPlayer():ConCommand("dr_alwaysspectate 1")
			RunConsoleCommand("dr_doselectspec");
		else
			LocalPlayer():ConCommand("dr_alwaysspectate 0")
			RunConsoleCommand("dr_doselectplay");
		end
	end
	chbox:SetChecked(GetConVar("dr_alwaysspectate"):GetBool());


	local vltr = vgui.Create("esButton",help);
	vltr:SetText("Volunteer baddie");
	vltr.DoClick = function()
		RunConsoleCommand("dr_volunteer_baddie");
		vltr:SetDisabled(true)
	end
	vltr:SetTall(30)
	vltr:Dock(TOP)
	vltr:DockMargin(20,20,20,0)

	help:MakePopup();
end
net.Receive("OpenHelp",ToggleHelp);
