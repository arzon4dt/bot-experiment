--local minion = dofile( GetScriptDirectory().."/MinionUtility" )
local castRTDesire = 0;
local castSRDesire = 0;
local RetreatDesire = 0;
local MoveDesire = 0;
local AttackDesire = 0;
local npcBotAR = 0;
local ProxRange = 1100;
local BearItem = {
	"item_stout_shield",
	"item_boots",
	"item_orb_of_venom",
	"item_blight_stone"
}
function  MinionThink(  hMinionUnit ) 

if not hMinionUnit:IsNull() and hMinionUnit ~= nil then 
	if string.find(hMinionUnit:GetUnitName(), "npc_dota_lone_druid_bear") then
		local npcBot = GetBot();
		if ( hMinionUnit:IsUsingAbility() or hMinionUnit:IsChanneling() or not hMinionUnit:IsAlive() ) then return end
			
		abilityFG = npcBot:GetAbilityByName( "lone_druid_spirit_bear" );	
		abilityES = npcBot:GetAbilityByName( "lone_druid_savage_roar" );
		abilityRT = hMinionUnit:GetAbilityByName( "lone_druid_spirit_bear_return" );
		abilitySR = hMinionUnit:GetAbilityByName( "lone_druid_savage_roar_bear" );
		
		BearPurchaseItem(hMinionUnit)
		
		castRTDesire = ConsiderReturn(hMinionUnit);
		castSRDesire = ConsiderSavageRoar(hMinionUnit);
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		RetreatDesire, RetreatLocation = ConsiderRetreat(hMinionUnit); 
		
		if castRTDesire > 0 then
			hMinionUnit:Action_UseAbility(abilityRT);
			return
		end
		if castSRDesire > 0 then
			hMinionUnit:Action_UseAbility(abilitySR);
			return
		end
		if ( RetreatDesire > 0 ) 
		then
			hMinionUnit:Action_MoveToLocation( RetreatLocation );
			return;
		end
		if (AttackDesire > 0)
		then
			--print("attack")
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		if (MoveDesire > 0)
		then
			--print("move")
			hMinionUnit:Action_MoveToLocation( Location );
			return
		end
	elseif hMinionUnit:IsIllusion() then
		--minion.GeneralMinionThink(hMinionUnit)
	end		
end		

end


function BearPurchaseItem(hMinionUnit)
	local npcBot = GetBot();
	if ( BearItem == nil or #(BearItem) == 0 ) then
		hMinionUnit:SetNextItemPurchaseValue( 0 );
		return;
	end
	local sNextItem = BearItem[1];
	hMinionUnit:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );
	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) and hMinionUnit:DistanceFromFountain() < 100 ) then
		if ( hMinionUnit:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS ) then
			table.remove( BearItem, 1 );
		end
	end	
end

function CanCastSavageRoarOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanBeAttacked( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function ConsiderReturn(hMinionUnit)

	local npcBot = GetBot();
	
	if RetreatDesire > 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if abilityFG:GetLevel() < 2  then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if 	 not abilityRT:IsFullyCastable() or abilityRT:IsHidden() 
	then
		return BOT_ACTION_DESIRE_NONE;
	end

	if hMinionUnit:DistanceFromFountain() > 0 and GetUnitToUnitDistance(hMinionUnit, npcBot) > ProxRange then
		return BOT_ACTION_DESIRE_MODERATE
	end
	
	if hMinionUnit:DistanceFromFountain() == 0 and ( hMinionUnit:GetHealth() / hMinionUnit:GetMaxHealth() ) == 1.0 and GetUnitToUnitDistance(hMinionUnit, npcBot) > ProxRange then
		return BOT_ACTION_DESIRE_MODERATE
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end

function ConsiderSavageRoar(hMinionUnit)

	local npcBot = GetBot();

	if abilityES:GetLevel() < 1 then
		return BOT_ACTION_DESIRE_NONE;
	end
		
	-- Make sure it's castable
	if ( not abilitySR:IsFullyCastable() or abilitySR:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius = abilitySR:GetSpecialValueInt( "radius" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) or RetreatDesire > 0 ) 
	then
		local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY 
		 ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			if ( CanCastSavageRoarOnTarget( npcTarget ) and 
				GetUnitToUnitDistance( npcTarget, hMinionUnit ) < nRadius and 
				( npcTarget:IsChanneling() or npcTarget:IsUsingAbility() ) 
				)
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if hMinionUnit:WasRecentlyDamagedByAnyHero( 2.0 ) and hMinionUnit:GetHealth() / hMinionUnit:GetMaxHealth() < 0.55 then
		local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderRetreat(hMinionUnit)
	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	
	if hMinionUnit:DistanceFromFountain() == 0 and hMinionUnit:GetHealth() / hMinionUnit:GetMaxHealth() < 1.0 then
		if GetTeam( ) == TEAM_DIRE then
			return BOT_ACTION_DESIRE_MODERATE, DB;
		elseif GetTeam( ) == TEAM_RADIANT then
			return BOT_ACTION_DESIRE_MODERATE, RB;
		end
	end
	
	if hMinionUnit:WasRecentlyDamagedByAnyHero( 2.0 ) and hMinionUnit:GetHealth() / hMinionUnit:GetMaxHealth() < 0.65 then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
	end
	
	if hMinionUnit:GetHealth() / hMinionUnit:GetMaxHealth() < 0.25 then
		if GetTeam( ) == TEAM_DIRE then
			return BOT_ACTION_DESIRE_MODERATE, DB;
		elseif GetTeam( ) == TEAM_RADIANT then
			return BOT_ACTION_DESIRE_MODERATE, RB;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end	

function ConsiderAttacking(hMinionUnit)
	local npcBot = GetBot();
	local target = npcBot:GetTarget();
	local AR = hMinionUnit:GetAttackRange();
	local OAR = npcBot:GetAttackRange();
	local AD = hMinionUnit:GetAttackDamage();
	
	if target ~= nil and CanBeAttacked(target) and GetUnitToUnitDistance(target, npcBot) <= OAR + 200 and GetUnitToUnitDistance(hMinionUnit, npcBot) <= ProxRange then
		--[[if target:IsTower() and GetUnitToUnitDistance(target, npcBot) > OAR then
			return BOT_ACTION_DESIRE_NONE, {};
		end]]--
		return BOT_ACTION_DESIRE_MODERATE, target;
	else
		if hMinionUnit:WasRecentlyDamagedByTower( 1.0 ) then
			local NearbyLaneCreeps = hMinionUnit:GetNearbyLaneCreeps(800, false);
			if NearbyLaneCreeps[1] ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, NearbyLaneCreeps[1];
			end
		end
		if npcBot:GetActiveMode() == BOT_MODE_LANING and GetUnitToUnitDistance(npcBot, hMinionUnit) < ProxRange then
			local NearbyLaneCreeps = hMinionUnit:GetNearbyLaneCreeps(1000, true);
			local TCreep = nil;
			for _,creep in pairs(NearbyLaneCreeps)
			do
				local CHealth = creep:GetHealth();
				if CHealth < 4*AD then
					TCreep = creep;
				end
			end
			if TCreep ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, TCreep;
			end
		elseif ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
				 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
				 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT 
				 ) 
		then
			local NearbyLaneCreeps = npcBot:GetNearbyLaneCreeps(1000, true);
			local TCreep = nil;
			local MinHealth = 10000;
			for _,creep in pairs(NearbyLaneCreeps)
			do
				local CHealth = creep:GetHealth();
				if CHealth < MinHealth then
					TCreep = creep;
					MinHealth = CHealth;
				end
			end
			if TCreep ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, TCreep;
			end
		elseif npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
				 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
				 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT
		then
			local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes == nil then
				local NearbyLaneCreeps = hMinionUnit:GetNearbyLaneCreeps(1000, true);
				local TCreep = nil;
				local MinHealth = 10000;
				for _,creep in pairs(NearbyLaneCreeps)
				do
					local CHealth = creep:GetHealth();
					if CHealth < MinHealth then
						TCreep = creep;
						MinHealth = CHealth;
					end
				end
				if TCreep ~= nil then
					return BOT_ACTION_DESIRE_MODERATE, TCreep;
				end
			end
		elseif 	npcBot:GetActiveMode() == BOT_MODE_FARM 
		then
			local NearbyCreeps = npcBot:GetNearbyCreeps(1000, true);
			local TCreep = nil;
			local MinHealth = 10000;
			for _,creep in pairs(NearbyCreeps)
			do
				local CHealth = creep:GetHealth();
				if CHealth < MinHealth then
					TCreep = creep;
					MinHealth = CHealth;
				end
			end
			if TCreep ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, TCreep;
			end
		end
		
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderMove(hMinionUnit)

	local npcBot = GetBot();
	local target = npcBot:GetTarget()
	
	if AttackDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if target == nil or ( target ~= nil and not CanBeAttacked(target) ) or (target ~= nil and GetUnitToUnitDistance(target, npcBot) > ProxRange) then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end


	