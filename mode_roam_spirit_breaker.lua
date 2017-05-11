if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local npcBot = GetBot();
local roamDistance = 600;
local npcTarget = nil;
local RADBase = Vector(-7200,-6666);
local DIREBase = Vector(7137,6548);

function GetDesire()
	
	if npcBot:IsIllusion() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness")
	then
		return BOT_MODE_DESIRE_ABSOLUTE;
	end
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() 
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	local target = FindTarget();
	
	if target ~= nil   
	then
	    npcTarget = target;	
		return npcBot:GetHealth() / npcBot:GetMaxHealth()
	end
	
	return BOT_MODE_DESIRE_NONE;
	
end

function OnStart()
	npcBot:SetTarget(npcTarget);
end

function OnEnd()
	npcBot:SetTarget(nil);
	npcTarget = nil;
end

function Think()
	
	if npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness")
	then
		if ConsiderCancelCharge() then
			npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(200));
			return;
		else
			return;
		end
	end
	
	local target = FindTarget();
	
	if target ~= nil   
	then
		npcBot:Action_MoveToLocation(target:GetLocation());
		return;
	end

end

function GetBase(Team)
	if Team == TEAM_RADIANT then
		return RADBase;
	else
		return DIREBase;
	end
end

function ConsiderCancelCharge()
	local target = npcBot:GetTarget();
	if target ~= nil 
	then
		local targetAlly = target:GetNearbyHeroes(1300, false, BOT_MODE_NONE);
		local Ally = target:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		if Ally ~= nil 
		then
			return false
		elseif GetUnitToLocationDistance(target, GetBase(GetOpposingTeam())) < 2500 or ( targetAlly ~= nil and #targetAlly >= 2 ) 
		then
			--print(tostring(#targetAlly))
			--print("Cancel")
			return true;
		end
	end
	return false;
end

function IsValidTarget(target)
	return  target ~= nil 
			and target:IsAlive() 
			and target:CanBeSeen() 
			and target:IsHero() 
			and not target:IsIllusion() 
			and GetUnitToUnitDistance(target, npcBot) > roamDistance
end

function FindLowHPTarget()
	local enemyheroes = GetUnitList(UNIT_LIST_ENEMY_HEROES );
	for _,enemy in pairs(enemyheroes)
	do
		if enemy:GetHealth() < 100 + ( enemy:GetLevel() * 10 ) then
			return enemy;
		end
	end
	return nil;
end

function FindSuroundedEnemy()
	local enemyheroes = GetUnitList(UNIT_LIST_ENEMY_HEROES );
	for _,enemy in pairs(enemyheroes)
	do
		local allyNearby = enemy:GetNearbyHeroes(1200, false, BOT_MODE_ATTACK);
		if allyNearby ~= nil and #allyNearby >= 2 then
			return enemy;
		end
	end
	return nil;
end

function FindAllyTarget()
	local allyheroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);
	for _,ally in pairs(allyheroes)
	do
		local target = ally:GetTarget();
		if IsValidTarget(target) then
			return target;
		end
	end
	return nil;
end

function FindTarget()
	
	local target  = nil;
	
	target = npcBot:GetTarget();
	
	if IsValidTarget(target) then
		return target;	
	end
	
	target = FindLowHPTarget();
	
	if IsValidTarget(target) then
		return target;
	end
	
	target = FindSuroundedEnemy();
	
	if IsValidTarget(target) then
		return target;
	end
	
	target = FindAllyTarget();
	
	if IsValidTarget(target) then
		return target;
	end
	
	return target;
	
end