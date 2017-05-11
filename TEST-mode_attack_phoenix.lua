local npcBot = GetBot();
function GetDesire()

	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() )
	then 
		return BOT_MODE_DESIRE_NONE;
	end

	if IsAllyOffensivePowerGreater() then
		if npcBot:GetLevel() < 6 then
			local nearbyEnemyTower = npcBot:GetNearbyTowers(nRange, true);
			if #nearbyEnemyTower == nil then
				return BOT_MODE_DESIRE_VERYHIGH;
			end
		else
			return BOT_MODE_DESIRE_VERYHIGH;
		end
	end
	
	return BOT_MODE_DESIRE_NONE;
end

function OnStart()
	local enemys = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local WeakestEnemy,HeroHealth=GetWeakestUnit(enemys)
	npcBot:SetTarget(WeakestEnemy)
end

function OnEnd()
	npcBot:SetTarget(nil)
end

function Think()
	local npcEnemy = npcBot:GetTarget();
	local AttackRange = npcBot:GetAttackRange();
	if npcEnemy ~= nil then
		local d=GetUnitToUnitDistance(npcBot,npcEnemy)
		if( d <= AttackRange )
		then
			npcBot:Action_AttackUnit(npcEnemy,true);
			return
		else
			npcBot:Action_MoveToUnit(npcEnemy);
			return
		end
	end
end


function GetWeakestUnit(EnemyUnits)
	
	if EnemyUnits==nil or #EnemyUnits==0 then
		return nil,10000;
	end
	
	local WeakestUnit=nil;
	local LowestHealth=10000;
	for _,unit in pairs(EnemyUnits) 
	do
		if unit~=nil and unit:IsAlive() 
		then
			if unit:GetHealth()<LowestHealth 
			then
				LowestHealth=unit:GetHealth();
				WeakestUnit=unit;
			end
		end
	end
	
	return WeakestUnit,LowestHealth
end

function IsAllyOffensivePowerGreater()

	local AllyOffensivePower = GetTotalOffensivePower(false, 1600);
	local EnemyOffensivePower =  GetTotalOffensivePower(true, 1600);
	--print("AOP = "..tostring(AllyOffensivePower).." >< ".."EOP = "..tostring(EnemyOffensivePower));
	
	return AllyOffensivePower ~= 0 and EnemyOffensivePower ~= 0 and AllyOffensivePower >= EnemyOffensivePower;
	
end

function GetTotalOffensivePower(bEnemy, nRange)
	
	local TotalOffensivePower = 0;
	
	if not bEnemy then
		local nearbyAlly = npcBot:GetNearbyHeroes(nRange, false, BOT_MODE_NONE);
		local nearbyAllyTower = npcBot:GetNearbyTowers(nRange, false);
		local nearbyAllyCreeps = npcBot:GetNearbyLaneCreeps(nRange, false);
		
		TotalOffensivePower = CountTotalOffensivePower(nearbyAlly, true) + CountTotalOffensivePower(nearbyAllyTower, false) +  CountTotalOffensivePower(nearbyAllyCreeps, false)
		
	else
		local nearbyEnemy = npcBot:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
		local nearbyEnemyTower = npcBot:GetNearbyTowers(nRange, true);
		local nearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(nRange, true);
		
		local TotalEnemyOP = CountTotalOffensivePower(nearbyEnemy, true);
		
		if TotalEnemyOP ~= 0 then
		
			TotalOffensivePower = TotalEnemyOP + CountTotalOffensivePower(nearbyEnemyTower, false) +  CountTotalOffensivePower(nearbyEnemyCreeps, false)
		
		end
	end
	
	return TotalOffensivePower;
	
end

function CountTotalOffensivePower(tableOfUnit, bHero)
	local OP = 0;
	if bHero then
		for _,unit in pairs(tableOfUnit) 
		do
			OP = OP + unit:GetRawOffensivePower();
		end
	else
		for _,unit in pairs(tableOfUnit) 
		do
			OP = OP + unit:GetAttackDamage();
		end
	end
	return OP;
end
----------------------------------------------------------------------------------------------------