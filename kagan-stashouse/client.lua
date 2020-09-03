-- AreCoordsCollidingWithExterior()
local OwnedHouse = nil
local AvailableHouses = {}
local blips = {}
local Knockings = {}





Citizen.CreateThread(function()
    while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Wait(0) end
    while ESX.GetPlayerData().job == nil do Wait(0) end
    TriggerServerEvent('loaf_housing:getOwned')
    while OwnedHouse == nil do Wait(0) end

    
    local DepoEv = AddBlipForCoord(vector3(Config.StashHouseBuy["x"], Config.StashHouseBuy["y"], Config.StashHouseBuy["z"]))
    SetBlipSprite(DepoEv, 375)
    SetBlipColour(DepoEv, 2)
    SetBlipAsShortRange(DepoEv, true)
    SetBlipScale(DepoEv, 0.7)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Depo Ev Satın Al")
    EndTextCommandSetBlipName(DepoEv)
end)


RegisterCommand('stver', function()
    local player, distance = ESX.Game.GetClosestPlayer()

    for k, v in pairs(Config.Houses) do
        if Vdist2(GetEntityCoords(PlayerPedId()), v['door']) <= 2.5 then
            if OwnedHouse.houseId == k then
                -- if distance ~= -1 and distance <= 3.0 then
                    TriggerServerEvent('kagan-givehouse', k)
                -- else
                    -- TriggerEvent('notification', 'Yakınlarda oyuncu yok', 4)
                -- end
            else
                TriggerEvent('notification', 'Bu ev senin değil', 4)
            end
        end
    end
end)

RegisterCommand('stgir', function()
    for k, v in pairs(Config.Houses) do
        if Vdist2(GetEntityCoords(PlayerPedId()), v['door']) <= 2.5 then
            if OwnedHouse.houseId == k then
                TriggerServerEvent('loaf_housing:enterHouse', k)
                TriggerEvent('luck_weed:inhouse', true)
            else
                TriggerEvent('notification', 'Bu ev senin değil', 4)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local distance = #(GetEntityCoords(PlayerPedId()) - vector3(Config.StashHouseBuy["x"], Config.StashHouseBuy["y"], Config.StashHouseBuy["z"]))
        if distance < 10 then
            DrawMarker(2, Config.StashHouseBuy["x"], Config.StashHouseBuy["y"], Config.StashHouseBuy["z"]-0.25, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(0.5, 0.5, 0.5), 255, 0, 0, 150, false, true, 2, false, false, false)
            if distance < 1.5 then
                DrawText3D(Config.StashHouseBuy["x"], Config.StashHouseBuy["y"], Config.StashHouseBuy["z"]+0.3, "[E] Depo Ev Satın Al")
                if IsControlJustReleased(0, 38) then
                    HouseBuyMenu()
                end
            end
        end
    end
end)

function HouseBuyMenu()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'houseBuyFirstMenu',
    {
        title    = 'Depo Evler',
        align    = 'left',
        elements = {
            {label = "Depo Ev Satın Al", value = "depo_ev"},
            {label = "Satın Aldığım Evler", value = "evlerim"},
            {label = "Satın Alınabilen Evleri Göster/Gizle", value = "evgoster"}
        }
    },function(data, menu)
        if data.current.value == "depo_ev" then
            BuyHouse()
        elseif data.current.value == "evlerim" then
            myHouse()
        elseif data.current.value == "evgoster" then  
            menu.close()
            satilanEvler()
        end
    end,function(data, menu)
        menu.close()
    end)
end

function BuyHouse()
    local elements = {}
    local Houses = Config.Houses
    for x, y in pairs(Houses) do
        table.insert(elements, {label =  x .." Nolu Depo Evi Satın Al $".. Houses[x]["price"], value = x})
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'buyHouse',
    {
        title    = 'Depo Evi Satın Al',
        align    = 'left',
        elements = elements
    },function(data, menu)
        if data.current.value then
            local evNo = data.current.value
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'buyHouseSoru',
            {
                title    = evNo .. ' Nolu Depo Evi Satın Almak İçin Emin misin',
                align    = 'left',
                elements = {
                    {label =  "Evet", value = "yes"},
                    {label =  "Hayır", value = "no"}
                }
            },function(data2, menu2)
                menu2.close()
                if data2.current.value == "yes" then
                    ESX.UI.Menu.CloseAll()
                    TriggerServerEvent('loaf_housing:buyHouse', evNo)
                end
            end,function(data2, menu2)
                menu2.close()
            end)
        end
    end,function(data, menu)
        menu.close()
    end)
end

