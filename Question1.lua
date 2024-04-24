-- Original
local function releaseStorage(player)
    player:setStorageValue(1000, -1)
end

function onLogout(player)
    if player:getStorageValue(1000) == 1 then
        addEvent(releaseStorage, 1000, player)
    end
    return true
end


-- This question seemed like it requires specific engine knowledge to answer.
-- What's 'player'? How does addEvent work? Digging around the otland forums, 
-- I found this post which mentions our 'player' argument may be unsafe to 
-- pass to addEvent: https://otland.net/threads/spell-error-addevent-argument-3-is-unsafe.287469/post-2741241
-- To fix it, we can pass the ID instead, and re-get the player in releaseStorage.

-- Modified
local function releaseStorage(playerId)
    local player = Player(playerId)
    player:setStorageValue(1000, -1)
end

function onLogout(player)
    if player:getStorageValue(1000) == 1 then
        addEvent(releaseStorage, 1000, player:getId())
    end
    return true
end
