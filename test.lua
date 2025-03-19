MainAccUsername = "WINTERMEM3"
PetNames = {"Puptune", "Clover Cow", "Sunglider", "Love Bird", "Sweetheart Rat"}

repeat task.wait(1) until game:IsLoaded()
local RS = game:GetService("ReplicatedStorage")
local ClientData = require(RS.ClientModules.Core.ClientData)
local Player = game:GetService("Players").LocalPlayer

-- Anti-AFK
for i,v in pairs(getconnections(Player.Idled)) do v:Disable() end

function GetInv()
    return ClientData.get_data()[Player.Name].inventory.pets
end

function CreatePetDictionary()
    local petsToTrade = {}
    for _, petName in ipairs(PetNames) do
        for _, entry in pairs(require(RS.ClientDB.Inventory.InventoryDB).pets) do
            if entry.name:lower() == petName:lower() then
                petsToTrade[entry.id] = 999 -- Set to maximum possible
                break
            end
        end
    end
    return petsToTrade
end

while true do
    local petsToTrade = CreatePetDictionary()
    if game.Players:FindFirstChild(MainAccUsername) then
        RS.API["TradeAPI/SendTradeRequest"]:FireServer(MainAccUsername)
        
        local tradeApp = Player.PlayerGui:WaitForChild("TradeApp", 5)
        if tradeApp and tradeApp.Frame.Visible then
            local countA = 0
            
            -- First pass: Mega Neon
            for _, v in pairs(GetInv()) do
                if petsToTrade[v.id] and petsToTrade[v.id] > 0 and v.properties.mega_neon then
                    RS.API["TradeAPI/AddItemToOffer"]:FireServer(v.unique)
                    petsToTrade[v.id] = petsToTrade[v.id] - 1
                    task.wait(0.15)
                    countA += 1
                    if countA >= 18 then break end
                end
            end
            
            -- Second pass: Regular Neon (if slots remaining)
            if countA < 18 then
                for _, v in pairs(GetInv()) do
                    if petsToTrade[v.id] and petsToTrade[v.id] > 0 and v.properties.neon then
                        RS.API["TradeAPI/AddItemToOffer"]:FireServer(v.unique)
                        petsToTrade[v.id] = petsToTrade[v.id] - 1
                        task.wait(0.15)
                        countA += 1
                        if countA >= 18 then break end
                    end
                end
            end

            -- Final confirmation
            if countA > 0 then
                task.wait(0.5)
                RS.API["TradeAPI/AcceptNegotiation"]:FireServer()
                task.wait(0.3)
                RS.API["TradeAPI/ConfirmTrade"]:FireServer()
                print("Traded", countA, "Neon/Mega Neon pets")
            end
        end
    end
    task.wait(3)
end
