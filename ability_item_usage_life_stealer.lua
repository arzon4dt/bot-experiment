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

local castRGDesire = 0;
local castOWDesire = 0;
local castINDesire = 0;
local castCODesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityRG = npcBot:GetAbilityByName( "life_stealer_rage" );
	abilityOW = npcBot:GetAbilityByName( "life_stealer_open_wounds" );
	abilityIN = npcBot:GetAbilityByName( "life_stealer_infest" );
	abilityCO = npcBot:GetAbilityByName( "life_stealer_consume" );

	-- Consider using each ability
	castRGDesire = ConsiderRage();
	castOWDesire, castOWTarget = ConsiderOpenWounds();
	castINDesire, castINTarget = ConsiderInfest();
	castCODesire = ConsiderConsume();
	
	if ( castRGDesire > 0 ) 
	then
		--print("cast RG")
		npcBot:Action_UseAbility( abilityRG );
		return;
	end
	
	if ( castCODesire > 0 ) 
	then
		--print("cast Co")
		npcBot:Action_UseAbility( abilityCO );
		return;
	end

	if ( castOWDesire > 0 ) 
	then
		--print("cast OW")
		npcBot:Action_UseAbilityOnEntity( abilityOW, castOWTarget );
		return;
	end
	
	if ( castINDesire > 0 ) 
	then
		--print("cast IN")
		npcBot:Action_UseAbilityOnEntity( abilityIN, castINTarget );
		return;
	end

	

end

function CanCastOpenWoundsOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastInfestOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end


function ConsiderRage()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityRG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if GetUnitToUnitDistance(npcEnemy, npcBot) < 500 and 
		  ( npcEnemy:IsUsingAbility() or npcEnemy:GetActiveMode() == BOT_MODE_ATTACK or npcEnemy:GetActiveMode() == BOT_MODE_RETREAT  )  
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_MODERATE ) 
	then
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or npcEnemy:IsUsingAbility() or npcBot:GetHealth()/npcBot:GetMaxHealth() <= 0.15 ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
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
			local eHeroesCastSpell = false;
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcEnemy:IsUsingAbility() ) 
				then
					eHeroesCastSpell = true;
				end
			end
			if ( GetUnitToUnitDistance( npcBot, npcTarget ) < 400 or eHeroesCastSpell or npcTarget:IsUsingAbility() )
			then
				return BOT_ACTION_DESIRE_ABSOLUTE;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderOpenWounds()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityOW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( castRGDesire > 0 ) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityOW:GetCastRange();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange - 100, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( (npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange - 100) and CanCastOpenWoundsOnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastOpenWoundsOnTarget( npcTargetToKill ) and not enemyDisabled(npcTargetToKill) )
	then
		if ( (npcTargetToKill:GetHealth() / npcTargetToKill:GetMaxHealth()) < 0.25 and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastOpenWoundsOnTarget( npcTarget ) and not enemyDisabled(npcTarget)) 
		then
			if ( GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderInfest()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityIN:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( castRGDesire > 0 ) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityIN:GetCastRange();
	local nDamage = abilityIN:GetSpecialValueInt("damage");
	local nRadius = abilityIN:GetSpecialValueInt("radius");
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes[1] ~= nil ) 
		then
				local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
				local tableNearbyAlliedCreeps = npcBot:GetNearbyLaneCreeps ( 800, false );
				local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( 800, true );
					for _,npcAllied in pairs( tableNearbyAlliedHeroes  )
					do
						if ( npcAllied:GetUnitName() ~= npcBot:GetUnitName() and GetUnitToUnitDistance( npcAllied, npcBot ) < 3*nCastRange and CanCastInfestOnTarget(npcAllied) ) 
						then
							return BOT_ACTION_DESIRE_HIGH, npcAllied;
						end
					end
				
					for _,npcACreep in pairs( tableNearbyAlliedCreeps  )
					do
						if ( GetUnitToUnitDistance( npcACreep, npcBot ) < 3*nCastRange and CanCastInfestOnTarget(npcACreep) ) 
						then
							return BOT_ACTION_DESIRE_HIGH, npcACreep;
						end
					end
			
					for _,npcECreep in pairs( tableNearbyEnemyCreeps  )
					do
						if ( GetUnitToUnitDistance( npcECreep, npcBot ) < 3*nCastRange and CanCastInfestOnTarget(npcECreep)  ) 
						then
							return BOT_ACTION_DESIRE_HIGH, npcECreep;
						end
					end
		end
	end

	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and npcTarget:IsHero() )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nRadius - 200 ) )
		then
			local tableNearbyAlliedCreeps = npcBot:GetNearbyLaneCreeps ( 3*nCastRange, false );
			local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( 3*nCastRange, true );
			
				for _,npcACreep in pairs( tableNearbyAlliedCreeps  )
				do
					if ( GetUnitToUnitDistance( npcTarget, npcBot ) < (nRadius - 200) and GetUnitToUnitDistance( npcACreep, npcBot ) < (2*nCastRange) and CanCastInfestOnTarget( npcACreep ) ) 
					then
						return BOT_ACTION_DESIRE_HIGH, npcACreep;
					end
				end
			
				for _,npcECreep in pairs( tableNearbyEnemyCreeps  )
				do
					if ( GetUnitToUnitDistance( npcTarget, npcBot ) < (nRadius - 200) and GetUnitToUnitDistance( npcECreep, npcBot ) < (2*nCastRange) and CanCastInfestOnTarget( npcECreep ) ) 
					then
						return BOT_ACTION_DESIRE_HIGH, npcECreep;
					end
				end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK  ) 
	then
		local npcTarget = npcBot:GetTarget();
		
		if ( npcTarget~= nil and npcTarget:IsHero() )
		then
			local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 600, false, BOT_MODE_NONE );
			local target = nil;
			for _,npcAllied in pairs( tableNearbyAlliedHeroes  )
			do
					if ( npcAllied:GetUnitName() ~= npcBot:GetUnitName() and GetUnitToUnitDistance( npcAllied, npcBot ) < 3*nCastRange and npcAllied:GetAttackRange() < 320 ) 
					then
						target = npcAllied;
					end
			end
			if GetUnitToUnitDistance(npcTarget, npcBot) > 2000 and target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderConsume()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityCO:IsFullyCastable() or abilityCO:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	

	local nDamage = abilityIN:GetSpecialValueInt("damage");
	local nRadius = abilityIN:GetSpecialValueInt("radius");
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		if ( #tableNearbyEnemyHeroes == 0 or abilityRG:IsFullyCastable() ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
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
		if ( 
			( npcTarget~= nil and npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nRadius - 200 ) ) or 
			( npcTarget~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nRadius - 200 ) )
		)
		then
			return BOT_ACTION_DESIRE_ABSOLUTE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

