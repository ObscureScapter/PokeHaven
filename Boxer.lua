-- services

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- variables

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Blocking = false
local BlockCooldown = tick()

-- functions

RunService.RenderStepped:connect(function()
    local DoAttack = {}
    local DoBlock = false

    for _,v in Players:GetPlayers() do
        if v == Player then continue end
        if not v.Character then continue end
        if not v.Character:FindFirstChild("Humanoid") then continue end
        if not v.Character:FindFirstChild("HumanoidRootPart") then continue end
        if not v.Character:FindFirstChild("Punch") then continue end

        local Distance = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
        if Distance <= 5.35 then
           table.insert(DoAttack, v.Character.Humanoid)
        end

        if Distance <= 8 then
            if v.Character.RightHand:FindFirstChild("Sound") or v.Character.LeftHand:FindFirstChild("Sound") then
                DoBlock = true
           end

            local Animations = v.Character.Humanoid:GetPlayingAnimationTracks()
            for _,c in Animations do
                if c.IsPlaying and (c.Name == "Swing1" or c.Name == "Swing2") then
                    DoBlock = true

                    break
                end
            end

            if DoBlock then break end
        end
    end

    if Blocking and tick() - BlockCooldown >= 3 and DoBlock then
        Blocking = true
        BlockCooldown = tick()
        Remotes.ClientToServer:FireServer("Block", "Punch")

        task.wait(3)
        if tick() - BlockCooldown >= 3 then
            Blocking = false
        end
    elseif #DoAttack > 0 and (not Blocking or tick() - BlockCooldown >= 3) then
        Blocking = false

        Remotes.ClientToServer:FireServer("Attack", "Punch")
        for _,v in DoAttack do
            Remotes.ClientToServer:FireServer("PlayerHit", "Punch", v)
        end
    end
end)
