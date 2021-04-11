local mutils = require(GetScriptDirectory() ..  "/MyUtility")

Cast = {}

Cast.__index = Cast

function Cast:new(bot, abilities)
    local instance = {
        _abilities = abilities,
        _bot = bot
    }
    setmetatable(instance, Cast)
    return instance
end

function Cast:getAbilityByIndex(index)
    return self._abilities[index]
end

function Cast:getAbilityByIndex(index)
    return self._abilities[index]
end

function Cast:considerQ(bot, ability)
    if  mutils.CanBeCast(ability) == false then
		return BOT_ACTION_DESIRE_NONE, nil
	end
	
	local nCastPoint = ability:GetCastPoint()
	local manaCost   = ability:GetManaCost()
    local nCastRange    = mutils.GetProperCastRange(false, bot, ability:GetCastRange())
    
    return BOT_ACTION_DESIRE_HIGH, nil
end


return Ability