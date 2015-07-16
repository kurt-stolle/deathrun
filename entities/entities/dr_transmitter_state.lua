-- ####################################################################################
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     CASUAL BANANAS CONFIDENTIAL                                                ##
-- ##                                                                                ##
-- ##     __________________________                                                 ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Copyright 2014 (c) Casual Bananas                                          ##
-- ##     All Rights Reserved.                                                       ##
-- ##                                                                                ##
-- ##     NOTICE:  All information contained herein is, and remains                  ##
-- ##     the property of Casual Bananas. The intellectual and technical             ##
-- ##     concepts contained herein are proprietary to Casual Bananas and may be     ##
-- ##     covered by U.S. and Foreign Patents, patents in process, and are           ##
-- ##     protected by trade secret or copyright law.                                ##
-- ##     Dissemination of this information or reproduction of this material         ##
-- ##     is strictly forbidden unless prior written permission is obtained          ##
-- ##     from Casual Bananas                                                        ##
-- ##                                                                                ##
-- ##     _________________________                                                  ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Casual Bananas is registered with the "Kamer van Koophandel" (Dutch        ##
-- ##     chamber of commerce) in The Netherlands.                                   ##
-- ##                                                                                ##
-- ##     Company (KVK) number     : 59449837                                        ##
-- ##     Email                    : info@casualbananas.com                          ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ####################################################################################

AddCSLuaFile();

ENT.Base 				="base_point"
ENT.Type				="point"
ENT.PrintName 			="DR State Transmitter"

function ENT:Initialize()
	DR.TRANSMITTER = self;
	DR:DebugPrint("Setup State Transmitter!");
end
function ENT:Think()
	if not IsValid(DR.TRANSMITTER) and IsValid(self) then // there is no registered transmitter and yet we're here. What's going on? Let's assume that we are the transmitter that is being looked for.
		DR.TRANSMITTER = self;
	end
end
function ENT:SetupDataTables()
	self:NetworkVar( "Int",	0, "DRState" );
	self:NetworkVar( "Int",	1, "DRRoundsPassed" );		
	self:NetworkVar( "Float", 0, "DRRoundStartTime" );
		
	if ( SERVER ) then
		self:SetDRRoundStartTime(0);
		self:SetDRState(STATE_IDLE);
		self:SetDRRoundsPassed(0);
	end
end
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end
function ENT:KeyValue( key, value )
	if ( self:SetNetworkKeyValue( key, value ) ) then
		return
	end
end
function ENT:CanEditVariables( ply )
	return false;
end