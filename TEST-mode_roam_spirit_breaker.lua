if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local npcBot = GetBot();
local roamDistance = 600;
local npcTarget = nil;
local RADBase = Vector(-7200,-6666);
local DIREBase = Vector(7137,6548);
local cod = nil;

function GetDesire()
	
	if npcBot:IsIllusion() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if cod == nil then cod = npcBot:GetAbilityByName( "spirit_breaker_charge_of_darkness" ) end
	
	if cod:IsInAbilityPhase()or npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness")
	then
		return BOT_MODE_DESIRE_ABSOLUTE;
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
	else	
		return;
	end
	
	local target = FindTarget();
	
	if target ~= nil   
	then
		npcBot:Action_MoveToLocation(target:GetLocation());
		return;
	end

end

function GetBase()
	return GetAncient(GetOpposingTeam()):GetLocation();
end

function ConsiderCancelCharge()
	local target = npcBot.chargeTarget;
	if target ~= nil and not target:IsNull() and target:IsHero()
	then
		local targetAlly = target:GetNearbyHeroes(1300, false, BOT_MODE_NONE);
		local Ally = target:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		if Ally ~= nil and #Ally > 0
		then
			return false;
		elseif target:GetHealth() < 200 then
			return false;
		elseif GetUnitToUnitDistance(target, GetAncient(GetOpposingTeam())) < 2500 or ( targetAlly ~= nil and #targetAlly >= 2 ) 
		then
			npcBot:ActionImmediate_Chat("Canceling charge. "..tostring(#targetAlly).." enemies no ally.", true);
			npcBot:ActionImmediate_Chat("or target way too close to their base", true);
			return true;
		end
	elseif target ~= nil and not target:IsNull() and not target:IsHero() then
		return false;
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