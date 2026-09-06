local Games = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Homebuu/Godmyhxnd-script/refs/heads/main/Godmyhxnd.lua"
))()

local Script = Games[game.GameId]

if Script then
    if Script:match("^https?://") then
        loadstring(game:HttpGet(Script))()
    else
        loadstring(Script)()
    end
end
