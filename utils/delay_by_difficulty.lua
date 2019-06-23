-- Get bot action delay time by difficulty

local module = {};

local delayMax = {};

delayMax[DIFFICULTY_EASY] = 1.0;
delayMax[DIFFICULTY_MEDIUM] = 0.6;
delayMax[DIFFICULTY_HARD] = 0.2;
delayMax[DIFFICULTY_UNFAIR] = 0.15;

module.getMaxValue = function (difficulty)
    return delayMax[difficulty];
end

return module;