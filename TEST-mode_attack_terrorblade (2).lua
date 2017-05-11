local ThresholdDist = 1300;
function GetDesire()
	local Bot = GetBot();
	
	if ( Bot:IsUsingAbility() or Bot:IsChanneling() or Bot:IsSilenced() )
	then 
		return (0.0)
	end
	
	--[[local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local player = GetTeamMember(i);
		if player ~= nil and IsPlayerBot(player:GetPlayerID()) then
			print(player:GetUnitName()..player.test);
		end
	end]]--
	
	local NearbyEnemies = Bot:GetNearbyHeroes(ThresholdDist, true, BOT_MODE_NONE);
	local NearbyAllies = Bot:GetNearbyHeroes(ThresholdDist, false, BOT_MODE_ATTACK);
	local NearbyEnemyCreeps = Bot:GetNearbyLaneCreeps(ThresholdDist, true);
	local NearbyAllyCreeps = Bot:GetNearbyLaneCreeps(ThresholdDist, false);
	local NearbyEnemyTowers = Bot:GetNearbyTowers(ThresholdDist, true);
	local NearbyAllyTowers = Bot:GetNearbyTowers(ThresholdDist, false);
	
	local level = Bot:GetLevel();
	local health = Bot:GetHealth()/Bot:GetMaxHealth();
	
	if health < 0.15 then
		return (0.0);
	end
		
	if NearbyEnemies ~= nil and #NearbyEnemies == 1 then
		local enemy = NearbyEnemies[1];
		if enemy ~= nil and CanBeAttacked(enemy) and Bot:GetOffensivePower() >= enemy:GetOffensivePower() then
			return BOT_MODE_DESIRE_HIGH;
		end
	end
	
	if level <= 6 then
		if NearbyAllies ~= nil and #NearbyAllies >= 1 and
		   #NearbyAllyCreeps > #NearbyEnemyCreeps and
		   #NearbyEnemyTowers == 0
		then
			local WeakestEnemy = nil;
			local LowerHealth = 20000;
			for _,enemy in pairs(NearbyEnemies)
			do
				local eHealth = enemy:GetHealth();
				if eHealth < LowerHealth then
					LowerHealth = eHealth;
					WeakestEnemy = enemy;
				end
			end	
			if WeakestEnemy ~= nil and CanBeAttacked(WeakestEnemy) then
				return BOT_MODE_DESIRE_HIGH;
			end	
		end
	elseif level > 6 then
		if NearbyAllies ~= nil and #NearbyAllies >= 1 and
		   #NearbyAllyCreeps > #NearbyEnemyCreeps and
		   #NearbyEnemyTowers == 0
		then
			local WeakestEnemy = nil;
			local LowerHealth = 20000;
			for _,enemy in pairs(NearbyEnemies)
			do
				local eHealth = enemy:GetHealth();
				if eHealth < LowerHealth then
					LowerHealth = eHealth;
					WeakestEnemy = enemy;
				end
			end	
			if WeakestEnemy ~= nil and CanBeAttacked(WeakestEnemy) then
				return BOT_MODE_DESIRE_HIGH;
			end	
		end
	end
	
	return(0.0)
end

function Think()
	local Bot = GetBot();
		
	local NearbyEnemies = Bot:GetNearbyHeroes(ThresholdDist, true, BOT_MODE_NONE);
	local NearbyAllies = Bot:GetNearbyHeroes(ThresholdDist, false, BOT_MODE_ATTACK);
	local NearbyEnemyCreeps = Bot:GetNearbyLaneCreeps(ThresholdDist, true);
	local NearbyAllyCreeps = Bot:GetNearbyLaneCreeps(ThresholdDist, false);
	local NearbyEnemyTowers = Bot:GetNearbyTowers(ThresholdDist, true);
	local NearbyAllyTowers = Bot:GetNearbyTowers(ThresholdDist, false);
	
	local level = Bot:GetLevel();
	local attackRange = Bot:GetAttackRange();
	
	if NearbyEnemies ~= nil and #NearbyEnemies == 1 then
		local enemy = NearbyEnemies[1];
		if enemy ~= nil and CanBeAttacked(enemy) and Bot:GetOffensivePower() >= enemy:GetOffensivePower() then
			local dist = GetUnitToUnitDistance(Bot, enemy);
			if(dist < attackRange)
			then
				Bot:Action_AttackUnit(enemy,true);
				return
			else
				Bot:Action_MoveToUnit(enemy);
				return
			end
		end
	end

	
	if level <= 6 then
		if NearbyAllies ~= nil and #NearbyAllies >= 1 and
		   #NearbyAllyCreeps > #NearbyEnemyCreeps and
		   #NearbyEnemyTowers == 0
		then
			local WeakestEnemy = nil;
			local LowerHealth = 20000;
			for _,enemy in pairs(NearbyEnemies)
			do
				local eHealth = enemy:GetHealth();
				if eHealth < LowerHealth then
					LowerHealth = eHealth;
					WeakestEnemy = enemy;
				end
			end	
			if WeakestEnemy ~= nil and CanBeAttacked(WeakestEnemy) then
				local dist = GetUnitToUnitDistance(Bot, WeakestEnemy);
				if(dist < attackRange)
				then
					Bot:Action_AttackUnit(WeakestEnemy,true);
					return
				else
					Bot:Action_MoveToUnit(WeakestEnemy);
					return
				end
			end	
		end
	elseif level > 6 then
		if NearbyAllies ~= nil and #NearbyAllies >= 1 and
		   #NearbyAllyCreeps > #NearbyEnemyCreeps and
		   #NearbyEnemyTowers == 0
		then
			local WeakestEnemy = nil;
			local LowerHealth = 20000;
			for _,enemy in pairs(NearbyEnemies)
			do
				local eHealth = enemy:GetHealth();
				if eHealth < LowerHealth then
					LowerHealth = eHealth;
					WeakestEnemy = enemy;
				end
			end	
			if WeakestEnemy ~= nil and CanBeAttacked(WeakestEnemy) then
				local dist = GetUnitToUnitDistance(Bot, WeakestEnemy);
				if(dist < attackRange)
				then
					Bot:Action_AttackUnit(WeakestEnemy,true);
					return
				else
					Bot:Action_MoveToUnit(WeakestEnemy);
					return
				end
			end	
		end
	end
	
	
end

function CanBeAttacked(enemy)
	return not enemy:IsInvulnerable() and enemy:CanBeSeen();
end