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

local ListRune = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_BOUNTY_3,
	RUNE_BOUNTY_4,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2
}


local hawkLocDire = {
	Vector(-3788.000000, -280.000000, 0.000000),
	Vector(-166.000000, -4568.000000, 0.000000),
	GetRuneSpawnLocation(ListRune[1]),
	GetRuneSpawnLocation(ListRune[2]),
	GetRuneSpawnLocation(ListRune[3]),
	GetRuneSpawnLocation(ListRune[4]),
	GetRuneSpawnLocation(ListRune[5]),
	GetRuneSpawnLocation(ListRune[6])
}

local hawkLocRadiant = {
	Vector(-943.000000, 3546.000000, 0.000000),
	Vector(3136.000000, -370.000000, 0.000000),
	GetRuneSpawnLocation(ListRune[1]),
	GetRuneSpawnLocation(ListRune[2]),
	GetRuneSpawnLocation(ListRune[3]),
	GetRuneSpawnLocation(ListRune[4]),
	GetRuneSpawnLocation(ListRune[5]),
	GetRuneSpawnLocation(ListRune[6])
}



local castWADesire = 0;
local castWHDesire = 0;
local castWBDesire = 0;
local castPRDesire = 0;

local abilityWA = nil;
local abilityWH = nil;
local abilityWB = nil;
local abilityPR = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityWA == nil then abilityWA = npcBot:GetAbilityByName( "beastmaster_wild_axes" ) end
	if abilityWH == nil then abilityWH = npcBot:GetAbilityByName( "beastmaster_call_of_the_wild_hawk" ) end
	if abilityWB == nil then abilityWB = npcBot:GetAbilityByName( "beastmaster_call_of_the_wild_boar" ) end
	if abilityPR == nil then abilityPR = npcBot:GetAbilityByName( "beastmaster_primal_roar" ) end

	-- Consider using each ability
	castPRDesire, castPRTarget = ConsiderPrimalRoar();
	castWADesire, castWALocation = ConsiderWildAxes();
	castWHDesire, castWHLocation = ConsiderWildHawk();
	castWBDesire = ConsiderWildBoar();

	if ( castPRDesire > castWADesire ) 
	then
		--print("Use WA");
		npcBot:Action_UseAbilityOnEntity( abilityPR, castPRTarget );
		return;
	end

	if ( castWADesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityWA, castWALocation );
		return;
	end
	
	if ( castWHDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityWH, castWHLocation );
		return;
	end

	if ( castWBDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityWB );
		return;
	end

end


function ConsiderWildAxes()

	-- Make sure it's castable
	if ( not abilityWA:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityWA:GetSpecialValueInt( "radius" );
	local nCastRange = abilityWA:GetCastRange();
	local manaCost = abilityWA:GetManaCost();
	local nCastPoint = abilityWA:GetCastPoint( );
	local nDamage = abilityWA:GetSpecialValueInt("axe_damage");

	if nCastRange > 1600 then nCastRange = 1600 end
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If mana is full and we're laning just hit hero
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING and 
		npcBot:GetMana() == npcBot:GetMaxMana() ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		if(tableNearbyEnemyHeroes[1] ~= nil) then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyHeroes[1]:GetExtrapolatedLocation( (GetUnitToUnitDistance( tableNearbyEnemyHeroes[1], npcBot )/800) + nCastPoint );
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and
	   mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_PHYSICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( (GetUnitToUnitDistance(npcTarget, npcBot )/800) + nCastPoint );
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and mutil.CanSpamSpell(npcBot, manaCost)
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			local target = mutil.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, npcBot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and  mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( (GetUnitToUnitDistance(npcTarget, npcBot )/800) + nCastPoint );
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderPrimalRoar()

	-- Make sure it's castable
	if ( not abilityPR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityPR:GetCastRange();
	local nDamage = abilityPR:GetSpecialValueInt( "damage" );
	
	-- If enemy is channeling cancel it
    local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for	_,enemy in pairs(tableNearbyEnemyHeroes)
	do
		if enemy:IsChanneling() and mutil.CanCastOnMagicImmune(enemy) then
			return BOT_ACTION_DESIRE_HIGH, enemy;
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
    if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200)
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnMagicImmune(npcEnemy) 
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderWildBoar()

	-- Make sure it's castable
	if ( not abilityWB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 800)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 ) or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------


	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 800)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderWildHawk()

	if ( not abilityWH:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	local roll = RandomInt(1,8);
	if GetTeam() == TEAM_RADIANT then
		return BOT_ACTION_DESIRE_MODERATE, hawkLocRadiant[roll];
	else
		return BOT_ACTION_DESIRE_MODERATE, hawkLocDire[roll];
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

