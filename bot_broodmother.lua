local MoveDesire = 0;
local AttackDesire = 0;
local npcBotAR = 200;
local ProxRange = 1000;
function  MinionThink(  hMinionUnit ) 
if not hMinionUnit:IsNull() and hMinionUnit ~= nil then 
	AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
	MoveDesire, Location = ConsiderMove(hMinionUnit); 
	
	if (AttackDesire > 0)
	then
		hMinionUnit:Action_AttackUnit( AttackTarget, true );
		return
	end
	if (MoveDesire > 0)
	then
		hMinionUnit:Action_MoveToLocation( Location );
		return
	end
end
end

function CanBeAttacked( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function ConsiderAttacking(hMinionUnit)
	local npcBot = GetBot();
	local target = npcBot:GetTarget();
	local AR = hMinionUnit:GetAttackRange();
	local AD = hMinionUnit:GetAttackDamage();
	
	if target ~= nil and CanBeAttacked(target) and GetUnitToUnitDistance(hMinionUnit, npcBot) <= ProxRange then
		return BOT_ACTION_DESIRE_MODERATE, target;
	else
		if hMinionUnit:WasRecentlyDamagedByTower( 2.0 ) then
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
				if CHealth < 10*AD then
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
			local NearbyCreeps = hMinionUnit:GetNearbyCreeps(1000, true);
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
	
	if target == nil or ( target ~= nil and not CanBeAttacked(target) ) or GetUnitToUnitDistance(hMinionUnit, npcBot) > ProxRange then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
