if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/MyUtility")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local castSTDesire = 0;
local castSADesire = 0;
local castWWDesire = 0;
local castDPDesire = 0;

local abilityST = nil;
local abilitySA = nil;
local abilityWW = nil;
local abilityDP = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityST == nil then abilityST = npcBot:GetAbilityByName( "clinkz_death_pact" ) end
	if abilitySA == nil then abilitySA = npcBot:GetAbilityByName( "clinkz_searing_arrows" ) end
	if abilityWW == nil then abilityWW = npcBot:GetAbilityByName( "clinkz_wind_walk" ) end
	if abilityDP == nil then abilityDP = npcBot:GetAbilityByName( "clinkz_burning_army" ) end
	-- Consider using each ability
	if abilitySA:IsTrained() then
		ToggleSearingArrow();
	end
	
	castSTDesire, castSTTarget = ConsiderStarfe()
	castSADesire, castSATarget = ConsiderSearingArrows()
	castWWDesire               = ConsiderWindWalk()
	castDPDesire, castDPTarget = ConsiderDeathPack()
	
	if castSTDesire > 0
	then
		npcBot:Action_UseAbilityOnEntity(abilityST, castSTTarget);
		return;
	end
	
	if castSADesire > 0 
	then
		npcBot:Action_UseAbilityOnEntity(abilitySA, castSATarget);
		return;
	end
	
	if castWWDesire > 0
	then
		npcBot:Action_UseAbility(abilityWW);
		return;
	end
	
	if castDPDesire > 0
	then
		npcBot:Action_UseAbilityOnLocation(abilityDP, castDPTarget);
		return;
	end
	
end

function ToggleSearingArrow()

	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local npcTarget = npcBot:GetTarget();
	
	if ( npcTarget ~= nil and 
		( npcTarget:IsHero() or npcTarget:IsTower() or npcTarget:GetUnitName() == "npc_dota_roshan" ) and 
		mutil.CanCastOnNonMagicImmune(npcTarget) and 
		currManaP > .25 
		) 
	then
		if not abilitySA:GetAutoCastState( ) then
			abilitySA:ToggleAutoCast()
		end
	else 
		if  abilitySA:GetAutoCastState( ) then
			abilitySA:ToggleAutoCast()
		end
	end
	
end

function ConsiderStarfe()

	if ( not abilityST:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = abilityST:GetCastRange()
	local creepLvl = abilityST:GetSpecialValueInt('neutral_level');
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange+200, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 then
			for _,creep in pairs(tableNearbyEnemyCreeps)
			do
				if creep:GetLevel() <= creepLvl then
					return BOT_ACTION_DESIRE_LOW, creep;
				end
			end
		end
	end
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange+200, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 then
			for _,creep in pairs(tableNearbyEnemyCreeps)
			do
				if creep:GetLevel() <= creepLvl then
					return BOT_ACTION_DESIRE_LOW, creep;
				end
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange+200, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 then
			for _,creep in pairs(tableNearbyEnemyCreeps)
			do
				if creep:GetLevel() <= creepLvl then
					return BOT_ACTION_DESIRE_LOW, creep;
				end
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 2500)
		then
			local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange+200, true );
			if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 then
				for _,creep in pairs(tableNearbyEnemyCreeps)
				do
					if creep:GetLevel() <= creepLvl then
						return BOT_ACTION_DESIRE_LOW, creep;
					end
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
	
end



function ConsiderSearingArrows()

	if ( not abilitySA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if abilitySA:GetAutoCastState( ) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local nDamage = npcBot:GetAttackDamage() + abilitySA:GetSpecialValueInt( "damage_bonus" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local attackRange = npcBot:GetAttackRange()
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING then
		local laneCreeps = npcBot:GetNearbyLaneCreeps(attackRange, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage and currManaP > 0.25  then
				return BOT_ACTION_DESIRE_LOW, creep;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, attackRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING then
		local NearbyEnemyHeroes = npcBot:GetNearbyHeroes(attackRange, true, BOT_MODE_NONE);
		if NearbyEnemyHeroes[1] ~=  nil and mutil.CanCastOnNonMagicImmune(NearbyEnemyHeroes[1]) and currManaP > 0.65  then
			return BOT_ACTION_DESIRE_LOW, NearbyEnemyHeroes[1];
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function ConsiderWindWalk()
	
	if ( not abilityWW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local attackRange = npcBot:GetAttackRange()
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, attackRange + 300) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end

function ConsiderDeathPack()

	if ( not abilityDP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local nAttackRange = npcBot:GetAttackRange();
	local nCastRange = abilityDP:GetCastRange();
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nAttackRange, 400, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			skUse = false;
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and npcTarget:GetHealth() / npcTarget:GetMaxHealth() > 0.25 and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			skUse = false;
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;

end
