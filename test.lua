MainAccUsername = "WINTERMEM3" -- Roblox Username of Main Account (Receiver)
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
        for i,v in pairs(ClientData.get_data()[Player.Name].inventory.pets) do
            if v.id == findPetID(petName) and v.properties and (v.properties.neon or v.properties.mega_neon) then 
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

        -- Add Pets
        count = 0
        for _, petName in ipairs(PetNames) do
            for i,v in pairs(ClientData.get_data()[Player.Name].inventory.pets) do
                if v.id == findPetID(petName) and v.properties and (v.properties.neon or v.properties.mega_neon) then        
                    RS.API:FindFirstChild("TradeAPI/AddItemToOffer"):FireServer(v.unique)
                    count += 1
                    if count >= 18 then break end
                end
            end
        end

        -- Accept/Confirm
        while game:GetService("Players").LocalPlayer.PlayerGui.TradeApp.Frame.Visible do
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
            wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            wait(0.1)
        end
    end
    task.wait(1.5)
    print("Waiting for acc")
until InvEmpty()

print("Account Completed.")
