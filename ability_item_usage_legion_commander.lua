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

local castOODesire = 0;
local castDLDesire = 0;
local castPTADesire = 0;
local ItemBM = nil;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityOO = npcBot:GetAbilityByName( "legion_commander_overwhelming_odds" );
	abilityDL = npcBot:GetAbilityByName( "legion_commander_duel" );
	abilityPTA = npcBot:GetAbilityByName( "legion_commander_press_the_attack" );
	BMSlot = npcBot:FindItemSlot('item_blade_mail');
	if BMSlot >= 0 and BMSlot <= 5 then
		ItemBM = npcBot:GetItemInSlot(BMSlot);
	else
		ItemBM = nil;
	end

	-- Consider using each ability
	castPTADesire, castPTATarget = ConsiderPressTheAttack();
	castDLDesire, castDLTarget = ConsiderDuel();
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();

	if ItemBM ~= nil and ItemBM:IsFullyCastable() and castDLDesire > 0 then
		npcBot:Action_UseAbility( ItemBM );
		return;
	end
	
	if ( castPTADesire > castDLDesire and  castPTADesire > castOODesire) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityPTA, castPTATarget );
		return;
	end

	if ( castDLDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDL, castDLTarget );
		return;
	end
	
	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	

end

function CanCastOverWhelmingOddsOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function CanCastDuelOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function isDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end

function ConsiderOverwhelmingOdds()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
--
	-- If we want to cast Laguna Blade at all, bail
	--[[if ( castDLDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end]]--

	-- Get some of its values
	local nRadius = abilityOO:GetSpecialValueInt( "radius" );
	local nCastRange = abilityOO:GetCastRange();
	local nCastPoint = abilityOO:GetCastPoint( );
	local nDamage = abilityOO:GetSpecialValueInt("damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastOverWhelmingOddsOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:IsHero() and  npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange -300 ) )
		then
			--[[if npcTargetToKill:IsFacingUnit( npcBot, 45 ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetLocation();
			else
				return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetXUnitsInFront(300);
			end]]--
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( nCastPoint );
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 1000 );

		if ( locationAoE.count >= 3 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6 ) then
		--print("WA Farm");
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
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
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 1000 );

		if ( locationAoE.count >= 4 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - 200 and CanCastOverWhelmingOddsOnTarget( npcTarget )  ) 
		then
			--[[if npcTarget:IsFacingUnit( npcBot, 45 ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			else
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetXUnitsInFront(300);
			end]]--
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDuel()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityDL:GetCastRange();
	local nDamage = 500;
	
	-- If enemy is channeling cancel it
	local npcTarget = npcBot:GetTarget();
	if (npcTarget ~= nil and npcTarget:IsChanneling() and GetUnitToUnitDistance( npcTarget, npcBot ) < 2*nCastRange)
	then
		return BOT_ACTION_DESIRE_MODERATE, npcTarget;
	end
	
	-- If a mode has set a target, and we can kill them, do it
	--local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and CanCastDuelOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < 2*nCastRange )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastDuelOnTarget( npcEnemy ) )
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
			return BOT_ACTION_DESIRE_MODERATE, npcMostDangerousEnemy;
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < 2*nCastRange ) 
		then
			if ( CanCastDuelOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderPressTheAttack()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPTA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRangeU = abilityDL:GetCastRange();
	local nCastRange = abilityPTA:GetCastRange();
	
	if npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.5 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.5 then
		return BOT_ACTION_DESIRE_LOW, npcBot;
	end
	
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
	
	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local lowHpAlly = nil;
		local nLowestHealth = 1000;

		local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( CanCastDuelOnTarget( npcAlly ) )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) or isDisabled(npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end

		if ( lowHpAlly ~= nil )
		then
			return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < 2*nCastRangeU ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

