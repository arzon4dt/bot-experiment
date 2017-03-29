--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local skills = require(GetScriptDirectory() ..  "/SkillsUtility")
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
local castTLDesire = 0;
local setTarget = false;
function AbilityUsageThink()

	local npcBot = GetBot();
	
	--[[for i = 0, 24, 1
	do 
		local ability = npcBot:GetAbilityInSlot(i);
		if ability ~= nil then
			print(i..ability:GetName());
		end
	end]]--
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityUFB = npcBot:GetAbilityByName( "rubick_spell_steal" );
	abilityFB = npcBot:GetAbilityByName( "rubick_telekinesis" );
	abilityTL = npcBot:GetAbilityByName( "rubick_telekinesis_land" );
	abilityIG = npcBot:GetAbilityByName( "rubick_fade_bolt" );
	ability4 = npcBot:GetAbilityInSlot(4);
	ability5 = npcBot:GetAbilityInSlot(5);

	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTLDesire, castTLLocation = ConsiderTeleLand();
	castUFBDesire, castUFBTarget = ConsiderUnrefinedFireblast();
	castIGDesire, castIGTarget = ConsiderIgnite();
	
	if ( castUFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityUFB, castUFBTarget );
		return;
	end

	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		setTarget = false;
		return;
	end
	
	if ( castTLDesire > 0 and not setTarget ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTL, castTLLocation );
		setTarget = true;
		return;
	end

	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIG, castIGTarget );
		return;
	end
	
	skills.CastStolenSpells(ability4);
	skills.CastStolenSpells(ability5);

end

function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastIgniteOnTarget( npcTarget )
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
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 and not enemyDisabled(npcTarget))
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderTeleLand()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityTL:IsFullyCastable() or abilityTL:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	local nRadius = abilityTL:GetSpecialValueInt("radius");
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK 
		 ) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or npcBot:GetActiveMode() == BOT_MODE_RETREAT  ) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront( nCastRange + nRadius );
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
	local nDamage = abilityIG:GetSpecialValueInt( "damage" );
	
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and CanCastIgniteOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ) )
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
			if ( GetUnitToUnitDistance( npcCreepTarget, npcBot  ) < nCastRange and npcBot:GetMana()/npcBot:GetMaxMana() > 0.75 ) 
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
			if ( CanCastIgniteOnTarget( npcTarget ) and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 )  )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
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

	if not string.find(ability4:GetName(), 'empty') and not ability4:IsToggle() and ability4:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityUFB:GetCastRange();
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------

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
			if ( GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end



