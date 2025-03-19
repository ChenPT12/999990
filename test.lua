MainAccUsername = "Cloerrw92" -- Roblox Username of Main Account (Receiver)
PetNames = {"Puptune", "Clover Cow", "Sunglider", "Love Bird", "Sweetheart Rat"} -- Pet Names (spelling and capitals matter)

repeat task.wait(1) until game:IsLoaded() and game:GetService("ReplicatedStorage"):FindFirstChild("ClientModules") and game:GetService("ReplicatedStorage").ClientModules:FindFirstChild("Core") and game:GetService("ReplicatedStorage").ClientModules.Core:FindFirstChild("UIManager") and game:GetService("ReplicatedStorage").ClientModules.Core.UIManager.Apps:FindFirstChild("TransitionsApp") and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("TransitionsApp") and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("TransitionsApp"):FindFirstChild("Whiteout")

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

repeat
    if game.Players:FindFirstChild(MainAccUsername) and (not InvEmpty()) then
        repeat task.wait(1)
            RS.API:WaitForChild("TradeAPI/SendTradeRequest"):FireServer(game:GetService("Players"):WaitForChild(MainAccUsername))
        until game:GetService("Players").LocalPlayer.PlayerGui.TradeApp.Frame.Visible

        -- Add Pets with Priority on Neon and Mega Neon
        countA = 0
        petsToTrade = {}
        for _, petName in ipairs(PetNames) do
            local petID = findPetID(petName)
            if petID then
                petsToTrade[petID] = (petsToTrade[petID] or 0) + 1
            end
        end

        -- Debugging Output
        print("Starting trade process...")

        for i, v in pairs(require(game.ReplicatedStorage.ClientModules.Core.ClientData).get_data()[game.Players.LocalPlayer.Name].inventory.pets) do
            if petsToTrade[v.id] and petsToTrade[v.id] > 0 then
                if v.properties and v.properties.neon and (not v.properties.mega_neon) then
                    print("Adding Neon Pet: ", v.id, v.unique)
                    RS.API:FindFirstChild("TradeAPI/AddItemToOffer"):FireServer(v.unique)
                    petsToTrade[v.id] = petsToTrade[v.id] - 1
                    task.wait(0.1)
                    countA = countA + 1
                    if countA >= 18 then break end
                elseif v.properties and v.properties.mega_neon then
                    print("Adding Mega Neon Pet: ", v.id, v.unique)
                    RS.API:FindFirstChild("TradeAPI/AddItemToOffer"):FireServer(v.unique)
                    petsToTrade[v.id] = petsToTrade[v.id] - 1
                    task.wait(0.1)
                    countA = countA + 1
                    if countA >= 18 then break end
                end
            end
        end

        for i, v in pairs(require(game.ReplicatedStorage.ClientModules.Core.ClientData).get_data()[game.Players.LocalPlayer.Name].inventory.pets) do
            if petsToTrade[v.id] and petsToTrade[v.id] > 0 then
                print("Adding Regular Pet: ", v.id, v.unique)
                RS.API:FindFirstChild("TradeAPI/AddItemToOffer"):FireServer(v.unique)
                petsToTrade[v.id] = petsToTrade[v.id] - 1
                task.wait(0.1)
                countA = countA + 1
                if countA >= 18 then break end
            end
        end

        -- Accept/Confirm Trade
        if countA > 0 then
            print("Pets added to trade. Confirming...")
            while game:GetService("Players").LocalPlayer.PlayerGui.TradeApp.Frame.Visible do
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                wait(0.1)
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
                wait(0.1)
            end
        else
            print("No pets were added to the trade!")
        end
    end
    task.wait(1.5)
    print("Waiting for acc")
until InvEmpty()

print("Account Completed.")
