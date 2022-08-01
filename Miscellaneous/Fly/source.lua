-- init 
if not game:IsLoaded() then 
    game.Loaded:Wait();
end

-- services
local players, runService, userInputService, workspace = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("Workspace");
local client, characterAdded = players.LocalPlayer, players.LocalPlayer.CharacterAdded

local renderStepped, stepped, heartBeat = runService.RenderStepped, runService.Stepped, runService.Heartbeat
local currentCamera = workspace.CurrentCamera 

local inputBegan, inputEnded = userInputService.InputBegan, userInputService.InputEnded

local character = (client.Character or characterAdded:Wait());
local humanoid = (character and character:FindFirstChildOfClass("Humanoid"));
local rootPart = (character and character:FindFirstChild("HumanoidRootPart"));

-- micro-optimizations 
local newInstance = Instance.new
local cframe, vector3 = CFrame.new, Vector3.new 

local w, a, s, d = Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D
local f, equals, minus = Enum.KeyCode.F, Enum.KeyCode.Equals, Enum.KeyCode.Minus

-- miscellaneous 
local fly, flySpeed = false, 0.5

local bodyVelocity, bodyAngularVelocity = newInstance("BodyVelocity"), newInstance("BodyAngularVelocity"); do
    bodyVelocity.Velocity = vector3(0, 0, 0);
    bodyVelocity.MaxForce = vector3(9e9, 9e9, 9e9);
    
    bodyAngularVelocity.AngularVelocity = vector3(0, 0, 0);
    bodyAngularVelocity.MaxTorque = vector3(9e9, 9e9, 9e9);
end

-- functions 
function canFly()
    return character and rootPart and humanoid and humanoid.Health > 0 
end

-- events 
characterAdded:Connect(function(Character)
    character = Character
    humanoid = character:WaitForChild("Humanoid");
    rootPart = character:WaitForChild("HumanoidRootPart");
end);

inputBegan:Connect(function(key)
    if userInputService:GetFocusedTextBox() then return end 
    
    if key.KeyCode == f then 
        fly = not fly 
        
        if canFly() then 
            bodyVelocity.Parent = ((fly == true and rootPart) or nil);
            bodyAngularVelocity.Parent = bodyVelocity.Parent
            
            if not fly then 
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true);
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true); -- turn the states back on so you dont spin around when you unfly
                
                task.wait();
                
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false);
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp);
            end
        end
    elseif key.KeyCode == equals then 
        flySpeed = flySpeed + 0.1
    elseif key.KeyCode == minus then
        flySpeed = flySpeed - 0.1
    end
end);

heartBeat:Connect(function()
    local cameraLookVector = (currentCamera and currentCamera.CFrame.LookVector);
    
    if not (character or rootPart or humanoid or humanoid.Health > 0 or cameraLookVector) then 
        fly = false 
        return 
    end 
    
    if fly then 
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false);
        
        rootPart.Velocity = vector3(0, 0, 0);
        rootPart.CFrame = cframe(rootPart.Position, rootPart.Position + cameraLookVector); -- so you dont have to write this out every single time
        
        if not userInputService:GetFocusedTextBox() then 
            if userInputService:IsKeyDown(w) then 
                rootPart.CFrame = (rootPart.CFrame * cframe(0, 0, -flySpeed));
            end 
            
            if userInputService:IsKeyDown(a) then 
                rootPart.CFrame = (rootPart.CFrame * cframe(-flySpeed, 0, 0));
            end
            
            if userInputService:IsKeyDown(s) then 
                rootPart.CFrame = (rootPart.CFrame * cframe(0, 0, flySpeed));
            end
            
            if userInputService:IsKeyDown(d) then 
                rootPart.CFrame = (rootPart.CFrame * cframe(flySpeed, 0, 0));
            end
        end
    end
end);
