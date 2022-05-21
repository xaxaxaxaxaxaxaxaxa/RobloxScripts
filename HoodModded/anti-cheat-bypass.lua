-- init, by xaxa (bypasses anti-silent aim too)
local GetService, IsLoaded, Loaded = game.GetService, game.IsLoaded, game.Loaded; do 
    if not IsLoaded(game) then 
        Loaded.Wait(Loaded);
    end
end

-- variables
local client, connect = GetService(game, "Players").LocalPlayer, Loaded.Connect;

-- main hook
function griefgc(Index, Value)
    if type(Value) == "function" and getfenv(Value).script and getfenv(Value).script.Name == "Camera" then 
        table.foreach(getupvalues(Value), function(Index, Value)
            if type(Value) == "table" then 
                table.foreach(Value, function(Index, Value)
                    if type(Value) == "function" and (tostring(Index) == "DoThings" or tostring(Index) == "Alive") then 
                        hookfunction(Value, function()
                            return
                        end)
                    end
                end)
            end
        end)
    end
end; table.foreach(getgc(), griefgc);

connect(client.CharacterAdded, function()
    table.foreach(getgc(), griefgc);
end);
