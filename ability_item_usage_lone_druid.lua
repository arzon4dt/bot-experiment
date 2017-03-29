local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local castFGDesire = 0;
local castOPDesire = 0;
local castESDesire = 0;
local castTFDesire = 0;
local castDFDesire = 0;
local castBCDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityFG = npcBot:GetAbilityByName( "lone_druid_spirit_bear" );
	abilityOP = npcBot:GetAbilityByName( "lone_druid_rabid" );
	abilityES = npcBot:GetAbilityByName( "lone_druid_savage_roar" );
	abilityTF = npcBot:GetAbilityByName( "lone_druid_true_form" );
	abilityDF = npcBot:GetAbilityByName( "lone_druid_true_form_druid" );
	abilityBC = npcBot:GetAbilityByName( "lone_druid_true_form_battle_cry" );
	
	-- Consider using each ability
	castFGDesire, castFGTarget = ConsiderFleshGolem();
	castOPDesire = ConsiderOverpower();
	castESDesire = ConsiderEarthshock();
	castTFDesire = ConsiderTrueForm();
	castDFDesire = ConsiderDruidForm();
	castBCDesire = ConsiderBattleCry();
	
	if ( castFGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityFG );
		return;
	end
	if ( castOPDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityOP );
		return;
	end
	if ( castESDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityES );
		return;
	end
	if ( castTFDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTF );
		return;
	end
	if ( castDFDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityDF );
		return;
	end
	if ( castBCDesire > 0 ) 
	then
		print("Use bc")
		npcBot:Action_UseAbility( abilityBC );
		return;
	end
	
end

function CanCastEarthshockOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function ConsiderFleshGolem()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local numBear = 0;
	
	local listFamiliar = GetUnitList(UNIT_LIST_ALLIES);
	for _,unit in pairs(listFamiliar)
	do
		if string.find(unit:GetUnitName(), "npc_dota_lone_druid_bear") then
			numBear = numBear + 1;
		end
	end
	
	if  numBear == 0 then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderOverpower()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityOP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local attackRange = npcBot:GetAttackRange();
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	-- If we're pushing a lane 
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 1000, true );
		local tableNearbyEnemyBarracks = npcBot:GetNearbyBarracks( 1000, true );
		local EnemyAncient = GetAncient( GetOpposingTeam() );
		if tableNearbyEnemyTowers ~= nil or tableNearbyEnemyBarracks ~= nil or abilityOP:GetLevel() == 4 or
			( EnemyAncient ~= nil and GetUnitToUnitDistance(EnemyAncient, npcBot) < attackRange )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and string.find(npcTarget:GetUnitName(),"roshan") and GetUnitToUnitDistance(npcTarget, npcBot) < attackRange +  200 )
		then
			return BOT_ACTION_DESIRE_LOW;
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
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < attackRange + 200 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderEarthshock()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityES:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilityES:GetSpecialValueInt( "radius" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and CanCastEarthshockOnTarget( npcEnemy ) ) 
			then
					return BOT_ACTION_DESIRE_MODERATE;
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
			if ( CanCastEarthshockOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderTrueForm()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityTF:IsFullyCastable() or abilityTF:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes <= 2 and npcBot:WasRecentlyDamagedByAnyHero(1) and abilityBC:IsHidden() then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if tableNearbyEnemyTowers[1] ~= nil and GetUnitToUnitDistance(tableNearbyEnemyTowers[1], npcBot) < 800 and 
			abilityBC:IsFullyCastable() and abilityBC:IsHidden()
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
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < 1000 and abilityBC:IsFullyCastable() and abilityBC:IsHidden()  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderDruidForm()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDF:IsFullyCastable() or abilityDF:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes == nil and not abilityBC:IsHidden() then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if tableNearbyEnemyTowers[1] ~= nil and GetUnitToUnitDistance(tableNearbyEnemyTowers[1], npcBot) < 800 and 
			not abilityBC:IsFullyCastable() and not abilityBC:IsHidden()
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if npcBot:DistanceFromFountain() < 100 and not abilityBC:IsHidden() then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if tableNearbyEnemyHeroes == nil and not abilityBC:IsHidden() then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < 1000 and not abilityBC:IsFullyCastable() and not abilityBC:IsHidden() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderBattleCry()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityBC:IsFullyCastable() or abilityBC:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if tableNearbyEnemyTowers[1] ~= nil and GetUnitToUnitDistance(tableNearbyEnemyTowers[1], npcBot) < 800 then
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
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < 1000 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end