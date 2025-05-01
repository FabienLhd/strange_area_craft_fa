local craftingPlayers = {}
local playerProgression = {}

-- Chargement de ESX
local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

while ESX == nil do
    Wait(0)
end

-- Lorsqu'un joueur se connecte, envoyer ses données de progression
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local identifier = xPlayer.identifier

    getPlayerProgression(identifier, function(palierCrafted, totalCrafted)
        sendProgressionToClient(playerId, palierCrafted, totalCrafted)
    end)
end)

-- Fonction pour envoyer la progression actuelle au client
function sendProgressionToClient(source, palierCrafted, totalCrafted)
    if not source or not palierCrafted or not totalCrafted then
        print("Erreur : Données invalides lors de l'envoi de la progression au client.")
        return
    end

    TriggerClientEvent("strange_area_craft_fa:updateProgression", source, palierCrafted, totalCrafted)
    Wait(500)
end

-- Fonction pour obtenir la progression d'un joueur
function getPlayerProgression(identifier, callback)
    exports.oxmysql:query('SELECT palier_craft_fa, total_craft_fa FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result and result[1] then
            local palierCrafted = tonumber(result[1].palier_craft_fa) or 0
            local totalCrafted = tonumber(result[1].total_craft_fa) or 0

            -- Sauvegarde dans playerProgression
            playerProgression[identifier] = {
                palierCrafted = palierCrafted,
                totalCrafted = totalCrafted
            }

            if callback then
                callback(palierCrafted, totalCrafted)
            end
        else
            playerProgression[identifier] = {
                palierCrafted = 0,
                totalCrafted = 0
            }

            if callback then
                callback(0, 0)
            end
        end
    end)
end

-- Fonction pour sauvegarder la progression en bdd
function savePlayerProgression(identifier)
    local progression = playerProgression[identifier]
    if not progression or not progression.palierCrafted or not progression.totalCrafted then
        return
    end

    exports.oxmysql:query('UPDATE users SET palier_craft_fa = @palierCrafted, total_craft_fa = @totalCrafted WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['@palierCrafted'] = progression.palierCrafted,
        ['@totalCrafted'] = progression.totalCrafted
    }, function(result)
        if result and result.affectedRows and result.affectedRows > 0 then
            sendProgressionToClient(identifier, progression.palierCrafted, progression.totalCrafted)
        else
            print("Erreur : La progression n'a pas été sauvegardée.")
        end
    end)
end

-- Envoi la progression actuelle du joueur
RegisterServerEvent("strange_area_craft_fa:requestProgression")
AddEventHandler("strange_area_craft_fa:requestProgression", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        print("Erreur : Impossible de récupérer le joueur avec l'ID source", src)
        return
    end

    local identifier = xPlayer.identifier

    if not identifier then
        print("Erreur : Impossible de récupérer l'identifiant pour le joueur avec l'ID source", src)
        return
    end

    -- Appel de la fonction pour récupérer la progression
    getPlayerProgression(identifier, function(palierCrafted, totalCrafted)
        if palierCrafted == nil then
            palierCrafted = 0
        end
        if totalCrafted == nil then
            totalCrafted = 0
        end

        sendProgressionToClient(src, palierCrafted, totalCrafted)
    end)
end)

