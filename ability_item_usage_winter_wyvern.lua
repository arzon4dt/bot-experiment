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

local castFBDesire = 0;
local castLADesire = 0;
local castIGDesire = 0;
local castOGDesire = 0;

local abilityOG = nil;
local abilityIG = nil;
local abilityLA = nil;
local abilityFB = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityOG == nil then abilityOG = npcBot:GetAbilityByName( "winter_wyvern_arctic_burn" ) end
	if abilityIG == nil then abilityIG = npcBot:GetAbilityByName( "winter_wyvern_splinter_blast" ) end
	if abilityLA == nil then abilityLA = npcBot:GetAbilityByName( "winter_wyvern_cold_embrace" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "winter_wyvern_winters_curse" ) end

	-- Consider using each ability
	castOGDesire, castOGTarget = ConsiderOvergrowth();
	castIGDesire, castIGTarget = ConsiderIgnite();
	castLADesire, castLATarget = ConsiderLivingArmor();
	castFBDesire, castFBTarget = ConsiderFireblast();
	
	if ( castOGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityOG );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIG, castIGTarget );
		return;
	end
	
	if ( castLADesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLA, castLATarget );
		return;
	end
	
	
end


function ConsiderOvergrowth()
	
	-- Make sure it's castable
	if ( not abilityOG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = 1000;
	local nRange = abilityOG:GetSpecialValueInt('attack_range_bonus');
	local attackRange = npcBot:GetAttackRange();
	
	if npcBot:HasScepter() == false then
	
		if mutil.IsStuck(npcBot)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
		-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
		if mutil.IsRetreating(npcBot)
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH;
				end
			end
		end
		
		-- If we're going after someone
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local npcTarget = npcBot:GetTarget();

			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, attackRange+0.5*nRange)
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	
	else
		if mutil.IsStuck(npcBot) and abilityOG:GetToggleState() == false
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local npcTarget = npcBot:GetTarget();

			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, attackRange+0.5*nRange)
			then
				if npcTarget:HasModifier('modifier_winter_wyvern_arctic_burn_slow') == false and abilityOG:GetToggleState() == false 
				then 
					return BOT_ACTION_DESIRE_HIGH;
				elseif npcTarget:HasModifier('modifier_winter_wyvern_arctic_burn_slow') == true and abilityOG:GetToggleState() == true 
				then
					return BOT_ACTION_DESIRE_HIGH;
				elseif npcTarget:CanBeSeen() == false and abilityOG:GetToggleState() == true 	
				then
					return BOT_ACTION_DESIRE_HIGH;
				end	
			end
		else
			if abilityOG:GetToggleState() == true 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderIgnite()

	-- Make sure it's castable
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityIG:GetCastRange();
	local nDamage = abilityIG:GetAbilityDamage();
	local nRadius = abilityIG:GetSpecialValueInt( "split_radius" );
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local tableNearbyEnemyHeroes = npcEnemy:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
				local tableNearbyEnemyCreeps = npcEnemy:GetNearbyLaneCreeps( nRadius, false );
				for _, h in pairs(tableNearbyEnemyHeroes) 
				do
					if h:GetUnitName() ~= npcEnemy:GetUnitName() and mutil.CanCastOnNonMagicImmune(h) 
					then
						return BOT_ACTION_DESIRE_HIGH, h;
					end
				end
				for _, c in pairs(tableNearbyEnemyCreeps) 
				do
					if mutil.CanCastOnNonMagicImmune(c)
					then
						return BOT_ACTION_DESIRE_HIGH, c;
					end
				end
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4 and tableNearbyEnemyCreeps[2] ~= nil
		then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyCreeps[2];
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local tableNearbyEnemyCreeps = npcTarget:GetNearbyLaneCreeps( nRadius, false );
			for _,h in pairs(tableNearbyEnemyHeroes) 
			do
				if h:GetUnitName() ~= npcTarget:GetUnitName() and mutil.CanCastOnNonMagicImmune(h)
				then
					return BOT_ACTION_DESIRE_HIGH, h;
				end
			end
			for _,c in pairs(tableNearbyEnemyCreeps) 
			do
				if mutil.CanCastOnNonMagicImmune(c)
				then
					return BOT_ACTION_DESIRE_HIGH, c;
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end



function ConsiderLivingArmor()

	-- Make sure it's castable
	if ( not abilityLA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end

	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		for _,npcAlly in pairs( tableNearbyAllyHeroes )
		do
			if mutil.CanCastOnNonMagicImmune(npcAlly) and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.25 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcAlly;
			end
		end
	end
	
	for _,npcAlly in pairs( tableNearbyAllyHeroes )
	do
		if mutil.CanCastOnNonMagicImmune(npcAlly) and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.25 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcAlly;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityFB:GetSpecialValueInt("radius");
	local nCastRange = abilityFB:GetCastRange();
	local nDamage = 500;

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200)
	then

		local npcMostWeakEnemy = nil;
		local nMostWeakHP = 10000;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( #tableNearbyEnemyHeroes >= 3 ) then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( mutil.CanCastOnMagicImmune( npcEnemy ) and not mutil.IsDisabled(true, npcEnemy) )
				then
					local nHealth = npcEnemy:GetHealth()
					if ( nHealth < nMostWeakHP )
					then
						nMostWeakHP = nHealth;
						npcMostWeakEnemy = npcEnemy;
					end
				end
			end

			if ( npcMostWeakEnemy ~= nil  )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcMostWeakEnemy;
			end
		end
	end
	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and  mutil.CanCastOnMagicImmune( npcEnemy ) and not mutil.IsDisabled(true, npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end

	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2
		then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and  mutil.CanCastOnMagicImmune( npcEnemy ) and not mutil.IsDisabled(true, npcEnemy) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and not mutil.IsDisabled(true, npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		then
			local NearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local nInvUnit = mutil.CountInvUnits(true, NearbyEnemyHeroes);
			if nInvUnit >= 3 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

