--
-- Schedule actions in time
--

local module = {};

if _G._bot_schedule == nil then
    _G._bot_schedule = {};
end

module.add = function(action, time)
    _G._bot_schedule[action] = time;
    return module;
end

module.remove = function(action)
    _G._bot_schedule[action] = nil;
    return module;
end

module.has = function(action)
    return _G._bot_schedule[action] ~= nil;
end

module.getTime = function(action)
    return _G._bot_schedule[action];
end

return module;