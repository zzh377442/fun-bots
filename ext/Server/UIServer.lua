class 'FunBotUIServer'

require('__shared/ArrayMap')
require('__shared/Config')

Language = require('__shared/Language')

local m_NodeCollection = require('__shared/NodeCollection')
local m_SettingsManager = require('SettingsManager')

local BotManager = require('BotManager')
local BotSpawner = require('BotSpawner')
local WeaponModification = require('WeaponModification')
local WeaponList = require('__shared/WeaponList')

function FunBotUIServer:__init()
	self._webui = 0
	self._authenticated = ArrayMap()

	if Config.DisableUserInterface ~= true then
		NetEvents:Subscribe('UI_Request_Open', self, self._onUIRequestOpen)
		NetEvents:Subscribe('UI_Request_Save_Settings', self, self._onUIRequestSaveSettings)
		NetEvents:Subscribe('BotEditor', self, self._onBotEditorEvent)
		NetEvents:Subscribe('UI_Request_CommoRose_Show', self, self._onUIRequestCommonRoseShow)
	end
end

function FunBotUIServer:_onBotEditorEvent(p_Player, p_Data)
	if Config.DisableUserInterface == true then
		return
	end

	-- Low permission for Comm-Screen --TODO: for all? 
	if not Config.AllowCommForAll or PermissionManager:HasPermission(p_Player, 'Comm') == false then
		ChatManager:SendMessage('You have no permissions for this action.', p_Player)
		return
	end

	local request = json.decode(p_Data)

	-- Comm Screen
	if request.action == 'exit_vehicle' then
		BotManager:ExitVehicle(p_Player)
		NetEvents:SendTo('UI_CommonRose', p_Player, "false")
		return
	elseif request.action == 'drop_ammo' then
		BotManager:Deploy(p_Player, "ammo")
		NetEvents:SendTo('UI_CommonRose', p_Player, "false")
		return
	elseif request.action == 'drop_medkit' then
		BotManager:Deploy(p_Player, "medkit")
		NetEvents:SendTo('UI_CommonRose', p_Player, "false")
		return
	elseif request.action  == 'enter_vehicle' then
		BotManager:EnterVehicle(p_Player)
		NetEvents:SendTo('UI_CommonRose', p_Player, "false")
		return
	elseif request.action == 'repair_vehicle' then
		BotManager:RepairVehicle(p_Player)
		NetEvents:SendTo('UI_CommonRose', p_Player, "false")
		return
	elseif request.action == 'attack_objective' then
		-- change commo-rose
		NetEvents:SendTo('UI_CommonRose', p_Player, {
			Top = {
				Action = 'not_implemented',
				Label = Language:I18N(''),
				Confirm = true
			},
			Left = {
				{
					Action = 'attack_a',
					Label = Language:I18N('A')
				}, {
					Action = 'attack_b',
					Label = Language:I18N('B')
				}, {
					Action = 'attack_c',
					Label = Language:I18N('C')
				}, {
					Action = 'attack_d',
					Label = Language:I18N('D')
				}
			},
			Center = {
				Action = 'not_implemented',
				Label = Language:I18N('Attack') -- or "Unselect"
			},
			Right = {
				{
					Action = 'attack_e',
					Label = Language:I18N('E')
				}, {
					Action = 'attack_f',
					Label = Language:I18N('F')
				}, {
					Action = 'attack_g',
					Label = Language:I18N('G')
				}, {
					Action = 'attack_h',
					Label = Language:I18N('H')
				}
			},
			Bottom = {
				Action = 'back_to_comm',
				Label = Language:I18N('back'),
			}
		})
		return
	elseif request.action == 'defend_objective' then
		NetEvents:SendTo('UI_CommonRose', p_Player, {
			Top = {
				Action = 'not_implemented',
				Label = Language:I18N(''),
				Confirm = true
			},
			Left = {
				{
					Action = 'defend_a',
					Label = Language:I18N('A')
				}, {
					Action = 'defend_b',
					Label = Language:I18N('B')
				}, {
					Action = 'defend_c',
					Label = Language:I18N('C')
				}, {
					Action = 'defend_d',
					Label = Language:I18N('D')
				}
			},
			Center = {
				Action = 'not_implemented',
				Label = Language:I18N('defend') -- or "Unselect"
			},
			Right = {
				{
					Action = 'defend_e',
					Label = Language:I18N('E')
				}, {
					Action = 'defend_f',
					Label = Language:I18N('F')
				}, {
					Action = 'defend_g',
					Label = Language:I18N('G')
				}, {
					Action = 'defend_h',
					Label = Language:I18N('H')
				}
			},
			Bottom = {
				Action = 'back_to_comm',
				Label = Language:I18N('back'),
			}
		})
		return
	elseif string.find(request.action, 'attack_') ~= nil then
		local s_Objective = request.action:split('_')[2]
		BotManager:Attack(p_Player, s_Objective)
		NetEvents:SendTo('UI_CommonRose', p_Player, "false")
		return
	elseif string.find(request.action, "defend_") ~= nil then
		local s_Objective = request.action:split('_')[2]
		BotManager:Attack(p_Player, s_Objective)
		NetEvents:SendTo('UI_CommonRose', p_Player, "false")
		return
	elseif request.action == 'back_to_comm' then
		self:_onUIRequestCommonRoseShow(p_Player)
		return
	end

	-- General Commands
	if PermissionManager:HasPermission(p_Player, 'UserInterface.BotEditor') == false then
		ChatManager:SendMessage('You have no permissions for this action.', p_Player)
		return
	end

	-- Settings
	if request.action == 'request_settings' then
		if Config.Language == nil then
			Config.Language = 'en_US'
		end

		-- request.opened
		NetEvents:SendTo('UI_Settings', p_Player, Config)

	-- Bots
	elseif request.action == 'bot_spawn_default' then
		local amount = tonumber(request.value)
		local team = p_Player.teamId
		Globals.SpawnMode = "manual"
		if team == TeamId.Team1 then
			BotSpawner:SpawnWayBots(p_Player, amount, true, 0, 0, TeamId.Team2)
		else
			BotSpawner:SpawnWayBots(p_Player, amount, true, 0, 0, TeamId.Team1)
		end

	elseif request.action == 'bot_spawn_friend' then
		local amount = tonumber(request.value)
		Globals.SpawnMode = "manual"
		BotSpawner:SpawnWayBots(p_Player, amount, true, 0, 0, p_Player.teamId)

	elseif request.action == 'bot_spawn_path' then --todo: whats the difference? make a function to spawn bots on a fixed way instead?
		local amount = 1
		local indexOnPath = tonumber(request.pointindex) or 1
		local index = tonumber(request.value)
		Globals.SpawnMode = "manual"
		local s_TeamId = p_Player.teamId + 1
		if s_TeamId > Globals.NrOfTeams then
			s_TeamId = s_TeamId - Globals.NrOfTeams
		end
		BotSpawner:SpawnWayBots(p_Player, amount, false, index, indexOnPath, s_TeamId)

	elseif request.action == 'bot_kick_all' then
		Globals.SpawnMode = "manual"
		BotManager:DestroyAll()

	elseif request.action == 'bot_kick_team' then
		Globals.SpawnMode = "manual"
		local teamNumber = tonumber(request.value)
		if teamNumber == 1 then
			BotManager:DestroyAll(nil, TeamId.Team1)
		elseif teamNumber == 2 then
			BotManager:DestroyAll(nil, TeamId.Team2)
		end

	elseif request.action == 'bot_kill_all' then
		Globals.SpawnMode = "manual"
		BotManager:KillAll()

	elseif request.action == 'bot_respawn' then  --toggle this function
		local respawning = not Globals.RespawnWayBots
		Globals.RespawnWayBots = respawning
		BotManager:SetOptionForAll('respawn', respawning)
		if respawning then
			ChatManager:Yell(Language:I18N('Bot respawn activated!', request.action), 2.5)
		else
			ChatManager:Yell(Language:I18N('Bot respawn deactivated!', request.action), 2.5)
		end

	elseif request.action == 'bot_attack' then  --toggle this function
		local attack = not Globals.AttackWayBots
		Globals.AttackWayBots = attack
		BotManager:SetOptionForAll('shoot', attack)
		if attack then
			ChatManager:Yell(Language:I18N('Bots will attack!', request.action), 2.5)
		else
			ChatManager:Yell(Language:I18N('Bots will not attack!', request.action), 2.5)
		end

	-- Trace
	elseif request.action == 'trace_start' then
		NetEvents:SendToLocal('ClientNodeEditor:StartTrace', p_Player)

	elseif request.action == 'trace_end' then
		NetEvents:SendToLocal('ClientNodeEditor:EndTrace', p_Player)

	elseif request.action == 'trace_save' then
		local index = tonumber(request.value)
		NetEvents:SendToLocal('ClientNodeEditor:SaveTrace', p_Player, index)

	elseif request.action == 'trace_clear' then
		NetEvents:SendToLocal('ClientNodeEditor:ClearTrace', p_Player)

	elseif request.action == 'trace_reset_all' then
		m_NodeCollection:Clear()
		NetEvents:BroadcastLocal('NodeCollection:Clear')

	elseif request.action == 'waypoints_client_load' then
		local expectedAmount = m_NodeCollection:Get()
		NetEvents:SendToLocal('ClientNodeEditor:ReceiveNodes', p_Player, (#expectedAmount))

	elseif request.action == 'waypoints_client_save' then
		NetEvents:SendToLocal('ClientNodeEditor:SaveNodes', p_Player)

	elseif request.action == 'waypoints_server_load' then
		m_NodeCollection:Load()

	elseif request.action == 'waypoints_server_save' then
		m_NodeCollection:Save()

	elseif request.action == 'waypoints_show_spawns' then
		Config.DrawSpawnPoints = not Config.DrawSpawnPoints
		NetEvents:SendToLocal('WriteClientSettings', p_Player, Config, false)

	elseif request.action == 'waypoints_show_lines' then
		Config.DrawWaypointLines = not Config.DrawWaypointLines
		NetEvents:SendToLocal('WriteClientSettings', p_Player, Config, false)

	elseif request.action == 'waypoints_show_labels' then
		Config.DrawWaypointIDs = not Config.DrawWaypointIDs
		NetEvents:SendToLocal('WriteClientSettings', p_Player, Config, false)

	-- Waypoints-Editor
	elseif request.action == 'request_waypoints_editor' then
		NetEvents:SendTo('UI_Waypoints_Editor', p_Player, true)
	elseif request.action == 'disable_waypoint_editor' then
		NetEvents:SendTo('UI_Waypoints_Disable', p_Player)
	elseif request.action == 'hide_waypoints_editor' then
		NetEvents:SendTo('UI_Waypoints_Editor', p_Player, false)
	else
		ChatManager:Yell(Language:I18N('%s is currently not implemented.', request.action), 2.5)
	end
end

function FunBotUIServer:_onUIRequestSaveSettings(p_Player, p_Data)
	if Config.DisableUserInterface == true then
		return
	end

	if Debug.Server.UI then
		print(p_Player.name .. ' requesting to save settings.')
	end

	if PermissionManager:HasPermission(p_Player, 'UserInterface.Settings') == false then
		ChatManager:SendMessage('You have no permissions for this action.', p_Player)
		return
	end

	local request = json.decode(p_Data)

	self:_writeSettings(p_Player, request)
end

function FunBotUIServer:_onUIRequestCommonRoseShow(p_Player, p_Data)
	if Config.DisableUserInterface == true then
		return
	end

	if not Config.AllowCommForAll or PermissionManager:HasPermission(p_Player, 'Comm') == false then
		ChatManager:SendMessage('You have no permissions for this action.', p_Player)
		return
	end

	if Debug.Server.UI then
		print(p_Player.name .. ' requesting show CommonRose.')
	end

	NetEvents:SendTo('UI_CommonRose', p_Player, {
		Top = {
			Action = 'not_implemented',
			Label = Language:I18N(''),
		},
		Left = {
			{
				Action = 'exit_vehicle',
				Label = Language:I18N('Exit Vehicle')
			}, {
				Action = 'enter_vehicle',
				Label = Language:I18N('Enter Vehicle')
			}, {
				Action = 'drop_ammo',
				Label = Language:I18N('Drop Ammo')
			}, {
				Action = 'drop_medkit',
				Label = Language:I18N('Drop Medkit')
			}
		},
		Center = {
			Action = 'not_implemented',
			Label = Language:I18N('Commands') -- or "Unselect"
		},
		Right = {
			{
				Action = 'attack_objective',
				Label = Language:I18N('Attack Objective')
			}, {
				Action = 'defend_objective',
				Label = Language:I18N('Defend Objective'),
			}, {
				Action = 'repair_vehicle',
				Label = Language:I18N('Repair Vehicle')
			}, {
				Action = 'not_implemented',
				Label = Language:I18N('')
			}
		},
		Bottom = {
			Action = 'not_implemented',
			Label = Language:I18N(''),
		}
	})
end

function FunBotUIServer:_onUIRequestCommonRoseHide(p_Player, p_Data)
	if Config.DisableUserInterface == true then
		return
	end

	if PermissionManager:HasPermission(p_Player, 'UserInterface.WaypointEditor') == false then
		ChatManager:SendMessage('You have no permissions for this action.', p_Player)
		return
	end

	if Debug.Server.UI then
		print(p_Player.name .. ' requesting hide CommonRose.')
	end

	NetEvents:SendTo('UI_CommonRose', p_Player, 'false')
end

function FunBotUIServer:_onUIRequestOpen(p_Player, p_Data)
	if Config.DisableUserInterface == true then
		return
	end

	if Debug.Server.UI then
		print(p_Player.name .. ' requesting open Bot-Editor.')
	end

	if PermissionManager:HasPermission(p_Player, 'UserInterface') then

		if Debug.Server.UI then
			print('Open Bot-Editor for ' .. p_Player.name .. '.')
		end

		NetEvents:SendTo('UI_Toggle', p_Player)
		NetEvents:SendTo('UI_Show_Toolbar', p_Player, 'true')
	else
		ChatManager:SendMessage('You have no permissions to open the UI', p_Player)
	end
end

function FunBotUIServer:_writeSettings(p_Player, p_Request)
	if Config.DisableUserInterface == true then
		return
	end

	local temporary = false
	local updateWeapons = false
	local updateBotTeamAndNumber = false
	local updateWeaponSets = false
	local calcYawPerFrame = false
	local updateLanguage = false
	local updateMaxBots = false
	local batched = true

	if p_Request.subaction ~= nil then
		temporary = (p_Request.subaction == 'temp')
	end

	for _, l_Item in pairs(SettingsDefinition.Elements) do
		-- validate requests
		if p_Request[l_Item.Name] ~= nil then
			local s_Changed = false
			local s_Value = nil
			local s_Valid = false
			if l_Item.Type == Type.Enum then
				-- convert value back
				for l_Key, l_Value in pairs(l_Item.Reference) do
					if l_Key == p_Request[l_Item.Name] and l_Key ~= "Count" then
						s_Value = l_Value
						s_Valid = true
						if s_Value ~= Config[l_Item.Name] then
							s_Changed = true
						end
						break
					end
				end

			elseif l_Item.Type == Type.Table then
				for _, l_Value in pairs(l_Item.Reference) do
					if l_Value == p_Request[l_Item.Name] then
						s_Value = l_Value
						s_Valid = true
						if s_Value ~= Config[l_Item.Name] then
							s_Changed = true
						end
						break
					end
				end

			elseif l_Item.Type == Type.Integer or l_Item.Type == Type.Float then
				s_Value = tonumber(p_Request[l_Item.Name])
				if l_Item.Reference:IsValid(s_Value) then
					s_Valid = true
					if math.abs(s_Value - Config[l_Item.Name]) > 0.001 then
						s_Changed = true
					end
				end

			elseif l_Item.Type == Type.Boolean then
				s_Value = p_Request[l_Item.Name] == true
				s_Valid = true
				if s_Value ~= Config[l_Item.Name] then
					s_Changed = true
				end
			end

			-- update with value or with current Config. Update is needed to not loose Config Values
			if s_Valid then
				m_SettingsManager:Update(l_Item.Name, s_Value, temporary, batched)
			else
				m_SettingsManager:Update(l_Item.Name, Config[l_Item.Name], temporary, batched)
			end

			-- check for update flags
			if s_Changed then
				if l_Item.UpdateFlag == UpdateFlag.WeaponSets then
					updateWeaponSets = true
				elseif l_Item.UpdateFlag == UpdateFlag.Weapons then
					updateWeapons = true
				elseif l_Item.UpdateFlag == UpdateFlag.YawPerSec then
					calcYawPerFrame = true
				elseif l_Item.UpdateFlag == UpdateFlag.AmountAndTeam then
					updateBotTeamAndNumber = true
				elseif l_Item.UpdateFlag == UpdateFlag.Language then
					updateLanguage = true
				elseif l_Item.UpdateFlag == UpdateFlag.MaxBots then
					updateMaxBots = true
				end
			end
		end
	end

	-- Language of UI
	if updateLanguage then
		Language:loadLanguage(Config.Language)
		NetEvents:SendTo('UI_Change_Language', p_Player, Config.Language)
	end

	-- Call batched process
	if batched then
		Database:ExecuteBatch()
	end

	if temporary then
		ChatManager:Yell(Language:I18N('Settings has been saved temporarily.'), 2.5)
	else
		ChatManager:Yell(Language:I18N('Settings has been saved.'), 2.5)
	end

	-- update Weapons if needed
	if updateWeapons then
		WeaponModification:ModifyAllWeapons(Config.BotAimWorsening, Config.BotSniperAimWorsening)
	end

	if updateWeaponSets then
		WeaponList:updateWeaponList()
	end

	if calcYawPerFrame then
		Globals.YawPerFrame = BotManager:CalcYawPerFrame()
	end

	if updateMaxBots then
		g_FunBotServer:SetMaxBotsPerTeam(Globals.GameMode)
	end

	NetEvents:BroadcastLocal('WriteClientSettings', Config, updateWeaponSets)

	if updateBotTeamAndNumber then
		Globals.SpawnMode = Config.SpawnMode
		BotSpawner:UpdateBotAmountAndTeam()
	end
	-- @ToDo create Error Array and dont hide if has values
	NetEvents:SendTo('UI_Settings', p_Player, false)
end

if g_FunBotUIServer == nil then
	g_FunBotUIServer = FunBotUIServer()
end

return g_FunBotUIServer
