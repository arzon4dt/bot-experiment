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
local castFBDesire = 0;
local castUFBDesire = 0;
local castIGDesire = 0;
local castBLDesire = 0;


function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityUFB = npcBot:GetAbilityByName( "ogre_magi_unrefined_fireblast" );
	abilityFB = npcBot:GetAbilityByName( "ogre_magi_fireblast" );
	abilityIG = npcBot:GetAbilityByName( "ogre_magi_ignite" );
	abilityBL = npcBot:GetAbilityByName( "ogre_magi_bloodlust" );

	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castUFBDesire, castUFBTarget = ConsiderUnrefinedFireblast();
	castIGDesire, castIGTarget = ConsiderIgnite();
	castBLDesire, castBLTarget = ConsiderBloodlust();
	
	if ( castUFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityUFB, castUFBTarget );
		return;
	end

	if ( castFBDesire > castIGDesire and castFBDesire > castBLDesire ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end

	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIG, castIGTarget );
		return;
	end
	
	if ( castBLDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBL, castBLTarget );
		return;
	end

end

function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastIgniteOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastBloodlustOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end

function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nDamage = abilityFB:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireblastOnTarget( npcTargetToKill ) and not enemyDisabled(npcTargetToKill) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastFireblastOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
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
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange and not enemyDisabled(npcTarget))
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderIgnite()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityIG:GetCastRange();
	local nDuration = abilityIG:GetSpecialValueInt( "duration" );
	local nDOT = abilityIG:GetSpecialValueInt( "burn_damage" );
	local nRadius = 0;
	
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and CanCastIgniteOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( (nDuration*nDOT), DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastIgniteOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
			for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
				if ( GetUnitToUnitDistance( npcCreepTarget, npcBot  ) < nCastRange and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcCreepTarget;
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
			if ( CanCastIgniteOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderBloodlust()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityBL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityBL:GetCastRange();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end
	
	-- If we're pushing or defending a lane
	if ( npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		    local tableNearbyFriendlyTowers = npcBot:GetNearbyTowers( nCastRange, false );
			for _,myTower in pairs(tableNearbyFriendlyTowers) do
				if ( GetUnitToUnitDistance( myTower, npcBot  ) < nCastRange and not myTower:HasModifier("modifier_ogre_magi_bloodlust") ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, myTower;
				end
			end
			local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				if ( GetUnitToUnitDistance( myFriend, npcBot  ) < nCastRange and not myFriend:HasModifier("modifier_ogre_magi_bloodlust") ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, myFriend;
				end
			end	
			if not npcBot:HasModifier("modifier_ogre_magi_bloodlust") then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
	end
	
	-- If we're pushing or defending a lane
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT  ) 
	then
			local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				if ( GetUnitToUnitDistance( myFriend, npcBot  ) < nCastRange and not myFriend:HasModifier("modifier_ogre_magi_bloodlust") ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, myFriend;
				end
			end	
			if not npcBot:HasModifier("modifier_ogre_magi_bloodlust") then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
			local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				if ( GetUnitToUnitDistance( myFriend, npcBot  ) < nCastRange and not myFriend:HasModifier("modifier_ogre_magi_bloodlust") ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, myFriend;
				end
			end	
			if not npcBot:HasModifier("modifier_ogre_magi_bloodlust") then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderUnrefinedFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityUFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( not npcBot:HasScepter() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if castFBDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityUFB:GetCastRange();
	local nDamage = abilityFB:GetAbilityDamage();
	local curPMana  = npcBot:GetMana()/npcBot:GetMaxMana();

	if ( curPMana > 0.5 ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireblastOnTarget( npcTargetToKill ) and not enemyDisabled(npcTargetToKill) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastFireblastOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
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
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange and not enemyDisabled(npcTarget))
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end



