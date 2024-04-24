-- Original
function do_sth_with_PlayerParty(playerId, membername)
    player = Player(playerId)
    local party = player:getParty()

    for k,v in pairs(party:getMembers()) do
        if v == Player(membername) then
            party:removeMember(Player(membername))
        end
    end
end


-- First, to name the function, we can look at the contents of the loop.
-- It seems clear that it's looking for a specific member to remove from 
-- the player's party, thus a name like 'removeMemberFromPlayerParty' 
-- seems appropriate.

-- Besides that, there's some cleanup we can do:
--   We use Player(membername) twice per loop iteration, so we should move it
--   to a local. This also gives us a chance to give it a name that doesn't 
--   depend on context.
--   We aren't using k, so we should replace it with '_' per convention.
--   Renaming 'v' to 'member' makes the if statement easier to reason about.

-- Note: I assumed that membername is known to be a valid member before this 
--       call. If this isn't true, we should add an "if memberToRemove" check
--       before the loop.

-- Modified
function removeMemberFromPlayerParty(playerId, membername)
    player = Player(playerId)
    local party = player:getParty()
    local memberToRemove = Player(membername)
    
    for _, member in pairs(party:getMembers()) do
        if member == memberToRemove then
            party:removeMember(memberToRemove)
        end
    end
end
