BotsInit = require( "game/botsinit" );
local MyModule = BotsInit.CreateGeneric();

local bot = GetBot();
local attackTarget = nil;
local nRange = 1300;

function GetDesire()
	if bot:IsUsingAbility() or bot:IsChanneling()  
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING then
		return BOT_MODE_DESIRE_NONE;
	end
	
	attackTarget = FindTarget();
	
	if attackTarget ~= nil then
		local desire = MeasureDesire(attackTarget);
		return desire;
	end
	
	return BOT_MODE_DESIRE_NONE;
end

function OnStart()
	bot:SetTarget(attackTarget);
end

function OnEnd()
	bot:SetTarget(nil);
end

function Think()
	local Target = bot:GetTarget();
	if Target ~= nil then
		bot:Action_AttackUnit(Target, true)
		return
	end
end

function FindTarget()
	local target = nil;
	local enemyheroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    for _,enemy in pairs(enemyheroes)
	do
		if IsValidTarget(enemy) 
		then
			target = enemy;
			break;
		end
	end
	return target;
end

function IsValidTarget(target)
	return target ~= nil and target:IsAlive() and target:CanBeSeen() and not target:IsInvulnerable();
end

function MeasureDesire(target)
	if target ~= nil then
		local CAllyToEnemy = CompareAllyToEnemy(target);
		local CEstDamageSelfToTarget = CompareEstDamage(target);
		local CHEalthSelfToTarget = CompareHealth(target);
		return ( 0.25 * CAllyToEnemy ) + (0.25 * CEstDamageSelfToTarget) + (0.25 * CHEalthSelfToTarget);
	end
	return BOT_MODE_DESIRE_NONE;
end

function CompareAllyToEnemy(target)
	
	local NearbyAlly = target:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	local NearbyEnemy = target:GetNearbyHeroes(nRange, false, BOT_MODE_NONE);
	local NearbyAllyCreep = target:GetNearbyLaneCreeps(nRange, true);
	local NearbyEnemyCreep = target:GetNearbyLaneCreeps(nRange, false);
	local NearbyAllyTower = target:GetNearbyTowers(nRange, true);
	local NearbyEnemyTower = target:GetNearbyTowers(nRange, false);
	
	if NearbyAlly ~= nil and NearbyEnemy ~= nil then
		local Cmp = #NearbyAlly / #NearbyEnemy;
		if Cmp > 1 then
			return 1.0;
		else
			return Cmp;
		end
	end
	return 0.0;
end

function CompareEstDamage(target)
	local BPower = bot:GetEstimatedDamageToTarget(true, target, 4.0, DAMAGE_TYPE_ALL);
	local EPower = target:GetEstimatedDamageToTarget(true, bot, 4.0, DAMAGE_TYPE_ALL);
	if BPower >= EPower then 
		return 1.0;
	else
		return BPower / EPower;
	end
end

function CompareHealth(target)
	local BHealth = bot:GetHealth()
	local EHealth = target:GetHealth()
	if BHealth >= EHealth then
		return 1.0
	else
		return BHealth / EHealth;
	end
end

MyModule.OnStart = OnStart;
MyModule.OnEnd = OnEnd;
MyModule.Think = Think;
MyModule.GetDesire = GetDesire;
return MyModule;