-- Event pour gérer le craft
RegisterServerEvent('strange_area_craft_fa:attemptCraft')
AddEventHandler('strange_area_craft_fa:attemptCraft', function(itemName, craftingZone)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local playerSource = source

    -- Vérification que la recette existe pour l'item
    local recipe = Config.CraftingRecipes[itemName]
    if not recipe then
        print("Erreur : Recette non trouvée pour l'item '" .. itemName .. "'")
        TriggerClientEvent('esx:showNotification', playerSource, '~r~Recette introuvable pour cet item.')
        return
    end

    -- Vérification si l'item est une arme et si le joueur la possède déjà
    if string.find(recipe.itemName, "WEAPON_") then
        if xPlayer.hasWeapon(recipe.itemName) then
            -- Si le joueur a déjà l'arme, on l'informe et on arrête le processus
            TriggerClientEvent('esx:showNotification', playerSource, '~r~Vous possédez déjà cette arme.')
            return
        end
    end

    -- Récupérer la progression avant d'exécuter le craft
    getPlayerProgression(identifier, function(palierCrafted, totalCrafted)
        if not palierCrafted then
            print("Erreur : La progression du joueur est invalide.")
            TriggerClientEvent('esx:showNotification', playerSource, '~r~Erreur lors de la récupération de la progression.')
            return
        end

        -- Vérifier si le joueur a les matériaux nécessaires
        local canCraft = true
        for _, material in pairs(recipe.materials) do
            if xPlayer.getInventoryItem(material.name).count < material.quantity then
                canCraft = false
                break
            end
        end

        if not canCraft then
            TriggerClientEvent('esx:showNotification', playerSource, '~r~Vous n\'avez pas les matériaux nécessaires pour cette recette.')
            return
        end

        -- Lancement du processus de craft
        TriggerClientEvent('esx:showNotification', playerSource, 'Fabrication de ~g~' .. recipe.label .. ' ~s~en cours...')

        local craftingDuration = craftingZone == "armes" and 60000 or 10000
        TriggerClientEvent('strange_area_craft_fa:startCraftingAnimation', playerSource, craftingDuration / 1000)

        -- Déclencher le craft après le délai
        craftingPlayers[playerSource] = true
        SetTimeout(craftingDuration, function()
            if not craftingPlayers[playerSource] then
                return
            end
        
            craftingPlayers[playerSource] = nil
        
            for _, material in pairs(recipe.materials) do
                xPlayer.removeInventoryItem(material.name, material.quantity)
            end
        
            if string.find(itemName, "WEAPON_") then
                local planName = ""
            
                -- Vérifie d'abord les types plus spécifiques
                if string.find(itemName, "MACHINE") or string.find(itemName, "SMG") then
                    planName = "plan_autogun"
                elseif string.find(itemName, "SHOTGUN") then
                    planName = "plan_shotgun"
                elseif string.find(itemName, "PISTOL") then
                    planName = "plan_handgun"
                end
            
                print("Nom de l'item : " .. itemName)
                print("Plan requis : " .. planName)
            
                if planName ~= "" then
                    local playerPlan = xPlayer.getInventoryItem(planName)
            
                    print("Nombre dans l'inventaire : " .. (playerPlan and playerPlan.count or 0))
            
                    if playerPlan and playerPlan.count > 0 then
                        xPlayer.removeInventoryItem(planName, 1)
                    else
                        TriggerClientEvent('esx:showNotification', playerSource, '~r~Vous n\'avez pas le plan requis pour cette arme.')
                        return
                    end
                end
            end            
            
            -- Ajouter l'arme ou l'item au joueur
            local xPlayerAfterDelay = ESX.GetPlayerFromId(playerSource)
            if not xPlayerAfterDelay then
                print("Erreur : joueur non trouvé après le délai.")
                return
            end
        
            if string.find(recipe.itemName, "WEAPON_") then
                xPlayerAfterDelay.addWeapon(recipe.itemName, 0)
                TriggerClientEvent('esx:showNotification', playerSource, 'Vous avez fabriqué ~g~' .. recipe.label .. ' ~s~et ajouté à votre arsenal.')
            else
                xPlayerAfterDelay.addInventoryItem(recipe.itemName, recipe.quantity)
                TriggerClientEvent('esx:showNotification', playerSource, 'Vous avez fabriqué ~g~' .. recipe.label)
            end
        
            -- Incrémenter la progression uniquement pour la zone "armes"
            if craftingZone == "armes" then
                playerProgression[identifier].totalCrafted = playerProgression[identifier].totalCrafted + 1
        
                local newPalier = 0
        
                for tier, threshold in ipairs(Config.CraftingTiers) do
                    if playerProgression[identifier].totalCrafted >= threshold then
                        newPalier = tier
                    end
                end
        
                playerProgression[identifier].palierCrafted = newPalier
        
                savePlayerProgression(identifier)
            end
        end)
    end)
end)

-- Event pour cancel le craft
RegisterServerEvent('strange_area_craft_fa:cancelCraft')
AddEventHandler('strange_area_craft_fa:cancelCraft', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if craftingPlayers[source] then
        craftingPlayers[source] = nil
    end
end)