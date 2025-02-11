-- just here for documentation purposes

-- services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Plushies = ReplicatedStorage:WaitForChild("PlushieLibrary")

-- variables

local function SpawnPlushy(Plush: string, Amount: number)
    local Goal = 10 + Amount
    local Count = 0
    local Data = Remotes.getData:InvokeServer()
    local Rarity = Plushies.PlushieTools:FindFirstChild(Plush, true).Parent
    local ToSend = {
        [`G4/{Plush}`] = -Amount
    }

    for _,v in Data.Plushies do
        local Target = v[1]
        if not Rarity:FindFirstChild(Target) then continue end
        if Plush == Target then continue end

        local End = Count + v[2]
        local ToAdd = End > Goal and v[2] - (End - Goal) or v[2]
        Count += ToAdd
        ToSend[`G4/{Target}`] = ToAdd
        if Count >= Goal then break end
    end
    
    if Count >= Goal then
        local Result = Remotes.ExchangePlushies:InvokeServer(ToSend)
        warn(Result)
    end
end

SpawnPlushy("ObscureScrumptor Plush", 1)
