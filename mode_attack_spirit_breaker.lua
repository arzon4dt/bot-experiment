----------------------------------------------------------------------------
--	Ranked Matchmaking AI v1.0a
--	Author: adamqqq		Email:adamqqq@163.com
----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function Think()
	local npcBot = GetBot();
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() or npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") )
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
		else
			npcBot:Action_MoveToUnit(npcEnemy);
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
	end
	
	return
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