--[[
	____                                                    
	|  _ \                                                   
	| |_) |_ __ ___  ___ _____   _                           
	|  _ <| '__/ _ \/ _ \_  / | | |                          
	| |_) | | |  __/  __// /| |_| |                          
	|____/|_|  \___|\___/___|\__, |                          
							  __/ |                          
	 _    _                 _|___/     _ _     _             
	| |  | |               (_) |      | (_)   (_)            
	| |__| | ___  ___ _ __  _| |_ __ _| |_ _____ _ __   __ _ 
	|  __  |/ _ \/ __| '_ \| | __/ _` | | |_  / | '_ \ / _` |
	| |  | | (_) \__ \ |_) | | || (_| | | |/ /| | | | | (_| |
	|_|  |_|\___/|___/ .__/|_|\__\__,_|_|_/___|_|_| |_|\__, |
					 | |                                __/ |
					 |_|                               |___/ 
   
															   
	 
			Made By Badger#0002 edited by Breezy#8000
									 
									 
		   
  ]] 

function SaveFile(data)
	SaveResourceFile(GetCurrentResourceName(), "players.json", json.encode(data, { indent = true }), -1)
end
function LoadFile()
	local al = LoadResourceFile(GetCurrentResourceName(), "players.json")
	--print(al)
    local cfg = json.decode(al)
    return cfg;
end
function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }


    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end
JailTracker = {};
RegisterCommand('hospitalize', function(src, args, raw)
	-- /jail <id> <time> 
	if IsPlayerAceAllowed(src, "Breezy_Hospitalize.Jail") then 
		if #args < 2 then 
			-- Not enough args 
			TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: Invalid usage. ^2Usage: /hospitalize <id> <time>");
			return;
		end
		if GetPlayerIdentifiers(args[1])[1] ~= nil then 
			-- Valid player 
			if tonumber(args[2]) ~= nil then 
				-- Valid number supplied 
				TriggerClientEvent('chatMessage', -1, Config.Prefix .. "Player ^5" .. GetPlayerName(args[1]) .. " ^3has been hospitalized for ^1" ..
					args[2] .. " ^3seconds...");
				Citizen.CreateThread(function()
					local cfg = LoadFile();
					local ids = ExtractIdentifiers(args[1]);
					cfg[ids.license] = {Cell = nil, Time = tonumber(args[2])};
					SaveFile(cfg); 
					while not IsCellFree() do
						TriggerClientEvent('chatMessage', args[1], Config.Prefix .. "Waiting on a free spot at the hospital..."); 
						Citizen.Wait(10000);
					end
					local key = GetFreeCell();
					local coords = Config.Cells[key];
					CellTracker[key] = ids.license;
					local cfg = LoadFile();
					cfg[ids.license] = {Cell = key, Time = tonumber(args[2])};
					JailTracker[tonumber(args[1])] = tonumber(args[2]);
					SaveFile(cfg); 
					TriggerClientEvent('Breezy_Hospitalize:JailPlayer3253634', tonumber(args[1]), coords, tonumber(args[2]), key);
				end)
			else 
				-- Invalid number supplied 
				TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: The 2nd argument was not a proper number...");
			end
		else 
			-- Invalid player 
			TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: Invalid player supplied...");
		end
	end
end)

RegisterCommand('release', function(src, args, raw)
	-- /unjail <id> 
	if IsPlayerAceAllowed(src, "Breezy_Hospitalize.Unjail") then 
		if #args ~= 1 then 
			-- Not enough args 
			TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: Invalid usage. ^2Usage: /release <id>");
			return;
		end
		if GetPlayerIdentifiers(args[1])[1] ~= nil then 
			-- Valid player 
			TriggerClientEvent('chatMessage', -1, Config.Prefix .. "Player ^5" .. GetPlayerName(args[1]) .. " ^3has been released from the hospital by ^2" 
				.. GetPlayerName(src));

			TriggerClientEvent('Breezy_Hospitalize:UnjailPlayer', args[1]);
			local ids = ExtractIdentifiers(args[1]);
			local cfg = LoadFile();
			cfg[ids.license] = nil;
			JailTracker[tonumber(args[1])] = nil;
			SaveFile(cfg); 
		else 
			-- Not valid player 
			TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: Invalid player supplied...");
		end
	end
end)
Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(1000);
		for k, v in pairs(JailTracker) do 
			if JailTracker[k] ~= nil and JailTracker[k] > 0 then 
				JailTracker[k] = JailTracker[k] - 1;
			end
			if JailTracker[k] ~= nil and JailTracker[k] == 0 then 
				JailTracker[k] = nil;
			end
		end
	end
end)
RegisterNetEvent("Breezy_Hospitalize:Connected")
AddEventHandler("Breezy_Hospitalize:Connected", function()
	local src = source;
	local ids = ExtractIdentifiers(src);
	local cfg = LoadFile();
	if cfg[ids.license] ~= nil then 
		local time = cfg[ids.license].Time
		local cell = cfg[ids.license].Cell;
		if CellTracker[cell] == nil then 
			-- Jail them in this cell 
			CellTracker[cell] = ids.license;
			local coords = Config.Cells[cell];
			TriggerClientEvent('Breezy_Hospitalize:JailPlayer3253634', tonumber(src), coords, time, cell);
		else 
			-- Jail them in another cell 
			Citizen.CreateThread(function()
				while not IsCellFree() do
					TriggerClientEvent('chatMessage', src, Config.Prefix .. "Waiting on a free spot at the hospital..."); 
					Citizen.Wait(10000);
				end
				local key = GetFreeCell();
				local coords = Config.Cells[key];
				local ids = ExtractIdentifiers(src);
				CellTracker[key] = ids.license;
				local cfg = LoadFile();
				cfg[ids.license] = {Cell = key, Time = tonumber(time)};
				JailTracker[src] = tonumber(time);
				SaveFile(cfg); 
				TriggerClientEvent('Breezy_Hospitalize:JailPlayer3253634', tonumber(src), coords, tonumber(time), key);
			end)
		end
	end
end)
AddEventHandler("playerDropped", function()
	local src = source;
	local ids = ExtractIdentifiers(src);
	local cfg = LoadFile();
	if cfg[ids.license] ~= nil then 
		cfg[ids.license].Time = JailTracker[src];
	end
	SaveFile(cfg);
	JailTracker[src] = nil;
	SaveFile(cfg);
	for key, license in pairs(CellTracker) do 
		if license == ids.license then 
			CellTracker[key] = nil;
		end
	end
end)

CellTracker = {}

RegisterNetEvent('Breezy_Hospitalize:FreeCell')
AddEventHandler('Breezy_Hospitalize:FreeCell', function(cell)
	local ids = ExtractIdentifiers(source);
	local cfg = LoadFile();
	cfg[ids.license] = nil;
	JailTracker[source] = nil;
	SaveFile(cfg); 
	CellTracker[cell] = nil;
end)

function GetFreeCell()
	for k, v in pairs(Config.Cells) do
		if CellTracker[k] == nil then 
			return k;
		end
	end
	return nil;
end

function IsCellFree()
	for k, v in pairs(Config.Cells) do
		if CellTracker[k] == nil then 
			return true;
		end
	end
	return false;
end




