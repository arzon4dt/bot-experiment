----------------------------------------------------------------------------
--	Ranked Matchmaking AI v1.0a
--	Author: adamqqq		Email:adamqqq@163.com
----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function GetDesire()
	local npcBot = GetBot();
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() )
	then 
		return (0.0)
	end
	
	local npcEnemy = npcBot:GetTarget();
	if ( npcEnemy ~= nil and npcEnemy:IsAlive() and GetUnitToUnitDistance(npcBot,npcEnemy) < npcBot:GetAttackRange() + 200) 
	then
			--print("Attack Target")
			return BOT_MODE_DESIRE_HIGH;
	else
		local enemys = npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE)
		local WeakestEnemy,HeroHealth=GetWeakestUnit(enemys)
		local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		for i,npcAlly in pairs(allys) 
		do	
			local target=npcAlly:GetTarget()
			if(target~=nil and target:IsAlive() and GetUnitToUnitDistance(npcBot,target) < npcBot:GetAttackRange() + 200)
			then
				--print("Attack Ally Target")
				return BOT_MODE_DESIRE_HIGH
			end
		end
		--print("Attack Ally Weakest")	
		if WeakestEnemy ~= nil and WeakestEnemy:IsAlive() and GetUnitToUnitDistance(npcBot,WeakestEnemy) < npcBot:GetAttackRange() + 200 then
			return BOT_MODE_DESIRE_HIGH
		end	
	end
	return (0.0)
end


function Think()
	local npcBot = GetBot();
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() )
	then 
		return
	end
	
	local npcEnemy = npcBot:GetTarget();
	if ( npcEnemy ~= nil and npcEnemy:IsAlive()) 
	then
		local d=GetUnitToUnitDistance(npcBot,npcEnemy)
		if(d<600)
		then
			npcBot:Action_AttackUnit(npcEnemy,true);
			return
		else
			npcBot:Action_MoveToUnit(npcEnemy);
			return
		end
	else
		local enemys = npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE)
		local WeakestEnemy,HeroHealth=GetWeakestUnit(enemys)
		local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		for i,npcAlly in pairs(allys) 
		do	
			local target=npcAlly:GetTarget()
			if(target~=nil)
			then
				npcBot:SetTarget(target)
				npcBot:Action_AttackUnit(target,true);
				return
			end
		end
		npcBot:SetTarget(WeakestEnemy)
		npcBot:Action_AttackUnit(WeakestEnemy,true);
		return
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

----------------------------------------------------------------------------------------------------