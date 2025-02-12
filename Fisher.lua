loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua"))()

-- services

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- variables

local Player = Players.LocalPlayer
local Rods = require(ReplicatedStorage.ItemLibrary.Fishing.FishingRods)
local Library   = loadstring(game:HttpGet("https://raw.githubusercontent.com/ObscureScapter/UILibrary/main/ScapLib.lua"))()
local Fishing = Library:CreatePage("Fishing")
local Setting = Library:CreatePage("Settings")
local Remotes = ReplicatedStorage.Remotes
local Baits = require(ReplicatedStorage.ItemLibrary.Fishing.BaitInfo)
local FishGame = require(ReplicatedStorage.Modules.UI.Interfaces.FishMinigame)
local OldBoost = FishGame.checkBoosterOverlay
local MyUI = nil
local FishTimer = nil
local Settings = {
    ["Auto Cast"] = false,
    ["Auto Reel"] = true,
    ["Auto Reel Time"] = 8,
    ["Auto Buy Bait"] = false,
    ["Cast Delay"] = 0.15,
    ["Bobber Delay"] = 0.75,
    ["UI Toggle"] = Enum.KeyCode.Home,
    ["Bait"] = "Uncommon",
}
local FishZones = Workspace.GameAssets.FishingRegions.Ocean:GetChildren()
local PossibleBait = {}

-- functions

for _, Rod in Rods do
    if not Rod.Hidden then continue end
    Rod.Hidden = nil
end

for i,v in Baits do
    PossibleBait[i] = v.Name
end

Player.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

Fishing.CreateToggle("Auto Cast", Settings["Auto Cast"], function(State: boolean)
    Settings["Auto Cast"] = State
end)
Fishing.CreateToggle("Auto Reel", Settings["Auto Reel"], function(State: boolean)
    Settings["Auto Reel"] = State
end)
Fishing.CreateSlider("Auto Reel Time", Settings["Auto Reel Time"], 3.96, 60, function(Count: number)
    Settings["Auto Reel Time"] = Count
end)
Fishing.CreateToggle("Auto Buy Bait", Settings["Auto Buy Bait"], function(State: boolean)
    Settings["Auto Buy Bait"] = State
end)
Fishing.CreateDropdown("Bait", Settings["Bait"], PossibleBait, function(Bait: string)
    Settings["Bait"] = Bait
end)

Setting.CreateSlider("Cast Delay", Settings["Cast Delay"], 0, 1, function(Count: number)
    Settings["Cast Delay"] = Count
end)
Setting.CreateSlider("Bobber Delay", Settings["Bobber Delay"], 0, 1, function(Count: number)
    Settings["Bobber Delay"] = Count
end)
Setting.CreateKeybind("UI Toggle", Settings["UI Toggle"], function(Key: EnumItem)
    Settings["UI Toggle"] = Key
end)

UserInputService.InputBegan:Connect(function(Input: InputObject)
    if Input.KeyCode == Settings["UI Toggle"] then
        Library:ToggleUI()
    end
end)

FishGame.checkBoosterOverlay = function(Minigame: table)
    if Minigame.UI ~= MyUI then
        MyUI = Minigame.UI
        FishTimer = tick() + Settings["Auto Reel Time"]
    end

    if Minigame.UI and Minigame.UI:FindFirstChild("MainBar") and Minigame.UI.MainBar:FindFirstChild("InnerFrame") and Settings["Auto Reel"] then
        local InnerFrame = Minigame.UI.MainBar.InnerFrame
        Minigame.UI.MainBar.Slider.Position = InnerFrame.Position + UDim2.new(0, (InnerFrame.AbsoluteSize.X) / 2, 0, 0)
        Minigame.Depletion = 0

        if tick() - FishTimer >= 0 then
            Minigame.Progress = Minigame.Settings.MaxProgress
            Minigame:EndGame(true)
        end
    elseif not Settings["Auto Reel"] then
        return OldBoost(Minigame)
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
    if Settings["Auto Buy Bait"] then
        local Index = 1

        for i,v in PossibleBait do
            if v == Settings["Bait"] then
                Index = i
                break
            end
        end

        Remotes.ShopRemotes.BuyBait:InvokeServer(Index)
    end

    local Position = Vector3.new(155.38783264160156, -4.067657947540283, 123.40579223632812)
    local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = FishZones

    local Start = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, -15)
    local WaterRay = Workspace:Raycast(Start.Position, Vector3.new(0, -100, 0), Params)
    if WaterRay and WaterRay.Instance then
        Position = WaterRay.Position
    end

    Remotes.ToolAction:FireServer("CastLine", {
        Position = Position
    })

    task.wait(Settings["Bobber Delay"])
    --repeat task.wait() until foundBobber() or Rod:FindFirstChildOfClass("Model")

    Remotes.ToolAction:FireServer("BaitHit", {
        WaterPart = workspace.GameAssets.FishingRegions.Ocean.Water,
        Position = Position
    })

    repeat task.wait() until Rod:FindFirstChildOfClass("Model")
    task.wait(Settings["Cast Delay"])
end

while task.wait(1) do
    if not Settings["Auto Cast"] then continue end
    if not Player.Character then continue end

    local Rod = Player.Character:FindFirstChildOfClass("Tool")
    if not Rod then continue end
	
    local Class = Rod:GetAttribute("ToolClass")
    if not Class or Class ~= "FishingRod" then continue end

    if not Rod:GetAttribute("Active") and Rod:GetAttribute("Enabled") and Rod:FindFirstChildOfClass("Model") then
        castLine(Rod)
    end
end
