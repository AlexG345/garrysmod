
--[[---------------------------------------------------------
	Name: KickId2
	Desc: Allows admins to use the kickid2 command to kick people.
-----------------------------------------------------------]]
local function KickId( player, command, arguments )

	if ( !player:IsAdmin() ) then return end

	local id = arguments[1]
	local reason = arguments[2] or "Kicked"

	RunConsoleCommand( "kickid", id, Format( "%s (%s)", reason, player:Nick() ) )

end

concommand.Add( "kickid2", KickId, nil, "Alias of kickid, do not use.", { FCVAR_DONTRECORD } )


--[[---------------------------------------------------------
	Name: BanId2
	Desc: Allows admins to use the banid2 command to ban people.
-----------------------------------------------------------]]
local function BanID( player, command, arguments )

	if ( !player:IsAdmin() ) then return end

	local length 	= arguments[1]
	local id 		= arguments[2]

	RunConsoleCommand( "banid", length, id )

end

concommand.Add( "banid2", BanID, nil, "Alias of banid, do not use.", { FCVAR_DONTRECORD } )
