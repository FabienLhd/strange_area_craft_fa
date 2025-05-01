ESX = nil
local isMenuOpen = false
local isWeaponMenuOpen = false
local playerPalier = 0
local playerTotal = 0
local isProgressionLoaded = false
local isCrafting = false

-- Initialiser ESX et blips (période test)
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    local blip = AddBlipForCoord(Config.PNJCoords)
    SetBlipSprite(blip, Config.Blip.Sprite)
    SetBlipScale(blip, Config.Blip.Scale)
    SetBlipColour(blip, Config.Blip.Colour)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.Name)
    EndTextCommandSetBlipName(blip)
end)

-- Boucle pour afficher les cercles et détecter la proximité
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Détection de la première zone de craft des pièces d'armes
        local dist = #(playerCoords - vector3(Config.CraftZone.x, Config.CraftZone.y, Config.CraftZone.z))
        if dist < Config.CraftZone.radius then
            isNearCraftZone = true
            DrawMarker(25, Config.CraftZone.x, Config.CraftZone.y, Config.CraftZone.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6, 0.6, 0, 110, 255, 200, false, false, 2, nil, nil, false)
            ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour utiliser les ~b~outils~s~')

            if IsControlJustReleased(0, 38) then
                OpenCraftMenu()
            end
        else
            isNearCraftZone = false
        end

        -- Détection de la deuxième zone de craft des armes
        local distWeapon = #(playerCoords - vector3(Config.WeaponCraftZone.x, Config.WeaponCraftZone.y, Config.WeaponCraftZone.z))
        if distWeapon < Config.WeaponCraftZone.radius then
            isNearWeaponCraftZone = true
            DrawMarker(25, Config.WeaponCraftZone.x, Config.WeaponCraftZone.y, Config.WeaponCraftZone.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6, 0.6, 0, 110, 255, 200, false, false, 2, nil, nil, false)
            ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour accéder aux ~b~outils~s~')

            if IsControlJustReleased(0, 38) then
                OpenWeaponMenu()
            end
        else
            isNearWeaponCraftZone = false
        end

        Citizen.Wait(0)
    end
end)

-- Fonction pour vérifier si le joueur a le plan requis
function HasPlan(planName)
    local playerData = ESX.GetPlayerData()
    local inventory = playerData.inventory

    for i=1, #inventory, 1 do
        if inventory[i].name == planName and inventory[i].count > 0 then
            return true
        end
    end
    return false
end

-- Fonction pour vérifier si le joueur a le palier requis
function HasRequiredTier(itemName)
    if not isProgressionLoaded then
        return false
    end

    local playerData = ESX.GetPlayerData()
    local palier = playerPalier or 0
    local recipe = Config.CraftingRecipes[itemName]

    -- Débug pour afficher les informations sur le palier et la recette
    if recipe then
        if palier >= recipe.requiredTier then
            return true
        else
            return false
        end
    else
        print("DEBUG : Recette non trouvée pour l'arme:", itemName)
    end

    return false
end

-- Fonction côté client pour mettre à jour la progression une fois qu'elle est reçue
RegisterNetEvent("strange_area_craft_fa:updateProgression")
AddEventHandler("strange_area_craft_fa:updateProgression", function(palierCrafted, totalCrafted)
    if not palierCrafted or not totalCrafted then
        print("Erreur : Données de progression invalides reçues.", palierCrafted, totalCrafted)
        return
    end

    if type(palierCrafted) ~= "number" or type(totalCrafted) ~= "number" then
        return
    end

    playerPalier = palierCrafted
    playerTotal = totalCrafted
    isProgressionLoaded = true
end)

-- Fonction pour obtenir la liste des matériaux nécessaires pour un craft
function GetMaterialsString(itemName)
    local recipe = Config.CraftingRecipes[itemName]
    if recipe and recipe.materials then
        local materialsString = ""
        for _, material in ipairs(recipe.materials) do
            materialsString = materialsString .. material.label .. " x" .. material.quantity .. ", "
        end
        return materialsString:sub(1, -3)
    end
    return "Aucun matériau requis"
