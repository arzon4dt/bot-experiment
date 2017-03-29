local MinScore=0;
local MinHp=0.37;

function  OnStart()
	local npcBot=GetBot();
	
	if npcBot.Target==nil then
		npcBot.IsAttacking=false;
		npcBot.MyDamage=0;
		return;
	end
	
	npcBot:ActionImmediate_Chat("Trying to kill "..npcBot.Target:GetUnitName(),false);
	npcBot.IsAttacking=true;
end

function OnEnd()
	local npcBot=GetBot();
	npcBot.IsAttacking=false;
end

function GetDesire()
	local npcBot=GetBot();
	
	if npcBot:GetHealth()/npcBot:GetMaxHealth()<MinHp then 
		npcBot.IsAttacking=false;
		npcBot.Target=nil;
		npcBot.MyDamage=0;
		return 0.0;
	end
	
	if npcBot.IsAttacking==nil then
		npcBot.IsAttacking=false;
		npcBot.Target=nil;
		npcBot.MyDamage=0;
	end
	
	local WeakestHero=nil;
	local Score=0;
	local Damage=0;
	
	WeakestHero,Damage,Score = FindTarget(1400);
	npcBot.Target=WeakestHero;
	npcBot.MyDamage=Damage;
	npcBot.AttackScore=Score;
	
	if (not NotNilOrDead(WeakestHero)) or (not WeakestHero:CanBeSeen()) then
		npcBot.IsAttacking=false;
		npcBot.Target=nil;
		npcBot.MyDamage=0;
		return 0.0;
	end
	
--	print(npcBot:GetUnitName(),Damage,Score,WeakestHero:GetUnitName());
	
	if npcBot.IsAttacking then
		--[[if npcBot.ShouldPush~=nil and npcBot.ShouldPush then
			return 0.6;
		end]]--
		return 0.5;
	end

	local AlliesScore=Score;
	local AlliesDamage=Damage;
	
	if npcBot.AttackScore<MinScore then
		npcBot.IsAttacking=false;
		npcBot.Target=nil;
		npcBot.MyDamage=0;
		return 0.0;
	end
	
	for i=1,5,1 do
		local Ally=GetTeamMember(i);
		if NotNilOrDead(Ally) and NotNilOrDead(Ally.Target) and Ally.Target:GetUnitName()==npcBot:GetUnitName() and GetUnitToUnitDistance(Ally,Target)<1200 and Ally:GetHealth()/Ally:GetMaxHealth()>MinHp then
			AlliesScore=AlliesScore+Ally.AttackScore;
			AlliesDamage=AlliesDamage+Ally.MyDamage;
		end
	end
	
	if AlliesDamage > npcBot.Target:GetHealth() and AlliesScore>1 then
		npcBot.IsAttacking=true;
		--[[if npcBot.ShouldPush~=nil and npcBot.ShouldPush then
			return 0.6;
		end]]--
		return 0.5;
	end
	
	return 0.0;
end

function Think()
	local npcBot=GetBot();
	
	local AlliesScore=npcBot.AttackScore;
	local AlliesDamage=npcBot.MyDamage;
	
	if (not NotNilOrDead(npcBot.Target)) then
		npcBot.IsAttacking=false;
		return;
	end
	
	for i=1,5,1 do
		local Ally=GetTeamMember(i);
		if NotNilOrDead(Ally) and NotNilOrDead(Ally.Target) and Ally.Target:GetUnitName()==npcBot:GetUnitName() and GetUnitToUnitDistance(Ally,Target)<1200  and Ally:GetHealth()/Ally:GetMaxHealth()>MinHp  then
			AlliesScore=AlliesScore+Ally.AttackScore;
			AlliesDamage=AlliesDamage+Ally.MyDamage;
		end
	end
	
	if AlliesScore<0.6 or npcBot.Target:GetHealth()>AlliesDamage then
		npcBot.IsAttacking=false;
		return;
	end
	
	if not npcBot.IsAttacking or npcBot.Target==nil then
		return;
	end
	
	if npcBot:IsChanneling() or npcBot:IsUsingAbility() then
		return;
	end
	
	local enemy=npcBot.Target;
	
	npcBot:Action_AttackUnit(enemy,true);
	return