-- Kendi evini gösterme ve satma
function myHouse()
    local elements = {}

    for k, v in pairs(Config.Houses) do
        if OwnedHouse.houseId == k then
            fiyat = math.floor(Config.Houses[k]['price']*(Config.SellPercentage/100))
            if anahtar then
                table.insert(elements, {label =  OwnedHouse.houseId .." Nolu Depo Evin Anahtarını Bırak", value = OwnedHouse.houseId, durum = "sat"})
            else
                table.insert(elements, {label =  OwnedHouse.houseId .." Nolu Depo Evi Sat $".. fiyat, value = OwnedHouse.houseId, durum = "sat"})
                table.insert(elements, {label =  "Evin Anahtarını Yakınındaki Kişiye Kopyala", value = OwnedHouse.houseId, durum = "anahtar"})
                table.insert(elements, {label =  "Evin Anahtarını Değiştir", value = OwnedHouse.houseId, durum = "anahtar_temizle"})
            end
        else
            table.insert(elements, {label = "Satın Aldığın Herhangi Bir Depo Ev Yok"})
        end
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'myHouse',
    {
        title    = 'Depo Evlerim',
        align    = 'left',
        elements = elements
    },function(data, menu)
        if data.current.value then
            if data.current.durum == "sat" then
                if anahtar then 
                    yazi = data.current.value .. " Nolu Depo Evin Anahtarını Bırak"
                else
                    yazi = data.current.value .. " Nolu Depo Evi ".. fiyat .."$ Karşılığında Satmak İstediğinden Eminmisin"
                end

                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'myHouseSoruMenu',
                {
                    title    = yazi,
                    align    = 'left',
                    elements = {
                        {label =  "Evet", value = "yes"},
                        {label =  "Hayır", value = "no"}
                    }
                },function(data2, menu2)
                    menu2.close()
                    if data2.current.value == "yes" then
                        ESX.UI.Menu.CloseAll()
                        TriggerServerEvent('loaf_housing:sellHouse', data.current.value, anahtar)
                    end
                end,function(data2, menu2)
                    menu2.close()
                end)
            elseif data.current.durum == "anahtar" then
                local player, distance = ESX.Game.GetClosestPlayer()
                if distance ~= -1 and distance <= 3.0 then
                    TriggerServerEvent('loaf_housing:anahtar-ver',  GetPlayerServerId(player), data.current.value)
                else
                    ESX.ShowNotification('Yakınlarda Kimse Yok')
                end

            elseif data.current.durum == "anahtar_temizle" then
                ESX.UI.Menu.CloseAll()
                TriggerServerEvent('loaf_housing:anahtar-temizle', data.current.value)
                ESX.ShowNotification('Evin Ana Anahtarı Değişti')
            end    
        end
    end,function(data, menu)
        menu.close()
    end)
end

function satilanEvler()
    if not goster then
        goster = true
        for k, v in pairs(Config.Houses) do
            CreateBlip(v['door'], 374, 0, 0.45, '')
        end
        ESX.ShowNotification('Haritada Satın Alınabilen Evler Açıldı')
    else
        goster = false
        for k, v in pairs(blips) do
            RemoveBlip(v)
        end
        ESX.ShowNotification('Haritada Satın Alınabilen Evler Kapatıldı')
    end
end


