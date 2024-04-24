-- Original
function printSmallGuildNames(memberCount)
    -- this method is supposed to print names of all guilds that have less than memberCount max members
    local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
    local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))
    local guildName = result.getString("name")
    print(guildName)
end


-- It seemed clear that we needed to iterate the results of the SELECT query 
-- and print each one. To know how to do this in forgottenserver though, I 
-- had to find examples.

-- Looking around for examples of database usage in forgottenserver, I 
-- found this migrate script: https://github.com/otland/forgottenserver/blob/1fcb5c27e62ff767c969d8eb028380f9f5d3325f/data/migrations/7.lua#L16
-- which shows us that we need to check resultId, free result at the end, 
-- and also shows us how to iterate through the results.

-- Modified
function printSmallGuildNames(memberCount)
    -- this method is supposed to print names of all guilds that have less than memberCount max members
    local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
    local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))
    
    if resultId then
        repeat
            local guildName = result.getString("name")
            print(guildName)
        until not result.next(resultId)
        result.free()
    end
end
