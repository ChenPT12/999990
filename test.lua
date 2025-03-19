MainAccUsername = "WINTERMEM3" -- Roblox Username of Main Account (Receiver)
PetNames = {"Puptune", "Clover Cow", "Sunglider", "Love Bird", "Sweetheart Rat"} -- Pet Names (spelling and capitals matter)

repeat task.wait(1) until game:IsLoaded() and game:GetService("ReplicatedStorage"):FindFirstChild("ClientModules") and game:GetService("ReplicatedStorage").ClientModules:FindFirstChild("Core") and game:GetService("ReplicatedStorage").ClientModules.Core:FindFirstChild("UIManager") and game:GetService("ReplicatedStorage").ClientModules.Core:FindFirstChild("UIManager").Apps:FindFirstChild("TransitionsApp") and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("TransitionsApp") and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("TransitionsApp"):FindFirstChild("Whiteout")
local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = RS
local ClientData = require(RS.ClientModules.Core.ClientData)
local RouterClient = require(RS.ClientModules.Core:WaitForChild("RouterClient"):WaitForChild("RouterClient"))
local Main_Menu = require(RS.ClientModules.Core.UIManager.Apps.MainMenuApp)
local Player = game:GetService("Players").LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do v:Disable() end
for i, v in pairs(debug.getupvalue(RouterClient.init, 7)) do v.Name = i end

function findPetID(petName)
    for _, entry in pairs(require(game:GetService("ReplicatedStorage").ClientDB.Inventory.InventoryDB).pets) do
        if type(entry) == "table" and string.lower(entry.name) == string.lower(petName) then
            return entry.id
        end
    end
    return nil
end

function CheckPetRarity(PetName)
    for _, entry in pairs(require(game:GetService("ReplicatedStorage").ClientDB.Inventory.InventoryDB).pets) do
        if type(entry) == "table" and string.lower(entry.name) == string.lower(PetName) then
            if entry.rarity == "common" then
                return "Common"
            elseif entry.rarity == "uncommon" then 
                return "Uncommon"
            elseif entry.rarity == "rare" then 
                return "Rare"
            elseif entry.rarity == "ultra_rare" then 
                return "Ultra Rare"
            elseif entry.rarity == "legendary" then 
                return "Legendary"
            end
        end
    end
end

function InvEmpty()
    for _, petName in ipairs(PetNames) do
        for i,v in pairs(require(game.ReplicatedStorage.ClientModules.Core.ClientData).get_data()[game.Players.LocalPlayer.Name].inventory.pets) do
            if v.id == findPetID(petName) then 
                return false
            end
        end
    end
    return true
end

-- Added Neon/Mega Trading System
function TradePets()
    repeat task.wait() until game.Players:FindFirstChild(MainAccUsername)
    
    RS.API["TradeAPI/SendTradeRequest"]:FireServer(game.Players[MainAccUsername])
    repeat task.wait() until game.Players.LocalPlayer.PlayerGui.TradeApp.Frame.Visible
    
    -- Add neon/mega pets first
    local added = 0
    for petID, petData in pairs(ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.pets) do
        if petData.properties.neon or petData.properties.mega_neon then
            RS.API["TradeAPI/AddItemToOffer"]:FireServer(petID)
            added += 1
            if added >= 18 then break end
        end
    end

    -- Original pet adding logic as fallback
    if added < 18 then
        for _, petName in ipairs(PetNames) do
            for i,v in pairs(ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.pets) do
                if v.id == findPetID(petName) then        
                    RS.API["TradeAPI/AddItemToOffer"]:FireServer(v.unique)
                    added += 1
                    if added >= 18 then break end
                end
            end
            if added >= 18 then break end
        end
    end

    -- Accept/Confirm
    while game.Players.LocalPlayer.PlayerGui.TradeApp.Frame.Visible do
        RS.API["TradeAPI/AcceptNegotiation"]:FireServer()
        task.wait(0.1)
        RS.API["TradeAPI/ConfirmTrade"]:FireServer()
        task.wait(0.1)
    end
end

repeat
    if game.Players:FindFirstChild(MainAccUsername) and (not InvEmpty()) then
        TradePets() -- Using new trading function
    end
    task.wait(1.5)
    print("Waiting for acc")
until InvEmpty()

print("Account Completed.")