end

-- Fonction pour vérifier si le joueur a les matériaux nécessaires pour craft
function HasRequiredMaterials(materials)
    local playerData = ESX.GetPlayerData()
    local inventory = playerData.inventory

    for _, material in pairs(materials) do
        local hasMaterial = false

        for _, item in ipairs(inventory) do
            if item.name == material.name and item.count >= material.quantity then
                hasMaterial = true
                break
            end
        end

        if not hasMaterial then
            return false
        end
    end

    return true
end

-- Sous menus pour zone craft pièces d'armes
local firstMenu = RageUI.CreateMenu("Types de pièces d\'armes", "Types de pièces d\'armes")
local subMenuPistolPieces = RageUI.CreateSubMenu(firstMenu, "Pistolet", "Pièces de pistolet")
local subMenuAutoPieces = RageUI.CreateSubMenu(firstMenu, "Armes automatiques", "Pièces d'armes automatiques")
local subMenuPumpPieces = RageUI.CreateSubMenu(firstMenu, "Fusils à pompe", "Pièces de fusils à pompe")
local subMenuChargers = RageUI.CreateSubMenu(firstMenu, "Munitions", "Munitions")

-- Fonction pour ouvrir le menu de craft de pièces d'armes
function OpenCraftMenu()
    TriggerServerEvent("strange_area_craft_fa:requestProgression")
   
    Citizen.CreateThread(function()
        while not isProgressionLoaded do
            Citizen.Wait(500)
        end
    
        if not isMenuOpen then
            isMenuOpen = true
            RageUI.Visible(firstMenu, true)

            Citizen.CreateThread(function()
                while isMenuOpen do
                    RageUI.IsVisible(firstMenu, function()
                        RageUI.Button("Pièces de pistolets", nil, {RightLabel = "→→"}, HasPlan('plan_handgun') and HasRequiredTier('WEAPON_SNSPISTOL'), {}, subMenuPistolPieces)
                        RageUI.Button("Pièces d'armes automatiques", nil, {RightLabel = "→→"}, HasPlan('plan_autogun') and HasRequiredTier('WEAPON_MACHINEPISTOL'), {}, subMenuAutoPieces)
                        RageUI.Button("Pièces de fusils à pompe", nil, {RightLabel = "→→"}, HasPlan('plan_shotgun') and HasRequiredTier('WEAPON_DBSHOTGUN'), {}, subMenuPumpPieces)
                        RageUI.Button("Munitions", nil, {RightLabel = "→→"}, HasRequiredTier('WEAPON_SNSPISTOL'), {}, subMenuChargers)
                    end)

                    RageUI.IsVisible(subMenuPistolPieces, function()
                        RageUI.Button("Canon pistolet", GetMaterialsString("barrel_handgun"), {}, HasPlan('plan_handgun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("barrel_handgun")
                                CraftItem("barrel_handgun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Culasse pistolet", GetMaterialsString("slide_handgun"), {}, HasPlan('plan_handgun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("slide_handgun")
                                CraftItem("slide_handgun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Crosse pistolet", GetMaterialsString("grip_handgun"), {}, HasPlan('plan_handgun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("grip_handgun")
                                CraftItem("grip_handgun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Gâchette pistolet", GetMaterialsString("trigger_handgun"), {}, HasPlan('plan_handgun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("trigger_handgun")
                                CraftItem("trigger_handgun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Percuteur pistolet", GetMaterialsString("hammer_handgun"), {}, HasPlan('plan_handgun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("hammer_handgun")
                                CraftItem("hammer_handgun", materialsString, "pieces")
                            end
                        })
                    end)

                    RageUI.IsVisible(subMenuChargers, function()
                        RageUI.Button("Munitions pistolet et pistolet mitrailleur", GetMaterialsString("ammo_pistol"), {}, HasRequiredTier('WEAPON_SNSPISTOL'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("ammo_pistol")
                                CraftItem("ammo_pistol", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Munitions fusil à pompe", GetMaterialsString("ammo_shotgun"), {}, HasRequiredTier('WEAPON_DBSHOTGUN'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("ammo_shotgun")
                                CraftItem("ammo_shotgun", materialsString, "pieces")
                            end
                        })
                    end)

                    RageUI.IsVisible(subMenuAutoPieces, function()
                        RageUI.Button("Canon arme automatique", GetMaterialsString("barrel_autogun"), {}, HasPlan('plan_autogun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("barrel_autogun")
                                CraftItem("barrel_autogun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Culasse arme automatique", GetMaterialsString("slide_autogun"), {}, HasPlan('plan_autogun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("slide_autogun")
                                CraftItem("slide_autogun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Crosse arme automatique", GetMaterialsString("grip_autogun"), {}, HasPlan('plan_autogun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("grip_autogun")
                                CraftItem("grip_autogun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Gâchette arme automatique", GetMaterialsString("trigger_autogun"), {}, HasPlan('plan_autogun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("trigger_autogun")
                                CraftItem("trigger_autogun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Percuteur arme automatique", GetMaterialsString("hammer_autogun"), {}, HasPlan('plan_autogun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("hammer_autogun")
                                CraftItem("hammer_autogun", materialsString, "pieces")
                            end
                        })
                    end)

                    RageUI.IsVisible(subMenuPumpPieces, function()
                        RageUI.Button("Canon fusil à pompe", GetMaterialsString("barrel_shotgun"), {}, HasPlan('plan_shotgun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("barrel_shotgun")
                                CraftItem("barrel_shotgun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Culasse fusil à pompe", GetMaterialsString("slide_shotgun"), {}, HasPlan('plan_shotgun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("slide_shotgun")
                                CraftItem("slide_shotgun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Crosse fusil à pompe", GetMaterialsString("grip_shotgun"), {}, HasPlan('plan_shotgun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("grip_shotgun")
                                CraftItem("grip_shotgun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Gâchette fusil à pompe", GetMaterialsString("trigger_shotgun"), {}, HasPlan('plan_shotgun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("trigger_shotgun")
                                CraftItem("trigger_shotgun", materialsString, "pieces")
                            end
                        })
                        RageUI.Button("Percuteur fusil à pompe", GetMaterialsString("hammer_shotgun"), {}, HasPlan('plan_shotgun'), {
                            onSelected = function()
                                local materialsString = GetMaterialsString("hammer_shotgun")
                                CraftItem("hammer_shotgun", materialsString, "pieces")
                            end
                        })
                    end)

                    Citizen.Wait(0)
                end
            end)
        end
    end)
end

-- Sous menus pour zone craft armes avec pièces d'armes
local secondMenu = RageUI.CreateMenu("Types d'armes", "Type d'armes")
local subMenuPistols = RageUI.CreateSubMenu(secondMenu, "Pistolets", "Pistolets")
local subMenuPumps = RageUI.CreateSubMenu(secondMenu, "Fusils à pompe", "Fusils à pompe")
local subMenuAutos = RageUI.CreateSubMenu(secondMenu, "Armes automatiques", "Armes automatiques")
-- local subMenuExplosifs = RageUI.CreateSubMenu(secondMenu, "Explosifs", "Explosifs")

-- Fonction pour ouvrir le menu de craft d'armes
function OpenWeaponMenu()
     TriggerServerEvent("strange_area_craft_fa:requestProgression")

    Citizen.CreateThread(function()
        while not isProgressionLoaded do
            Citizen.Wait(500)
        end

        if not isWeaponMenuOpen then
            RageUI.Visible(secondMenu, true)
            isWeaponMenuOpen = true

            Citizen.CreateThread(function()
                while isWeaponMenuOpen do
                    Citizen.Wait(0)

                    if not isWeaponMenuOpen then
                        break
                    end

                    -- Contenu principal du menu
                    RageUI.IsVisible(secondMenu, function()
                        local progressionStep = math.floor(tonumber(Config.CraftingTiers[playerPalier + 1]) or 0)
                        local totalArmes = math.floor(tonumber(playerTotal) or 0)
                    
                        RageUI.Separator("Progression : ~y~Palier " .. playerPalier)
                        RageUI.Separator(string.format("Total armes craftées : ~r~%d", totalArmes))
                        RageUI.Separator(string.format("Total armes à crafter pour le prochain palier : ~y~%d", progressionStep))
                    
                        RageUI.Button("Pistolets", nil, {RightLabel = "→→"}, HasPlan('plan_handgun') and HasRequiredTier('WEAPON_SNSPISTOL'), {}, subMenuPistols)
                        RageUI.Button("Armes automatiques", nil, {RightLabel = "→→"}, HasPlan('plan_autogun') and HasRequiredTier('WEAPON_MACHINEPISTOL'), {}, subMenuAutos)
                        RageUI.Button("Fusils à pompe", nil, {RightLabel = "→→"}, HasPlan('plan_shotgun') and HasRequiredTier('WEAPON_DBSHOTGUN'), {}, subMenuPumps)
                        -- RageUI.Button("Explosifs", nil, {RightLabel = "→→"}, HasRequiredTier('WEAPON_PIPEBOMB'), {}, subMenuExplosifs)
                    end)            
                    -- Sous-menu : Pistolets
                    RageUI.IsVisible(subMenuPistols, function()
                        RageUI.Button("Pistolet SNS", nil, {}, HasPlan('plan_handgun') and HasRequiredTier('WEAPON_SNSPISTOL'), {
                            onSelected = function()
                                CraftItem("WEAPON_SNSPISTOL", "armes")
                            end
                        })
                        RageUI.Button("Pistolet", nil, {}, HasPlan('plan_handgun') and HasRequiredTier('WEAPON_PISTOL'), {
                            onSelected = function()
                                CraftItem("WEAPON_PISTOL", "armes")
                            end
                        })
                        RageUI.Button("Pistolet vintage", nil, {}, HasPlan('plan_handgun') and HasRequiredTier('WEAPON_VINTAGEPISTOL'), {
                            onSelected = function()
                                CraftItem("WEAPON_VINTAGEPISTOL", "armes")
                            end
                        })
                        RageUI.Button("Pistolet Cal. 50", nil, {}, HasPlan('plan_handgun') and HasRequiredTier('WEAPON_PISTOL50'), {
                            onSelected = function()
                                CraftItem("WEAPON_PISTOL50", "armes")
                            end
                        })
                    end)

                    -- Sous-menu : Armes automatiques
                    RageUI.IsVisible(subMenuAutos, function()
                        RageUI.Button("Pistolet mitrailleur", nil, {}, HasPlan('plan_autogun') and HasRequiredTier('WEAPON_MACHINEPISTOL'), {
                            onSelected = function()
                                CraftItem("WEAPON_MACHINEPISTOL", "armes")
                            end
                        })
                    end)

                    -- Sous-menu : Fusils à pompe
                    RageUI.IsVisible(subMenuPumps, function()
                        RageUI.Button("Fusil à pompe double canon", nil, {}, HasPlan('plan_shotgun') and HasRequiredTier('WEAPON_DBSHOTGUN'), {
                            onSelected = function()
                                CraftItem("WEAPON_DBSHOTGUN", "armes")
                            end
                        })
                    end)

                    -- -- Sous-menu : Explosifs
                    -- RageUI.IsVisible(subMenuExplosifs, function()
                    --     RageUI.Button("Bombe à tube", GetMaterialsString("WEAPON_PIPEBOMB"), {}, HasRequiredTier('WEAPON_PIPEBOMB'), {
                    --         onSelected = function()
                    --             local materialsString = GetMaterialsString("WEAPON_PIPEBOMB")
                    --             CraftItem("WEAPON_PIPEBOMB", materialsString, "armes")
                    --         end
                    --     })
                    -- end)
                end
                isWeaponMenuOpen = false
            end)
        end
    end)
end

-- Fonction pour effectuer le craft
function CraftItem(item, craftingZone)
    if isCrafting then
        ESX.ShowNotification('~r~Vous êtes déjà en train de fabriquer un objet.')
        return
    end

    local recipe = Config.CraftingRecipes[item]
    if recipe then
        local canCraft = HasRequiredMaterials(recipe.materials)

        if canCraft then
            isCrafting = true
            TriggerServerEvent('strange_area_craft_fa:attemptCraft', item, craftingZone) 

            -- Gestion locale du timer
            local duration = craftingZone == "armes" and 60 or 10 -- 10s pour "armes", 2s pour "pieces"
            Citizen.CreateThread(function()
                Citizen.Wait(duration * 1000)
                isCrafting = false

                if isWeaponMenuOpen then
                    RageUI.CloseAll()
                    Citizen.Wait(500)
                    OpenWeaponMenu()
                end
            end)
        else
            ESX.ShowNotification('~r~Vous n\'avez pas les matériaux nécessaires pour cette recette.')
        end
    end
end

-- Fonction pour démarrer l'animation de craft
RegisterNetEvent('strange_area_craft_fa:startCraftingAnimation')
AddEventHandler('strange_area_craft_fa:startCraftingAnimation', function(duration)
    local playerPed = PlayerPedId()

    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)

    Citizen.Wait(duration * 1000)

    ClearPedTasksImmediately(playerPed)
end)

-- Fonction pour annuler le craft
function CancelCraft()
    if isCrafting then
        isCrafting = false
        ESX.ShowNotification('~r~Action annulée : vous avez quitté la zone de fabrication.')
        ClearPedTasksImmediately(PlayerPedId())
    end
end

-- Fonction pour déterminer si le joueur est trop loin du menu pour le laisser afficher, et s'il ne l'est plus, ça annule le craft
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local distCraft = #(playerCoords - vector3(Config.CraftZone.x, Config.CraftZone.y, Config.CraftZone.z))
        local distWeaponCraft = #(playerCoords - vector3(Config.WeaponCraftZone.x, Config.WeaponCraftZone.y, Config.WeaponCraftZone.z))

        if isMenuOpen and distCraft > 3.0 then
            isMenuOpen = false
            RageUI.Visible(firstMenu, false)
            RageUI.Visible(subMenuPumpPieces, false)
            RageUI.Visible(subMenuAutoPieces, false)
            RageUI.Visible(subMenuPistolPieces, false)
            RageUI.Visible(subMenuChargers, false)
            CancelCraft()
            TriggerServerEvent('strange_area_craft_fa:cancelCraft')
        end

        if isWeaponMenuOpen and distWeaponCraft > 3.0 then
            isWeaponMenuOpen = false
            RageUI.Visible(secondMenu, false)
            RageUI.Visible(subMenuPumps, false)
            RageUI.Visible(subMenuAutos, false)
            RageUI.Visible(subMenuPistols, false)
            RageUI.Visible(subMenuExplosifs, false)
            CancelCraft()
            TriggerServerEvent('strange_area_craft_fa:cancelCraft')
        end

        if isMenuOpen and not RageUI.Visible(firstMenu) and not RageUI.Visible(subMenuPumpPieces) and not RageUI.Visible(subMenuAutoPieces) and not RageUI.Visible(subMenuPistolPieces) and not RageUI.Visible(subMenuChargers) then
            isMenuOpen = false
        end
        if isWeaponMenuOpen and not RageUI.Visible(secondMenu) and not RageUI.Visible(subMenuPumps) and not RageUI.Visible(subMenuAutos) and not RageUI.Visible(subMenuPistols) and not RageUI.Visible(subMenuExplosifs) then
            isWeaponMenuOpen = false
        end

        Citizen.Wait(100)
    end
end)
