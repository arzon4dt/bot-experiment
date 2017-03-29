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

local castESDesire = 0;
local castVODesire = 0;
local castFGDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityES = npcBot:GetAbilityByName( "visage_grave_chill" );
	abilityVO = npcBot:GetAbilityByName( "visage_soul_assumption" );
	abilityFG = npcBot:GetAbilityByName( "visage_summon_familiars" );
	
	
	-- Consider using each ability
	castESDesire, castESTarget = ConsiderEtherShock();
	castVODesire, castVOTarget = ConsiderVoodoo();
	castFGDesire, castFGTarget = ConsiderFleshGolem();

	if ( castESDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityES, castESTarget );
		return;
	end
	
	if ( castVODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityVO, castVOTarget );
		return;
	end
	if ( castFGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityFG );
		return;
	end
	
	
end

function CanCastEtherShockOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastVoodooOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end


function ConsiderEtherShock()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityES:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityES:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and CanCastVoodooOnTarget( npcEnemy )  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastEtherShockOnTarget( npcEnemy ) and GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange + 200 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			if ( CanCastEtherShockOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderVoodoo()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityVO:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local SAStack = 0;
	local npcModifier = npcBot:NumModifiers();
	
	for i = 0, npcModifier 
	do
		if npcBot:GetModifierName(i) == "modifier_visage_soul_assumption" then
			SAStack = npcBot:GetModifierStackCount(i);
			break;
		end
	end
	
	local nCastRange = abilityVO:GetCastRange();
	local nStackLimit = abilityVO:GetSpecialValueInt("stack_limit");
	local nBaseDamage = abilityVO:GetSpecialValueInt("soul_base_damage");
	local nChargeDamage = abilityVO:GetSpecialValueInt("soul_charge_damage");
	local nTotalDamage = nBaseDamage + (SAStack * nChargeDamage);
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If a mode has set a target, and we can kill them, do it
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		local distance = GetUnitToUnitDistance(npcEnemy, npcBot);
		if ( npcEnemy:GetActualIncomingDamage( nTotalDamage, DAMAGE_TYPE_MAGICAL ) >= npcEnemy:GetHealth() and 
			distance < nCastRange + 200 and
			npcEnemy:IsHero() and
			CanCastVoodooOnTarget(npcEnemy)
			)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		--local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastVoodooOnTarget( npcEnemy ) and SAStack == nStackLimit ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastVoodooOnTarget( npcEnemy ) and GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange + 200 and SAStack == nStackLimit ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil ) 
		then
			if ( CanCastVoodooOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 and SAStack == nStackLimit )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderFleshGolem()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local numFamiliar = 0;
	
	local listFamiliar = GetUnitList(UNIT_LIST_ALLIES);
	for _,unit in pairs(listFamiliar)
	do
		if string.find(unit:GetUnitName(), "npc_dota_visage_familiar") then
			numFamiliar = numFamiliar + 1;
		end
	end
	
	if numFamiliar < 1 then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