end

function NotNilOrDead(unit)
	if unit==nil or unit:IsNull() then
		return false;
	end
	if unit:IsAlive() then
		return true;
	end
	return false;
end

function Fountain(team)
	if team==TEAM_RADIANT then
		return Vector(-7093,-6542);
	end
	return Vector(7015,6534);
end

function FindTarget(dist)
	--npcBot:GetEstimatedDamageToTarget( true, WeakestCreep, AttackSpeed, DAMAGE_TYPE_PHYSICAL )
	local npcBot=GetBot();
	
	local mindis=100000;
	local candidate=nil;
	local MaxScore=-1;
	local damage=0;
	
	local Enemies=npcBot:GetNearbyHeroes(dist,true,BOT_MODE_NONE);
	
	if Enemies==nil or #Enemies==0 then
		return nil,0.0,0.0;
	end
	
	local Towers=npcBot:GetNearbyTowers(1100,true);
	local AlliedTowers=npcBot:GetNearbyTowers(950,false);
	local AlliedCreeps=npcBot:GetNearbyLaneCreeps(1000,false);
	local EnemyCreeps=npcBot:GetNearbyLaneCreeps(700,true);
	local nEc=0;
	local nAc=0;
	if AlliedCreeps~=nil then
		nAc=#AlliedCreeps;
	end
	if EnemyCreeps~=nil then
		nEc=#EnemyCreeps;
	end
	
	local nTo=0;
	if Towers~=nil then
		nTo=#Towers;
	end
	
	local fTo=0;
	if AlliedTowers~=nil then
		fTo=#AlliedTowers;
	end
	
	local lvl=npcBot:GetLevel();
	if lvl==nil then
		lvl=25;
	end
	
	for _,enemy in pairs(Enemies) do
		if NotNilOrDead(enemy) and enemy:GetHealth()>0 and GetUnitToLocationDistance(enemy,Fountain(GetOpposingTeam()))>1350  
		then
			local myDamage=npcBot:GetEstimatedDamageToTarget(true,enemy,4.5,DAMAGE_TYPE_ALL);

			local nfriends=0;
			local NearbyEnemyFriends = enemy:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
			for _,enemy2 in pairs(NearbyEnemyFriends) do
				if NotNilOrDead(enemy2) and enemy2:GetUnitName() ~= enemy:GetUnitName() and enemy2:GetHealth()>0 then
					if GetUnitToUnitDistance(enemy,enemy2)<1200 and enemy2:GetHealth()/enemy2:GetMaxHealth()>0.4 then
						nfriends=nfriends+1;
					end
				end
			end
			
			local nMyFriends=0;
			for j =1,5,1 do
				local Ally=GetTeamMember(j);
				if NotNilOrDead(Ally) and GetUnitToUnitDistance(enemy,Ally)<1200 then
					if Ally:GetActiveMode()==BOT_MODE_RETREAT then
						nMyFriends=nMyFriends+3;
					else
						nMyFriends=nMyFriends+1.1;
					end
				end
			end
			
			local score= Min(myDamage/enemy:GetHealth(),4) + (nMyFriends)/1.7 - (nfriends)/1.7 - GetUnitToUnitDistance(enemy,npcBot)/3500 -(1-npcBot:GetHealth()/npcBot:GetMaxHealth()) - nTo/(Min(lvl/8,3)) + fTo/(Min(lvl/8,3)) - nEc/(2*lvl) + nAc/(2*lvl);
			if score>MaxScore then
				damage=myDamage;
				candidate=enemy;
				MaxScore=score;
			end
		end
	end
	
	return candidate,damage,MaxScore;
end
