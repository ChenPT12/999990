MainAccUsername = "WINTERMEM3"
PetNames = {"Puptune", "Clover Cow", "Sunglider", "Love Bird", "Sweetheart Rat"}

repeat task.wait(1) until game:IsLoaded()
local RS = game:GetService("ReplicatedStorage")
local ClientData = require(RS.ClientModules.Core.ClientData)
local Player = game:GetService("Players").LocalPlayer

-- Anti-AFK
for i,v in pairs(getconnections(Player.Idled)) do v:Disable() end

function findPetID(petName)
    local petDB = require(RS.ClientDB.Inventory.InventoryDB).pets
    for _, entry in pairs(petDB) do
        if type(entry) == "table" and entry.name:lower() == petName:lower() then
            return entry.id
        end
    end
    return nil
end

function GetPetsToTrade()
    local pets = {}
    local inventory = ClientData.get_data()[Player.Name].inventory.pets
    for _, petName in ipairs(PetNames) do
        local targetID = findPetID(petName)
        for _, petData in pairs(inventory) do
            if petData.id == targetID and petData.properties then
                if petData.properties.neon or petData.properties.mega_neon then
                    table.insert(pets, petData)
                end
            end
        end
    end
    return pets
end

while true do
    local petsToTrade = GetPetsToTrade()
    if #petsToTrade > 0 and game.Players:FindFirstChild(MainAccUsername) then
        -- Initiate trade
        RS.API["TradeAPI/SendTradeRequest"]:FireServer(MainAccUsername)
        
        -- Wait for trade window to fully load
        local tradeFrame = Player.PlayerGui:WaitForChild("TradeApp", 5).Frame
        if tradeFrame and tradeFrame.Visible then
            -- Add items with proper delays
            for i, pet in ipairs(petsToTrade) do
                if i > 18 then break end
                RS.API["TradeAPI/AddItemToOffer"]:FireServer(pet.unique)
                task.wait(0.25) -- Important delay between additions
            end

            -- Confirm trade
            task.wait(1)
            RS.API["TradeAPI/AcceptNegotiation"]:FireServer()
            task.wait(0.5)
            RS.API["TradeAPI/ConfirmTrade"]:FireServer()
            
            -- Wait for trade completion
            repeat task.wait() until not tradeFrame.Visible
            print("Trade completed with", #petsToTrade, "pets")
        end
    end
    task.wait(5) -- Cooldown between trade attempts
end