RegisterNetEvent('loaf_housing:spawnHouse')
AddEventHandler('loaf_housing:spawnHouse', function(coords, furniture)
    local prop = Config.Houses[OwnedHouse.houseId]['prop']
    local house = EnterHouse(Config.Props[prop], coords)
    local placed_furniture = {}
    for k, v in pairs(OwnedHouse['furniture']) do
        local model = GetHashKey(v['object'])
        while not HasModelLoaded(model) do RequestModel(model) Wait(0) end
        local object = CreateObject(model, GetOffsetFromEntityInWorldCoords(house, vector3(v['offset'][1], v['offset'][2], v['offset'][3])), false, false, false)
        SetEntityHeading(object, v['heading'])
        FreezeEntityPosition(object, true)
        SetEntityCoordsNoOffset(object, GetOffsetFromEntityInWorldCoords(house, vector3(v['offset'][1], v['offset'][2], v['offset'][3])))
        table.insert(placed_furniture, object)
    end
    SetEntityHeading(house, 0.0)
    local exit = GetOffsetFromEntityInWorldCoords(house, Config.Offsets[prop]['door'])
    local storage = GetOffsetFromEntityInWorldCoords(house, Config.Offsets[prop]['storage'])
    TriggerServerEvent('loaf_housing:setInstanceCoords', exit, coords, prop, OwnedHouse['furniture'])
    DoScreenFadeOut(750)
    while not IsScreenFadedOut() do Wait(0) end
    for i = 1, 25 do
        SetEntityCoords(PlayerPedId(), exit)
        Wait(50)
    end
    while IsEntityWaitingForWorldCollision(PlayerPedId()) do
        SetEntityCoords(PlayerPedId(), exit)
        Wait(50)
    end
    DoScreenFadeIn(1500)
    local in_house = true
    ClearPedWetness(PlayerPedId())
    while in_house do
        NetworkOverrideClockTime(15, 0, 0)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist('EXTRASUNNY')
        SetWeatherTypeNow('EXTRASUNNY')
        SetWeatherTypeNowPersist('EXTRASUNNY')

        -- DrawMarker(27, exit, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(1.0, 1.0, 1.0), 255, 0, 255, 150, false, false, 2, false, false, false)
        -- DrawMarker(27, storage, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(1.0, 1.0, 1.0), 255, 0, 255, 150, false, false, 2, false, false, false)
        if Vdist2(GetEntityCoords(PlayerPedId()), storage) <= 2.0 then
            HelpText('[E] Depo', storage)
            if IsControlJustReleased(0, 38) and Vdist2(GetEntityCoords(PlayerPedId()), storage) <= 2.0 then
                ESX.UI.Menu.CloseAll()

                TriggerEvent("disc-inventoryhud:stash", "Depo Ev - "..tostring(OwnedHouse.houseId))
                

            end
        end
        if Vdist2(GetEntityCoords(PlayerPedId()), exit) <= 1.5 then
            HelpText('[E] - Evini Yönet', exit)
            if IsControlJustReleased(0, 38) then
                ESX.UI.Menu.CloseAll()

                local elements = {
                    {label = 'Evden Cık', value = 'exit'},
                }

                ESX.UI.Menu.Open(
                    'default', GetCurrentResourceName(), 'manage_door',
                {
                    title = Strings['Manage_Door'],
                    align = 'right',
                    elements = elements,
                },
                function(data, menu)
                    if data.current.value == 'exit' then
                        ESX.TriggerServerCallback('loaf_housing:hasGuests', function(has)
                            if not has then
                                ESX.UI.Menu.CloseAll()
                                TriggerServerEvent('loaf_housing:deleteInstance')
                                Wait(3500)
                                TriggerEvent('luck_weed:inhouse', false)
                                in_house = false
                                return
                            else
                                ESX.ShowNotification(Strings['Guests'])
                            end
                        end)
                    end
                end, 
                    function(data, menu)
                    menu.close()
                end)
            end
        end
        Wait(0)
    end
    DeleteObject(house)
    for k, v in pairs(placed_furniture) do
        DeleteObject(v)
    end
end)

RegisterNetEvent('loaf_housing:leaveHouse')
AddEventHandler('loaf_housing:leaveHouse', function(house)
    DoScreenFadeOut(750)
    while not IsScreenFadedOut() do Wait(0) end
    SetEntityCoords(PlayerPedId(), Config.Houses[house]['door'])
    for i = 1, 25 do
        SetEntityCoords(PlayerPedId(),  Config.Houses[house]['door'])
        Wait(50)
    end
    while IsEntityWaitingForWorldCollision(PlayerPedId()) do
        SetEntityCoords(PlayerPedId(), Config.Houses[house]['door'])
        Wait(50)
    end
    DoScreenFadeIn(1500)
end)


RegisterNetEvent('loaf_housing:reloadHouses')
AddEventHandler('loaf_housing:reloadHouses', function()
    while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Wait(0) end
    while ESX.GetPlayerData().job == nil do Wait(0) end
    TriggerServerEvent('loaf_housing:getOwned')
end)


RegisterNetEvent('loaf_housing:setHouse')
AddEventHandler('loaf_housing:setHouse', function(house, purchasedHouses)
    OwnedHouse = house

    for k, v in pairs(blips) do
        RemoveBlip(v)
    end

    for k, v in pairs(purchasedHouses) do
        if v.houseid ~= OwnedHouse.houseId then
            AvailableHouses[v.houseid] = v.houseid
        end
    end

    for k, v in pairs(Config.Houses) do
        if OwnedHouse.houseId == k then
            CreateBlip(v['door'], 40, 3, 0.75, Strings['Your_House'])
        else
            if not AvailableHouses[k] then
                if Config.AddHouseBlips then
                    CreateBlip(v['door'], 374, 0, 0.45, '')
                end
            else
                if Config.AddBoughtHouses then
                    CreateBlip(v['door'], 374, 2, 0.45, Strings['Player_House'])
                end
            end
        end
    end
end)

EnterHouse = function(prop, coords)
    local obj = CreateObject(prop, coords, false)
    FreezeEntityPosition(obj, true)
    return obj
end

HelpText = function(msg, coords)
    if not coords or not Config.Use3DText then
        AddTextEntry(GetCurrentResourceName(), msg)
        DisplayHelpTextThisFrame(GetCurrentResourceName(), false)
    else
        DrawText3D(coords, string.gsub(msg, "~INPUT_CONTEXT~", "~r~[~w~E~r~]~w~"), 0.35)
    end
end

CreateBlip = function(coords, sprite, colour, scale, text)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    table.insert(blips, blip)
end


