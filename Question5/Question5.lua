-- Question 5 - Spell script.

-- The number of times that we'll update the spell effect.
local UPDATE_COUNT = 10

-- Build an array of area templates.
local areas = {}
for i = 1, UPDATE_COUNT do
    areas[i] = {
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 1, 0, 1, 0, 0},
        {0, 1, 0, 1, 0, 1, 0},
        {1, 0, 1, 2, 1, 0, 1},
        {0, 1, 0, 1, 0, 1, 0},
        {0, 0, 1, 0, 1, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
    }
end

-- Fill the areas with random values.
-- (We need to set the seed so that the spell is always consistent).
math.randomseed(42)
for i = 1, #areas do
    for j = 1, #areas[i] do
        for k = 1, #areas[i][j] do
            if areas[i][j][k] == 1 then
                areas[i][j][k] = math.random(0, 1)
            end
        end
    end
end
math.randomseed(os.time())

-- Build a combat object for each area.
function onGetFormulaValues(player, level, magicLevel)
    local min = (level / 5) + (magicLevel * 1.4) + 8
    local max = (level / 5) + (magicLevel * 2.2) + 14
    return -min, -max
end

local combats = {}
for i = 1, UPDATE_COUNT do
    combats[i] = Combat()
    combats[i]:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
    combats[i]:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
    combats[i]:setArea(createCombatArea(areas[i]))
    
    -- Workaround for formula callback getting consumed: https://otland.net/threads/tfs-1-x-combat-setcallbackfunction-event-function.283490/
    temporaryGlobalCallbackFunction = loadstring(string.dump(onGetFormulaValues))
    combats[i]:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "temporaryGlobalCallbackFunction")
end

-- Set up the spell callback, including an event for each update.
local spell = Spell(SPELL_INSTANT)

function spell.onCastSpell(creature, variant)
    for i = 2, UPDATE_COUNT do
        addEvent(function()
            combats[i]:execute(creature, variant)
        end, (i * 300 - 300))
    end
    
    return combats[1]:execute(creature, variant)
end

-- Define and register the spell.
spell:group("attack")
spell:id(220)
spell:name("frigo")
spell:words("frigo")
spell:level(14)
spell:mana(20)
spell:isPremium(false)
spell:range(1)
spell:needCasterTargetOrDirection(true)
spell:isBlockingWalls(true)
spell:cooldown(2000)
spell:groupCooldown(2000)
spell:needLearn(false)
spell:vocation("sorcerer;true", "druid;true", "master sorcerer", "elder druid")
spell:register()