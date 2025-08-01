
hook.Add( "PopulateNPCs", "AddNPCContent", function( pnlContent, tree, browseNode )

	-- Get a list of available NPCs
	local NPCList = list.Get( "NPC" )

	-- Categorize them
	local Categories = {}

	-- Category localization support for old addons
	local TranslateNames = {
		["Animals"] = "#spawnmenu.category.animals",
		["Combine"] = "#spawnmenu.category.combine",
		["Humans + Resistance"] = "#spawnmenu.category.humans_resistance",
		["Zombies + Enemy Aliens"] = "#spawnmenu.category.zombies_aliens",
		["Other"] = "#spawnmenu.category.other"
	}

	for k, v in pairs( NPCList ) do

		local Category = language.GetPhrase( TranslateNames[v.Category] or v.Category or "#spawnmenu.category.other" )
		if ( !isstring( Category ) ) then Category = tostring( Category ) end

		local Tab = Categories[ Category ] or {}
		Tab[ k ] = v
		Categories[ Category ] = Tab

	end

	-- Create an icon for each one and put them on the panel
	local CustomIcons = list.Get( "ContentCategoryIcons" )
	for CategoryName, v in SortedPairs( Categories ) do

		-- Add a node to the tree
		local node = tree:AddNode( CategoryName, CustomIcons[ CategoryName ] or "icon16/monkey.png" )

		-- When we click on the node - populate it using this function
		node.DoPopulate = function( self )

			-- If we've already populated it - forget it.
			if ( self.PropPanel ) then return end

			-- Create the container panel
			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for name, ent in SortedPairsByMemberValue( v, "Name" ) do

				spawnmenu.CreateContentIcon( ent.ScriptedEntityType or "npc", self.PropPanel, {
					nicename	= ent.Name or name,
					spawnname	= name,
					material	= ent.IconOverride or "entities/" .. name .. ".png",
					weapon		= ent.Weapons,
					admin		= ent.AdminOnly
				} )

			end

		end

		-- If we click on the node populate it and switch to it.
		node.DoClick = function( self )

			self:DoPopulate()
			pnlContent:SwitchPanel( self.PropPanel )

		end

	end

	-- Select the first node
	local FirstNode = tree:Root():GetChildNode( 0 )
	if ( IsValid( FirstNode ) ) then
		FirstNode:InternalDoClick()
	end

end )

local PANEL = {}

Derma_Hook( PANEL, "Paint", "Paint", "Tree" )
PANEL.m_bBackground = true -- Hack for above

function PANEL:AddCheckbox( text, cvar )
	local DermaCheckbox = self:Add( "DCheckBoxLabel", self )
	DermaCheckbox:Dock( TOP )
	DermaCheckbox:SetText( text )
	DermaCheckbox:SetDark( true )
	DermaCheckbox:SetConVar( cvar)
	DermaCheckbox:SizeToContents()
	DermaCheckbox:DockMargin( 0, 5, 0, 0 )
end

function PANEL:Init()

	self:SetOpenSize( 150 )
	self:DockPadding( 15, 10, 15, 10 )

	self:AddCheckbox( "#menubar.npcs.disableai", "ai_disabled" )
	self:AddCheckbox( "#menubar.npcs.ignoreplayers", "ai_ignoreplayers" )
	self:AddCheckbox( "#menubar.npcs.keepcorpses", "ai_serverragdolls" )
	self:AddCheckbox( "#menubar.npcs.autoplayersquad", "npc_citizen_auto_player_squad" )

	local label = vgui.Create( "DLabel", self )
	label:Dock( TOP )
	label:DockMargin( 0, 5, 0, 0 )
	label:SetDark( true )
	label:SetText( "#menubar.npcs.weapon" )

	local DComboBox = vgui.Create( "DComboBox", self )
	DComboBox:Dock( TOP )
	DComboBox:DockMargin( 0, 0, 0, 0 )
	DComboBox:SetConVar( "gmod_npcweapon" )
	DComboBox:SetSortItems( false )

	DComboBox:AddChoice( "#menubar.npcs.defaultweapon", "" )
	DComboBox:AddChoice( "#menubar.npcs.noweapon", "none" )

	-- Sort the items by name, and group by category
	local groupedWeps = {}
	for _, v in pairs( list.Get( "NPCUsableWeapons" ) ) do
		local cat = (v.category or ""):lower()
		groupedWeps[ cat ] = groupedWeps[ cat ] or {}
		groupedWeps[ cat ][ v.class ] = language.GetPhrase( v.title )
	end

	for group, items in SortedPairs( groupedWeps ) do
		DComboBox:AddSpacer()
		for class, title in SortedPairsByValue( items ) do
			DComboBox:AddChoice( title, class )
		end
	end

	function DComboBox:OnSelect( index, value )
		self:ConVarChanged( self.Data[ index ] )
	end

	self:Open()

end

function PANEL:PerformLayout()
end

vgui.Register( "SpawnmenuNPCSidebarToolbox", PANEL, "DDrawer" )

spawnmenu.AddCreationTab( "#spawnmenu.category.npcs", function()

	local ctrl = vgui.Create( "SpawnmenuContentPanel" )
	ctrl:EnableSearch( "npcs", "PopulateNPCs" )
	ctrl:CallPopulateHook( "PopulateNPCs" )

	local sidebar = ctrl.ContentNavBar
	sidebar.Options = vgui.Create( "SpawnmenuNPCSidebarToolbox", sidebar )
	sidebar.Options:Dock( BOTTOM )

	return ctrl

end, "icon16/monkey.png", 20 )
