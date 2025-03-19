MainAccUsername = "WINTERMEM1" -- Main account to trade with
PetNames = {"Puptune", "Clover Cow", "Sunglider", "Love Bird", "Sweetheart Rat"} -- Pets to handle

repeat task.wait(1) until game:IsLoaded()
local RS = game:GetService("ReplicatedStorage")
local ClientData = require(RS.ClientModules.Core.ClientData)
local RouterClient = require(RS.ClientModules.Core.RouterClient.RouterClient)

-- Anti-AFK
for _,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do v:Disable() end

-- Pet Processing Functions
function FGPet(petID)
    game:GetService("ReplicatedStorage").API["ToolAPI/Equip"]:InvokeServer(petID)
    repeat task.wait() until ClientData.get_data()[game.Players.LocalPlayer.Name].pet_char_wrappers[1]
    
    while ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.pets[petID].properties.age < 6 do
        local Foods = {}
        for foodID, foodData in pairs(ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.food) do
            if foodData.id == "pet_age_potion" then
                table.insert(Foods, foodID)
            end
        end
        if #Foods == 0 then break end
        RS.API["PetAPI/ConsumeFoodItem"]:FireServer(Foods[1], petID)
        task.wait(1)
    end
end

-- Neon/Mega Creation
function MakeMega(isNeon)
    local validPets = {}
    for petID, petData in pairs(ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.pets) do
        if petData.properties.neon == isNeon and not petData.properties.mega_neon then
            table.insert(validPets, petID)
        end
    end
    
    while #validPets >= 4 do
        local selected = {}
        for i = 1, 4 do
            table.insert(selected, table.remove(validPets, 1))
        end
        RS.API["FusionAPI/FusePets"]:InvokeServer(selected)
        task.wait(1)
    end
end

-- Trading System
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
    
    -- Auto-confirm trade
    while game.Players.LocalPlayer.PlayerGui.TradeApp.Frame.Visible do
        RS.API["TradeAPI/AcceptNegotiation"]:FireServer()
        task.wait(0.1)
        RS.API["TradeAPI/ConfirmTrade"]:FireServer()
        task.wait(0.1)
    end
end
