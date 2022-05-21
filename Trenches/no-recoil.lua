-- init 
local GetService, IsLoaded, Loaded = game.GetService, game.IsLoaded, game.Loaded; do 
    if not IsLoaded(game) then 
        Loaded.Wait(Loaded);
    end
end

-- variables
local Client = GetService(game, "Players").LocalPlayer;
local FindFirstChild, WaitForChild = game.FindFirstChild, game.WaitForChild;
local IsA, Connect = game.IsA, Loaded.Connect;

-- functions 
function ChildAddedEvent(Child)
    if Child and IsA(Child, "Tool") and Child.Name == "Rifle" then 
        local LocalGunHeld = FindFirstChild(Child, "LocalGunHeld");
        if not LocalGunHeld then return end 
        
        table.foreach(getsenv(LocalGunHeld), function(Index, Value)
            if tostring(Index) == "ShakeCamera" and type(Value) == "function" then 
                if getupvalue(Value, 1) and type(getupvalue(Value, 1)) == "table" then  
                    table.foreach(getupvalue(Value, 1), function(Index, Value)
                        if tostring(Index) == "Initiate" and type(Value) == "function" then 
                            hookfunction(Value, function()
                                return
                            end)
                        end
                    end)
                end
            end
        end)
    end
end; Connect(Client.Character.ChildAdded, ChildAddedEvent);

function CharacterAddedEvent(Character)
    WaitForChild(Character, "Humanoid");
    
    Connect(Character.ChildAdded, ChildAddedEvent)
end; Connect(Client.CharacterAdded, CharacterAddedEvent);
