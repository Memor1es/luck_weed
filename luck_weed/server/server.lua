
--[[
╔═══╗╔═══╗╔═══╗╔═══╗╔╗───╔╗─╔╗╔═══╗╔╗╔═╗
║╔═╗║║╔═╗║║╔═╗║╚╗╔╗║║║───║║─║║║╔═╗║║║║╔╝
║║─╚╝║║─║║║║─║║─║║║║║║───║║─║║║║─╚╝║╚╝╝─
║║╔═╗║║─║║║║─║║─║║║║║║─╔╗║║─║║║║─╔╗║╔╗║─
║╚╩═║║╚═╝║║╚═╝║╔╝╚╝║║╚═╝║║╚═╝║║╚═╝║║║║╚╗
╚═══╝╚═══╝╚═══╝╚═══╝╚═══╝╚═══╝╚═══╝╚╝╚═╝
--]]


ESX = nil

TriggerEvent("esx:getSharedObject", function(library) 
	ESX = library 
end)

local st
local iden
RegisterServerEvent("luck_weed:createplant")
AddEventHandler("luck_weed:createplant", function(x, y, z, strain)
_source = source
local xPlayer = ESX.GetPlayerFromId(_source)
iden =  xPlayer.identifier
if strain == "Seeded" then
st = 3
else
st = 2
end
	MySQL.Async.fetchAll('INSERT INTO `weeds` (`identifier`, `x`, `y`, `z`, `strain`, `status`) VALUES (@identifier, @x, @y, @z, @strain, @status)', {
        ['@identifier'] = iden,
        ['@x']  = x,
        ['@y']  = y,
        ['@z']  = z,
        ['@strain']  = strain,
        ['@status']  = st
        

    }, function(lol)
    MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `weeds` ORDER BY `id`) sub ORDER BY `id`", {}, function(weeds)
        for c = 1, #weeds do
            print('ss')
         TriggerClientEvent("luck_weed:currentcrops", -1, weeds)  
        end
     end)
end)
end)

RegisterServerEvent("luck_weed:requestTable")
AddEventHandler("luck_weed:requestTable", function()
    _source = source
    MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `weeds` ORDER BY `id`) sub ORDER BY `id`", {}, function(weeds)
        for c = 1, #weeds do
         TriggerClientEvent("luck_weed:currentcrops", -1, weeds)  
        end
end)
end)

RegisterServerEvent("luck_weed:setStatus2")
AddEventHandler("luck_weed:setStatus2", function()
    _source = source
    local status
    MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `weeds` ORDER BY `id`) sub ORDER BY `id`", {}, function(weeds)
        for c = 1, #weeds do
    if weeds[c].strain == "Seeded" then
        status = 3
    else
        status = 2 
    end

         MySQL.Async.execute('UPDATE `weeds` SET `status` = @status WHERE `id` = @id', {
            ['@id'] = weeds[c].id,
            ['@status'] = status
        }, function(lol) 
    TriggerEvent("luck_weed:requestTable")
    end)
end
end)
  
end)




    RegisterServerEvent("luck_weed:killplant")
    AddEventHandler("luck_weed:killplant", function(id)
        _source = source
        MySQL.Async.execute('DELETE FROM `weeds` WHERE `id` = @id', {
            ['@id'] = id,
        }, function(lol) 
                TriggerClientEvent('luck_weed:updateplantwithID', -1, id, '0', "remove")
            end)
    end)
    

RegisterServerEvent("luck_weed:UpdateWeedGrowth")
AddEventHandler("luck_weed:UpdateWeedGrowth", function(id, new)
    _source = source
    print(id)
    MySQL.Async.execute('UPDATE `weeds` SET `growth` = @growth,  `status` = @status WHERE `id` = @id', {
        ['@id'] = id,
        ['@status'] = 1,
        ['@growth'] = new
    }, function(lol) 
      TriggerClientEvent('luck_weed:updateplantwithID', -1, id, new, "alter")

end)
end)



RegisterServerEvent("luck_weed:UpdateWeedStatus")
AddEventHandler("luck_weed:UpdateWeedStatus", function(id, status)
    _source = source
    print(id)
    MySQL.Async.execute('UPDATE `weeds` SET `status` = @status WHERE `id` = @id', {
        ['@id'] = id,
        ['@status'] = 1
    }, function(lol) 
      TriggerClientEvent('luck_weed:updateplantwithID', -1, id, new, 'alter')

end)
end)

RegisterServerEvent('luck_weed:AddItem')
AddEventHandler('luck_weed:AddItem', function(item, count)
local _source = source
local xPlayer = ESX.GetPlayerFromId(_source)
xPlayer.addInventoryItem(item, count)

end)

RegisterServerEvent('luck_weed:RemoveItem')
AddEventHandler('luck_weed:RemoveItem', function(item, count)
local _source = source
local xPlayer = ESX.GetPlayerFromId(_source)
xPlayer.removeInventoryItem(item, count)
end)




ESX.RegisterUsableItem('maleseed', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if 0 < xPlayer.getInventoryItem(Config.Pot).count then
    TriggerClientEvent("luck_weed:startcrop", source, 'male')
    else
    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = "Üzerinde saksı yok!"})
    end
end)


RegisterCommand('weed', function(source)
TriggerClientEvent("luck_weed:startcrop", source, 'female')
end)

ESX.RegisterUsableItem('femaleseed', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if 0 < xPlayer.getInventoryItem(Config.Pot).count then
    TriggerClientEvent("luck_weed:startcrop", source, 'female')
    else
    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = "Üzerinde saksı yok!"})
    end
end)

ESX.RegisterServerCallback('luck_weed:qtty', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local qtty = xPlayer.getInventoryItem(item).count
	cb(qtty)
end)
