--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
--local inspect = require(GetScriptDirectory() ..  "/inspect")
--local enemyStatus = require(GetScriptDirectory() .. "/enemy_status" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local castSTDesire = 0;
local castSADesire = 0;
local castWWDesire = 0;
local castDPDesire = 0;


function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityST = npcBot:GetAbilityByName( "clinkz_strafe" );
	abilitySA = npcBot:GetAbilityByName( "clinkz_searing_arrows" );
	abilityWW = npcBot:GetAbilityByName( "clinkz_wind_walk" );
	abilityDP = npcBot:GetAbilityByName( "clinkz_death_pact" );
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
		
		npcBot:Action_UseAbility(abilityST);
	end
	
	if castSADesire > 0 
	then
		
		npcBot:Action_UseAbilityOnEntity(abilitySA, castSATarget);
	end
	
	if castWWDesire > 0
	then
		
		npcBot:Action_UseAbility(abilityWW);
	end
	
	if castDPDesire > 0
	then
		
		npcBot:Action_UseAbilityOnEntity(abilityDP, castDPTarget);
	end
	
end

function CanCastSearingArrowOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end
function CanCastDeathPactOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function ToggleSearingArrow()

	local npcBot = GetBot();
	
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local npcTarget = npcBot:GetTarget();
	
	if ( npcTarget ~= nil and 
		( npcTarget:IsHero() or npcTarget:IsTower() or npcTarget:GetUnitName() == "npc_dota_roshan" ) and 
		CanCastSearingArrowOnTarget( npcTarget ) and 
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

	local npcBot = GetBot();
	
	if ( not abilityST:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local attackRange = npcBot:GetAttackRange()
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( attackRange, true );
		if tableNearbyEnemyTowers[1] ~= nil 
			and not tableNearbyEnemyTowers[1]:IsInvulnerable() 
			and GetUnitToUnitDistance(  tableNearbyEnemyTowers[1], npcBot  ) < attackRange
		then	
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance(  npcTarget, npcBot  ) < attackRange  )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < attackRange ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
	
end



function ConsiderSearingArrows()

	local npcBot = GetBot();
	
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
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING then
		local NearbyEnemyHeroes = npcBot:GetNearbyHeroes(attackRange, true, BOT_MODE_NONE);
		if NearbyEnemyHeroes[1] ~=  nil and CanCastSearingArrowOnTarget(NearbyEnemyHeroes[1]) and currManaP > 0.65  then
			return BOT_ACTION_DESIRE_LOW, NearbyEnemyHeroes[1];
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function ConsiderWindWalk()
	local npcBot = GetBot();

	if ( not abilityWW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local attackRange = npcBot:GetAttackRange()
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK  ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil ) 
		then
			local dist = GetUnitToUnitDistance( npcBot, npcTarget );
			if ( dist > 2 * attackRange and dist <= 3000 )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end

function ConsiderDeathPack()
	local npcBot = GetBot();
	if ( not abilityDP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local maxHP = 0;
	local NCreep = nil;
	local tableNearbyCreeps = npcBot:GetNearbyCreeps( 800, true );
	if #tableNearbyCreeps >= 2 then
		for _,creeps in pairs(tableNearbyCreeps)
		do
			local CreepHP = creeps:GetHealth();
			if CreepHP > maxHP and ( creeps:GetHealth() / creeps:GetMaxHealth() > .75 
				and CanCastDeathPactOnTarget(creeps) ) and not creeps:IsAncientCreep()
			then
				NCreep = creeps;
				maxHP = CreepHP;
			end
		end
	end
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	if NCreep ~= nil and currManaP > 0.20 then
		return BOT_ACTION_DESIRE_LOW, NCreep;
	end	

	return BOT_ACTION_DESIRE_NONE, 0;

end
