local blips = {}
local PlayerData                = {}
local GUI                       = {}
local sData 					= false
local PlayerData                = {}
ESX                             = nil



Citizen.CreateThread(function()
  while ESX == nil do
   TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(1)
  end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	 PlayerData.job = job
	 TriggerServerEvent('neey_coops:deleteJobLSPD',  GetPlayerName(PlayerId()))
end)

RegisterNetEvent('neey_coops:updateLSPD')
AddEventHandler('neey_coops:updateLSPD',function(policetable,name,showblips, gps)

	if PlayerData.job ~= nil and PlayerData.job.name == 'offpolice' then
		for i = 0,256 do
			RemoveBlip(blips[i])
		end
	end
	

	if	PlayerData.job ~= nil and PlayerData.job.name == 'police' then
		for i = 0,256 do
			RemoveBlip(blips[i])
		end
		for i=0,256 do
			if policetable ~= nil then
				for k,v in pairs(policetable) do
					if policetable[k].i == GetPlayerName(PlayerId()) then
						table.remove(policetable,k)
					end
				end
				for k,v in pairs(policetable) do
					local playerPed = GetPlayerPed(i)
					local playerName = GetPlayerName(i)
					if playerName == policetable[k].i then
						local new_blip = AddBlipForEntity(playerPed)
						BeginTextCommandSetBlipName("STRING");
						AddTextComponentString(policetable[k].name);
						EndTextCommandSetBlipName(new_blip);
						SetBlipColour(new_blip, 38)
						SetBlipCategory(new_blip, 2)
						SetBlipScale(new_blip, 0.85)
						SetBlipRotation(new_blip, math.ceil(GetEntityHeading(playerPed))) -- update rotation
						blips[k] = new_blip
					end
				end
			end
		end
	end
end)

RegisterNetEvent('neey_coops:gpslossloc')
AddEventHandler('neey_coops:gpslossloc',function()
	if PlayerData.job ~= nil and PlayerData.job.name == 'police' then
		local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
		TriggerServerEvent('neey_coops:showblip', plyPos.x, plyPos.y, plyPos.z)
	end
end)

RegisterNetEvent('neey_coops:showfploss')
AddEventHandler('neey_coops:showfploss', function(gx, gy, gz, name, name2)
	if PlayerData.job ~= nil and PlayerData.job.name == 'police' then
		TriggerEvent("pNotify:SendNotification", {
			text = "Jeden z funkcjonariuszy utracił nadajnik! Jego lokalizacja została oznaczona na GPS.",
			type = "success",
			queue = "lmao",
			timeout = 2000,
			layout = "centerLeft"
		})
		local blipname = 'bliprobbery' .. name2
		blipname = AddBlipForCoord(gx, gy, gz)
			SetBlipSprite(blipname , 161)
			SetBlipScale(blipname , 1.0)
			SetBlipColour(blipname, 49)
			PulseBlip(blipname)
			SetBlipAsShortRange(blipname, true)
			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString('# Ostatnia lokalizacja funkcjonariusza ' .. name)
			EndTextCommandSetBlipName(blipname)
		Citizen.SetTimeout(25000, function()
			RemoveBlip(blipname)
		end)
	end
end)

