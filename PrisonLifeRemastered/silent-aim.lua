getgenv().configuration = {
    ToggleKey = "RightAlt", -- the key that toggles the Silent-Aim on and off (to change it, go to - https://create.roblox.com/docs/reference/engine/enums/KeyCode)
    TargetPart = "Head", -- {Head, Body, Random} The part the Silent-Aim targets on your Silent-Aim Target
    
    ShowFOVCircle = true, -- if anyone is inside this Circle, the Silent-Aim will Target them
    FOVCircleRadius = 180, -- how wide the Circle is 
    FOVCircleColor = Color3.fromRGB(103, 89, 179), -- the Color of the FOV Circle
};

-- init 
if not game:IsLoaded() then 
    game.Loaded:Wait();
end

local service, draw = setmetatable({}, {
    __index = function(self, Index)
        assert((Index or game.GetService(game, Index)), string.format("%s is not a Game Service", tostring(Index)));
        return game.GetService(game, Index);
    end
}), Drawing and Drawing.new;

local ToggleKey, TargetPart = configuration.ToggleKey, configuration.TargetPart
local ShowFOVCircle, FOVCircleRadius, FOVCircleColor = configuration.ShowFOVCircle, configuration.FOVCircleRadius, configuration.FOVCircleColor;

local framework = {
    SilentAimEnabled = true,
    SilentAimTarget = nil,
    SilentAimTargetPart = nil 
};

local SilentAimEnabled, SilentAimTarget, SilentAimTargetPart = framework.SilentAimEnabled, framework.SilentAimTarget, framework.SilentAimTargetPart
local FOVCircle = draw("Circle");
FOVCircle.Visible = false
FOVCircle.Filled = false 
FOVCircle.Transparency = 1
FOVCircle.NumSides = 50 
FOVCircle.Thickness = 1
FOVCircle.ZIndex = 999

-- main variables
local players, userInputService, runService, guiService, workspace = service.Players, service.UserInputService, service.RunService, service.GuiService, service.Workspace;
local client, mouse, camera = players.LocalPlayer, players.LocalPlayer:GetMouse(), workspace.CurrentCamera; 

local worldToViewportPoint, getGuiInset = camera.WorldToViewportPoint, guiService.GetGuiInset;
local FindFirstChild, FindFirstChildOfClass = game.FindFirstChild, game.FindFirstChildOfClass;

local vector2, isA = Vector2.new, game.IsA;
local resume, create = coroutine.resume, coroutine.create

local TargetParts = {"Head", "HumanoidRootPart"};

-- script functions 
setmetatable(framework, {
    __call = function(self, caller, arguments)
        if caller == "CanHookRaycast" then 
            return SilentAimEnabled == true and SilentAimTarget ~= nil and SilentAimTargetPart ~= nil
        elseif caller == "GetClosestPlayerToMouse" then 
            assert((arguments or type(arguments) == "number"), "error in GetClosestPlayerToMouse call");
            
            local closestPlayer, closestPart
                
            for index, Player in next, players:GetPlayers() do 
                if Player.Name ~= client.Name and Player.Team ~= client.Team then 
                    local Character = Player.Character 
                    if not Character then continue end 
                    
                    local Humanoid = FindFirstChildOfClass(Character, "Humanoid");
                    if not Humanoid or Humanoid.Health == 0 then continue end 
                    
                    local Part = (TargetPart == "Head" and FindFirstChild(Character, "Head")) or (TargetPart == "Body" and (FindFirstChild(Character, "HumanoidRootPart") or Humanoid.RootPart)) or (TargetPart == "Random" and FindFirstChild(Character, TargetParts[random(1, #TargetParts)]));
                    if not Part then continue end 
                    
                    local viewportPoint, isOnScreen = worldToViewportPoint(camera, Part.Position);
                    if not isOnScreen then continue end 
                    
                    local screenPosition = ((vector2(mouse.X, mouse.Y) - vector2(viewportPoint.X, viewportPoint.Y)).Magnitude);
                    if screenPosition < arguments then closestPlayer, closestPart = Player, Part end
                end
            end
            
            if closestPlayer and closestPart then 
                return closestPlayer, closestPart 
            end
        end
    end
});

resume(create(function() 
    runService.RenderStepped:Connect(function()
        FOVCircle.Visible = ShowFOVCircle and SilentAimEnabled
        FOVCircle.Radius = FOVCircleRadius
        FOVCircle.Color = FOVCircleColor
        FOVCircle.Position = Vector2.new(mouse.X, (mouse.Y + getGuiInset(guiService).Y + 4));
        
        SilentAimTarget, SilentAimTargetPart = framework("GetClosestPlayerToMouse", FOVCircleRadius);
    end);
end))

-- hooks 
local namecall; do 
    namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local namecall_method, arguments = (getnamecallmethod or get_namecall_method)(), {...};

        if (namecall_method == "Raycast" or namecall_method == "raycast") and self == workspace and framework("CanHookRaycast") and (game.PlaceId == 8278412720 and getcallingscript().Name == "ACS_Framework") then 
            arguments[2] = ((SilentAimTargetPart.Position - arguments[1]).Unit * 1000);
        end
        
        return namecall(self, unpack(arguments));
    end));
end

getgenv()["syn_ciazware"] = false
