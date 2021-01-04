local policetable = {}
local active = {}
ESX                 = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function getIdentity(identifier, callback)
 
	MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = @identifier", {['@identifier'] = identifier},
	function(result)
	  if result[1]['firstname'] ~= nil then
		local data = {
		  identifier    = result[1]['identifier'],
		  firstname     = result[1]['firstname'],
		  lastname      = result[1]['lastname'],
		  odznaka 		= result[1]['odznaka']
		}
		callback(data)
	  else
		local data = 
		{
		  identifier    = '',
		  firstname     = '',
		  lastname      = '',
		  odznaka  = '',
		}
		callback(data)
	  end
	end)
  end

RegisterServerEvent('neey_coops:addLSPD')
AddEventHandler('neey_coops:addLSPD',function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.getIdentifier()
	local i = GetPlayerName(source) 
	if xPlayer.job.name == 'police' then
		Citizen.Wait(100)
		active[_source] = true
		if active[_source] == true then
			Citizen.Wait(100)
			if  #policetable > 0 then
			
				for k,v in pairs(policetable) do
					if policetable[k].i == i then
						table.remove(policetable,k)
						
					end
				end
			end
			
			getIdentity(identifier, function(data)
				if data.odznaka == '0' then
					table.insert(policetable, {
						i = i,
						name = (data.firstname..' '..data.lastname)
					})
				else
					table.insert(policetable, {
						i = i,
						name = (data.odznaka ..' | '.. data.firstname..' '..data.lastname)
					})
				end
				Citizen.Wait(500)
				showblips = true
				local gpscount = xPlayer.getInventoryItem('nadajson').count
				if gpscount > 0 and gpscount < 2 then
					local countgps = 1
					TriggerClientEvent('neey_coops:updateLSPD',-1,policetable,i,showblips, countgps)
				else
					local countgps = 0
					TriggerClientEvent('neey_coops:updateLSPD',-1,policetable,i,showblips, countgps)
				end
			end)
		end
	end
end)


RegisterServerEvent('neey_coops:deleteLSPD')
AddEventHandler('neey_coops:deleteLSPD',function(name, source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	print(active[_source])
	if active[_source] == true then
		for k,v in pairs(policetable) do
			if policetable[k].i == name then
				table.remove(policetable,k)
			end
		end
		showblips = false
		Citizen.Wait(100)
		active[source] = false
		Citizen.Wait(100)
		TriggerClientEvent('neey_coops:updateLSPD',-1,policetable,i,showblips)
		TriggerClientEvent("neey_coops:gpslossloc", source)
	end
end)

RegisterServerEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(type, itemName, itemCount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xItem = xPlayer.getInventoryItem('nadajson').count
	Citizen.Wait(500)
	if xPlayer.job.name == 'police' then
        if itemName == 'nadajson' then
			if active[_source] == true then
				TriggerEvent("neey_coops:deleteLSPD", GetPlayerName(_source), _source)
			else
				Citizen.Wait(100)
				active[_source] = false
			end
		end
	end
end)

RegisterServerEvent('bestup_kajdanki:confiscatePlayerItem')
AddEventHandler('bestup_kajdanki:confiscatePlayerItem', function(target, itemType, itemName, amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(target)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	print(itemName)
	Citizen.Wait(500)
	if targetXPlayer.job.name == 'police' then
		if itemName == 'nadajson' then
			print(active[target])
			if active[target] == true then
				TriggerEvent("neey_coops:deleteLSPD", GetPlayerName(target), targetXPlayer)
				Citizen.Wait(500)
				active[target] = false
			else
				Citizen.Wait(500)
				active[target] = false
			end
		end
	end
end)

ESX.RegisterUsableItem('nadajson', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if active[_source] == nil or active[_source] == false then
		if xPlayer.job.name == 'police' then
			TriggerEvent('neey_coops:addLSPD', source)
			TriggerClientEvent("pNotify:SendNotification", source, {
				text = "Aktywowano nadajnik GPS!",
				type = "success",
				queue = "lmao",
				timeout = 2000,
				layout = "centerLeft"
			})
			Citizen.Wait(500)
			active[_source] = true
		end
	end
end)

AddEventHandler('onResourceStart', function(resource)
	local _source = source
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		TriggerClientEvent('neey_coops:updateLSPD', -1)
	end
end)

RegisterServerEvent('neey_coops:showblip')
AddEventHandler('neey_coops:showblip', function(tx, ty, tz)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.getIdentifier()
	if xPlayer.job.name == 'police' then
		getIdentity(identifier, function(data)
			local name = data.firstname..' '..data.lastname
			local name2 = data.firstname..''..data.lastname
			TriggerClientEvent('neey_coops:showfploss', -1, tx, ty, tz, name, name2)
		end)
	end
end)

AddEventHandler('playerDropped', function()
	local _source = source
	if _source ~= nil then
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == 'police' then
			print(xPlayer.job.name)
			Citizen.Wait(5000)
			active[_source] = false
		end
	end	
end)

RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function(source)
	  local _source = source
	  local xPlayer = ESX.GetPlayerFromId(_source)
	  Citizen.Wait(15000)
	  if xPlayer.job.name == 'police' then
		local i = GetPlayerName(source) 
		xPlayer.setJob('police', xPlayer.job.grade)
		showblips = true
		Citizen.Wait(1000)
		TriggerClientEvent('neey_coops:updateLSPD',-1,policetable,i,showblips, 1)
		print('jd')
	  end
end)



