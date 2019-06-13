if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util");
local mutils = require(GetScriptDirectory() ..  "/MyUtility")
local abUtils = require(GetScriptDirectory() ..  "/AbilityItemUsageUtility")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

-- local bot = GetBot();

-- local abilities = {};

-- local castQDesire = 0;
-- local castWDesire = 0;
-- local castEDesire = 0;

-- function AbilityUsageThinkPlanned()
	
	-- if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,2,6}) end
	
	-- if mutils.CantUseAbility(bot) then return end
	
	-- castQDesire, targetQ = ConsiderQ();
	-- castWDesire, targetW = ConsiderW();
	-- castEDesire, targetE  = ConsiderE();
	-- castE2Desire, targetE2 = ConsiderE2();
	
	-- if castE2Desire > 0 then
		-- bot:Action_UseAbilityOnLocation(abilities[4], targetE2);		
		-- return
	-- end
	
	-- if castQDesire > 0 then
		-- bot:Action_UseAbilityOnLocation(abilities[1], targetQ);		
		-- return
	-- end
	
	-- if castWDesire > 0 then
		-- bot:Action_UseAbilityOnEntity(abilities[2], targetW);		
		-- return
	-- end
	
	-- if castEDesire > 0 then
		-- bot:Action_UseAbilityOnTree(abilities[3], targetE);		
		-- return
	-- end
	
-- end

-- function ConsiderQ()
	-- if not mutils.CanBeCast(abilities[1]) then
		-- return BOT_ACTION_DESIRE_NONE, nil;
	-- end
	
	-- local nCastRange = mutils.GetProperCastRange(true, bot, abilities[1]:GetCastRange()/2);
	-- local nCastPoint = abilities[1]:GetCastPoint();
	-- local manaCost  = abilities[1]:GetManaCost();
	-- local nRadius   = abilities[1]:GetSpecialValueInt( "radius" );
	
	-- if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	-- then
		-- local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange-150, bot);
		-- if target ~= nil then
			-- return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		-- end
	-- end
	
	-- if mutils.IsInTeamFight(bot, 1300)
	-- then
		-- local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange-200, nRadius, nCastPoint, 0 );
		-- if ( locationAoE.count >= 2 ) then
			-- local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange-200, nRadius, locationAoE.targetloc, bot);
			-- if target ~= nil then
				-- return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			-- end
		-- end
	-- end
	
	-- if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and mutils.CanSpamSpell(bot, manaCost)
	-- then
		-- local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		-- if ( locationAoE.count >= 4 ) then
			-- local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			-- if target ~= nil then
				-- return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			-- end
		-- end
	-- end
	
	-- if mutils.IsGoingOnSomeone(bot)
	-- then
		-- local target = bot:GetTarget();
		-- if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange/2)
		-- then
			-- return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		-- end
	-- end
	
	-- return BOT_ACTION_DESIRE_NONE, nil;
-- end

-- function ConsiderW()
	-- if not mutils.CanBeCast(abilities[2]) then
		-- return BOT_ACTION_DESIRE_NONE, nil;
	-- end
	
	-- local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	-- local nCastPoint = abilities[2]:GetCastPoint();
	-- local manaCost  = abilities[2]:GetManaCost();
	-- local nRadius   = abilities[2]:GetSpecialValueInt( "grab_radius" );
	
	-- if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	-- then
		-- local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		-- if enemies ~= nil and #enemies > 0 then
			-- local target = enemies[1];
			-- local furthest = nil;
			-- if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) then
				-- local eHeroes = bot:GetNearbyHeroes(nCastRange-300, true, BOT_MODE_NONE);
				
			-- end
		-- end
	-- end
	
	-- if mutils.IsInTeamFight(bot, 1300)
	-- then
		-- local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange-200, nRadius, nCastPoint, 0 );
		-- if ( locationAoE.count >= 2 ) then
			-- local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange-200, nRadius, locationAoE.targetloc, bot);
			-- if target ~= nil then
				-- return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			-- end
		-- end
	-- end
	
	-- if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and mutils.CanSpamSpell(bot, manaCost)
	-- then
		-- local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		-- if ( locationAoE.count >= 4 ) then
			-- local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			-- if target ~= nil then
				-- return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			-- end
		-- end
	-- end
	
	-- if mutils.IsGoingOnSomeone(bot)
	-- then
		-- local target = bot:GetTarget();
		-- if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange/2)
		-- then
			-- return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		-- end
	-- end
	
	-- return BOT_ACTION_DESIRE_NONE, nil;
-- end	