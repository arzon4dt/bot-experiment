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

local castLSDesire = 0;
local castLADesire = 0;
local castOGDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityLS = npcBot:GetAbilityByName( "treant_leech_seed" );
	abilityLA = npcBot:GetAbilityByName( "treant_living_armor" );
	abilityOG = npcBot:GetAbilityByName( "treant_overgrowth" );

	-- Consider using each ability
	castLSDesire, castLSTarget = ConsiderLeechSeed();
	castLADesire, castLATarget = ConsiderLivingArmor();
	castOGDesire, castOGTarget = ConsiderOvergrowth();
	

	if ( castOGDesire > castLSDesire and castOGDesire > castLADesire ) 
	then
		npcBot:Action_UseAbility( abilityOG );
		return;
	end

	if ( castLSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLS, castLSTarget );
		return;
	end
	
	if ( castLADesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLA, castLATarget );
		return;
	end

end

function CanCastLeechSeedOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastLivingArmorOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end
function CanCastOvergrowthOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function ConsiderLeechSeed()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityLS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityLS:GetCastRange();
	local nDuration = abilityLS:GetSpecialValueInt( "duration" );
	local nDOT = abilityLS:GetSpecialValueInt( "leech_damage" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and CanCastLeechSeedOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( (nDuration*nDOT), DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill;
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
				if ( CanCastLeechSeedOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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
			if ( CanCastLeechSeedOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderLivingArmor()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityLA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastLivingArmorOnTarget( npcBot ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcBot;
				end
			end
		end
	end

	-- If we're pushing or defending a lane
	if ( npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local tableNearbyFriendlyTowers = npcBot:GetNearbyTowers( 400, false );
			for _,myTower in pairs(tableNearbyFriendlyTowers) do
				if ( GetUnitToUnitDistance( myTower, npcBot  ) < 400 ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, myTower;
				end
			end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1300, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1300, false, BOT_MODE_NONE );
		for _,npcAlly in pairs( tableNearbyAllyHeroes )
		do
			if ( ( npcAlly:GetHealth() / npcAlly:GetMaxHealth() ) < 0.5 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcAlly;
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
			if ( CanCastLivingArmorOnTarget( npcBot ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
		end
	end

	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local Player = GetTeamMember(i);
		if Player:IsAlive() and Player:GetHealth()/Player:GetMaxHealth() < 0.65 and 
		   Player:GetActiveMode() == BOT_MODE_RETREAT and Player:GetActiveModeDesire() >= BOT_ACTION_DESIRE_HIGH and 
		   Player:DistanceFromFountain() > 0  
		then
			return BOT_ACTION_DESIRE_MODERATE, Player;
		end
	end
	
	local Team = GetTeam();
	for i = 0, 10
	do
		local tower =  GetTower(Team, i);
		if tower ~= nil and tower:GetHealth() > 0 then
			local THealth = tower:GetHealth()/tower:GetMaxHealth();
			if  THealth < 1.0 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.45 then 
				return BOT_ACTION_DESIRE_MODERATE, tower;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderOvergrowth()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityOG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityOG:GetSpecialValueInt( "radius" );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
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
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius - 400 ) 
		then
			if ( CanCastOvergrowthOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
