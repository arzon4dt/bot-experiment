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
local castLADesire = 0;
local castIGDesire = 0;
local castOGDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityOG = npcBot:GetAbilityByName( "winter_wyvern_arctic_burn" );
	abilityIG = npcBot:GetAbilityByName( "winter_wyvern_splinter_blast" );
	abilityLA = npcBot:GetAbilityByName( "winter_wyvern_cold_embrace" );
	abilityFB = npcBot:GetAbilityByName( "winter_wyvern_winters_curse" );

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


function CanCastLivingArmorOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastCurseOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end
function CanCastIgniteOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastOvergrowthOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune()  and not npcTarget:IsInvulnerable();
end

function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end

function ConsiderOvergrowth()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityOG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = 1000;
	
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius ) 
		then
			if ( CanCastOvergrowthOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderIgnite()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityIG:GetCastRange();
	local nDamage = abilityIG:GetAbilityDamage();
	local nRadius = abilityIG:GetSpecialValueInt( "split_radius" );
	
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastIgniteOnTarget( npcTarget )   )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ) )
		then
			print(npcTarget:GetUnitName());
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local tableNearbyEnemyCreeps = npcTarget:GetNearbyLaneCreeps( nRadius, false );
			for _,h in pairs(tableNearbyEnemyHeroes) 
			do
				if h:GetUnitName() ~= npcTarget:GetUnitName() and  GetUnitToUnitDistance(h, npcTarget) < nRadius and CanCastIgniteOnTarget( h ) 
				then
					return BOT_ACTION_DESIRE_HIGH, h;
				end
			end
			for _,c in pairs (tableNearbyEnemyCreeps) 
			do
				if GetUnitToUnitDistance(c, npcTarget) < nRadius  and CanCastIgniteOnTarget( c ) 
				then
					return BOT_ACTION_DESIRE_HIGH, c;
				end
			end
			
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
					local tableNearbyEnemyHeroes = npcEnemy:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
					local tableNearbyEnemyCreeps = npcEnemy:GetNearbyLaneCreeps( nRadius, false );
					for _, h in pairs(tableNearbyEnemyHeroes) 
					do
						if h:GetUnitName() ~= npcEnemy:GetUnitName() and GetUnitToUnitDistance(h, npcEnemy) < nRadius and CanCastIgniteOnTarget( h ) 
						then
							return BOT_ACTION_DESIRE_HIGH, h;
						end
					end
					for _, c in pairs(tableNearbyEnemyCreeps) 
					do
						if GetUnitToUnitDistance(c, npcEnemy) < nRadius  and CanCastIgniteOnTarget( c ) 
						then
							return BOT_ACTION_DESIRE_HIGH, c;
						end
					end
				end
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, true );
			for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
				if ( GetUnitToUnitDistance( npcCreepTarget, npcBot  ) < nCastRange and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 and #tableNearbyEnemyCreeps >= 4 ) 
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastIgniteOnTarget(npcTarget) ) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local tableNearbyEnemyCreeps = npcTarget:GetNearbyLaneCreeps( nRadius, false );
			for _,h in pairs(tableNearbyEnemyHeroes) 
			do
				if h:GetUnitName() ~= npcTarget:GetUnitName() and GetUnitToUnitDistance(h, npcTarget) < nRadius and CanCastIgniteOnTarget( h ) 
				then
					return BOT_ACTION_DESIRE_HIGH, h;
				end
			end
			for _,c in pairs(tableNearbyEnemyCreeps) 
			do
				if GetUnitToUnitDistance(c, npcTarget) < nRadius  and CanCastIgniteOnTarget( c ) 
				then
					return BOT_ACTION_DESIRE_HIGH, c;
				end
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
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end

	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1300, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
		for _,npcAlly in pairs( tableNearbyAllyHeroes )
		do
			if ( ( npcAlly:GetHealth() / npcAlly:GetMaxHealth() ) < 0.25 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcAlly;
			end
		end
	end
	
	for _,npcAlly in pairs( tableNearbyAllyHeroes )
	do
		if npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.25 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcAlly;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFireblast()

	local npcBot = GetBot();

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
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local npcMostWeakEnemy = nil;
		local nMostWeakHP = 10000;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( #tableNearbyEnemyHeroes >= 3 ) then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( CanCastCurseOnTarget( npcEnemy ) )
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
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end

	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastCurseOnTarget( npcEnemy ) and tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 ) 
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
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			local NearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if ( CanCastCurseOnTarget( npcTarget ) and 
				GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 and 
				NearbyEnemyHeroes ~= nil and 
				#NearbyEnemyHeroes >= 3 )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

