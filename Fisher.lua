loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua"))()

-- services

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- variables

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage.Remotes
local FishGame = require(ReplicatedStorage.Modules.UI.Interfaces.FishMinigame)
local OldBoost = FishGame.checkBoosterOverlay
local MyUI = nil
local FishTimer = nil

-- functions

Player.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

FishGame.checkBoosterOverlay = function(Minigame: table)
    if Minigame.UI ~= MyUI then
        MyUI = Minigame.UI
        FishTimer = tick() + 4
    end

    if Minigame.UI and Minigame.UI:FindFirstChild("MainBar") and Minigame.UI.MainBar:FindFirstChild("InnerFrame") then
        local InnerFrame = Minigame.UI.MainBar.InnerFrame
        Minigame.UI.MainBar.Slider.Position = InnerFrame.Position + UDim2.new(0, (InnerFrame.AbsoluteSize.X) / 2, 0, 0)
        Minigame.Depletion = 0

        if tick() - FishTimer >= 0 then
            Minigame:EndGame(true)
        end
    end
end

local function foundBobber()
    local foundBobber = false

    for _,v in Workspace.GameAssets.Runtime:GetChildren() do
        if v.Name ~= "ClonedBait" then continue end
        if not v:FindFirstChild("Root") then continue end
        if not v.Root:FindFirstChild("RopeConstraint") then continue end
        if not v.Root.RopeConstraint.Attachment1 then continue end
        
        if v.Root.RopeConstraint.Attachment1.Name:find(Player.Name) then
            foundBobber = true

            break
        end

    end

    return foundBobber
end

local function castLine(Rod: any?)
    Remotes.ToolAction:FireServer("CastLine", {
        Position = Vector3.new(155.38783264160156, -4.067657947540283, 123.40579223632812)
    })

    task.wait(0.5)
    --repeat task.wait() until foundBobber() or Rod:FindFirstChildOfClass("Model")

    Remotes.ToolAction:FireServer("BaitHit", {
        WaterPart = workspace.GameAssets.FishingRegions.Ocean.Water,
        Position = Vector3.new(155.38783264160156, -4.067657947540283, 123.40579223632812)
    })

    repeat task.wait() until Rod:FindFirstChildOfClass("Model")
    task.wait(0.1)
end

while task.wait(1) do
    if not Player.Character then continue end

    local Rod = Player.Character:FindFirstChildOfClass("Tool")
    if not Rod then continue end
	
    local Class = Rod:GetAttribute("ToolClass")
    if not Class or Class ~= "FishingRod" then continue end

    if not Rod:GetAttribute("Active") and Rod:GetAttribute("Enabled") and Rod:FindFirstChildOfClass("Model") then
        castLine(Rod)
    end
end
