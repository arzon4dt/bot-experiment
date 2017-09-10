local npcBot = GetBot();
local moveDesire = 0;
local attackDesire = 0;
local ProxRange = 1300;

function  MinionThink(  hMinionUnit ) 	
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then
		if IsSerpentWard(hMinionUnit:GetUnitName()) then
			attackDesire, attackTarget = ConsiderAttackOnNonMoveableUnit(hMinionUnit);
			if attackDesire > 0 then
				hMinionUnit:Action_AttackUnit( attackTarget, true );
				return
			end
		elseif hMinionUnit:IsIllusion() then
			return;
		end
	end
end

function IsSerpentWard(sName)
	return sName == 'npc_dota_shadow_shaman_ward_1' or sName == 'npc_dota_shadow_shaman_ward_2' or sName == 'npc_dota_shadow_shaman_ward_3'; 
end

function ConsiderAttackOnNonMoveableUnit(hMinionUnit)
	local attackRange = hMinionUnit:GetAttackRange();
	local target = GetPriorityTarget(hMinionUnit, attackRange);
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target;
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end

function CanBeAttackedByNonMoveableUnit(target, nAttackRange)
	return target ~= nil and not target:IsInvulnerable() and GetUnitToUnitDistance(target, hMinionUnit) < nAttackRange
end

function GetPriorityTarget(hMinionUnit, nRadius)
	local target =  npcBot:GetTarget();
	if not CanBeAttackedByNonMoveableUnit(target, nRadius) then
		target = npcBot:GetAttackTarget();
	end
	if not CanBeAttackedByNonMoveableUnit(target, nRadius) then
		target = GetWeakestHeroes(hMinionUnit, nRadius);
	end
	if not CanBeAttackedByNonMoveableUnit(target, nRadius) then
		target = GetWeakestTower(hMinionUnit, nRadius);
	end
	if not CanBeAttackedByNonMoveableUnit(target, nRadius) then
		target = GetWeakestBarrack(hMinionUnit, nRadius);
	end
	if not CanBeAttackedByNonMoveableUnit(target, nRadius) then
		target = GetWeakestCreep(hMinionUnit, nRadius);
	end
	return target;
end

function GetWeakestHeroes(hMinionUnit, nRadius)
	local minHP = 100000;
	local target = nil;
	local units = hMinionUnit:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
	for _,unit in pairs(units) do
		if unit ~= nil and not unit:IsInvulnerable() and unit:GetHealth() < minHP then
			target = unit;
			minHP = unit:GetHealth();
		end
	end
	return target;
end

function GetWeakestTower(hMinionUnit, nRadius)
	local minHP = 100000;
	local target = nil;
	local units = hMinionUnit:GetNearbyTowers(nRadius, true);
	for _,unit in pairs(units) do
		if unit ~= nil and not unit:IsInvulnerable() and unit:GetHealth() < minHP then
			target = unit;
			minHP = unit:GetHealth();
		end
	end
	return target;
end

function GetWeakestBarrack(hMinionUnit, nRadius)
	local minHP = 100000;
	local target = nil;
	local units = hMinionUnit:GetNearbyBarracks(nRadius, true);
	for _,unit in pairs(units) do
		if unit ~= nil and not unit:IsInvulnerable() and unit:GetHealth() < minHP then
			target = unit;
			minHP = unit:GetHealth();
		end
	end
	return target;
end

function GetWeakestCreep(hMinionUnit, nRadius)
	local minHP = 100000;
	local target = nil;
	local units = hMinionUnit:GetNearbyCreeps(nRadius, true);
	for _,unit in pairs(units) do
		if unit ~= nil and not unit:IsInvulnerable() and unit:GetHealth() < minHP then
			target = unit;
			minHP = unit:GetHealth();
		end
	end
	return target;
end