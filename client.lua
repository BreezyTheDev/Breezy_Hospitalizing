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
  
jailTime = nil;
cords = nil;
jailCell = nil;
RegisterNetEvent('Breezy_Hospitalize:JailPlayer3253634')
AddEventHandler('Breezy_Hospitalize:JailPlayer3253634', function(jailCoords, time, cell)
	local ped = GetPlayerPed(-1);
	jailTime = time;
	cords = jailCoords;
	jailCell = cell;
	SetEntityCoords(ped, cords.x, cords.y, cords.z, 1, 0, 0, 1)
end)

RegisterNetEvent('Breezy_Hospitalize:UnjailPlayer')
AddEventHandler('Breezy_Hospitalize:UnjailPlayer', function()
	jailTime = nil;
	local coords = Config.PrisonExit;
	local ped = GetPlayerPed(-1);
	SetEntityCoords(ped, coords.x, coords.y, coords.z, 1, 0, 0, 1)
	TriggerEvent('chatMessage', Config.Prefix .. "You have been released from the hospital!...");
	TriggerServerEvent('Breezy_Hospitalize:FreeCell', jailCell);
	jailCell = nil;
	cords = nil;
end)

Citizen.CreateThread(function()
	TriggerServerEvent("Breezy_Hospitalize:Connected");
	while true do 
		Citizen.Wait(1000);
		local ped = GetPlayerPed(-1)
		if jailTime ~= nil then 
			if jailTime > 0 then 
				jailTime = jailTime - 1;
			end
			if mod(jailTime, 5) == 0 and jailTime ~= 0 then 
				TriggerEvent('chatMessage', Config.Prefix .. "You have ^1" .. jailTime .. "^3 seconds left in the hospital...");
				SetEntityCoords(ped, cords.x, cords.y, cords.z, 1, 0, 0, 1)
			end
			if jailTime == 0 then 
				TriggerEvent('Breezy_Hospitalize:UnjailPlayer');
				jailTime = nil;
			end
		end
	end
end)
function mod(a, b)
    return a - (math.floor(a/b)*b)
end
function Draw2DText(x, y, text, scale, center)
    -- Draw text on screen
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    if center then 
    	SetTextJustification(0)
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

TriggerEvent('chat:addSuggestion', '/hospitalize', '/hospitalize <id> <time>')

TriggerEvent('chat:addSuggestion', '/release', '/release <id>')