local bot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion() then return; end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutils = require(GetScriptDirectory() ..  "/MyUtility")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local abilities = mutils.InitiateAbilities(bot, {0,1,2,5,6,3,7});

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local function CanCastOnCreep(unit)
	return unit:CanBeSeen() and unit:IsMagicImmune() == false and unit:IsInvulnerable() == false; 
end

local function GetNumEnemyCreepsAroundTarget(target, bEnemy, nRadius)
	local locationAoE = bot:FindAoELocation( true, false, target:GetLocation(), 0, nRadius, 0, 0 );
	if ( locationAoE.count >= 3 ) then
		return 3;
	end
	return 0;
end

local function GetBestTree(source, target, nCastRange, radius)
   
	local bestTree=nil;
	local mindis=10000;

	local trees=source:GetNearbyTrees(nCastRange);
	
	local vStart = bot:GetLocation();
	local tgtLoc = target:GetLocation();
	for i=1, #trees do
		local vEnd = GetTreeLocation(trees[i]);
		local tResult = PointToLineDistance(vStart, vEnd, tgtLoc);
		local tgtTreeDist = GetUnitToLocationDistance(target, vEnd)
		if tResult ~= nil 
			and tResult.within == true  
			and tResult.distance <= radius
			and tgtTreeDist < mindis
			and tgtTreeDist < GetUnitToLocationDistance(bot, vEnd)
		then
			mindis = tgtTreeDist;
			bestTree = trees[i];
		end
	end
	
	return bestTree;

end

local function GetBestRetreatTree(npcBot, nCastRange)
	local trees=npcBot:GetNearbyTrees(nCastRange);
	
	local dest=utils.VectorTowards(npcBot:GetLocation(),utils.Fountain(GetTeam()),1000);
	
	local BestTree=nil;
	local maxdis=0;
	
	for _,tree in pairs(trees) do
		local loc=GetTreeLocation(tree);
		
		if (not utils.AreTreesBetween(loc,100)) and 
			GetUnitToLocationDistance(npcBot,loc)>maxdis and 
			GetUnitToLocationDistance(npcBot,loc)<nCastRange and 
			utils.GetDistance(loc,dest)<880 
		then
			maxdis=GetUnitToLocationDistance(npcBot,loc);
			BestTree=loc;
		end
	end
	
	if BestTree~=nil and maxdis>250 then
		return BestTree;
	end
	
	return nil;
end

local function GetUltLoc(npcBot, enemy, nManaCost, nCastRange, s)

	local v=enemy:GetVelocity();
	local sv=utils.GetDistance(Vector(0,0),v);
	if sv>800 then
		v=(v / sv) * enemy:GetCurrentMovementSpeed();
	end
	
	local x=npcBot:GetLocation();
	local y=enemy:GetLocation();
	
	local a=v.x*v.x + v.y*v.y - s*s;
	local b=-2*(v.x*(x.x-y.x) + v.y*(x.y-y.y));
	local c= (x.x-y.x)*(x.x-y.x) + (x.y-y.y)*(x.y-y.y);
	
	local t=math.max((-b+math.sqrt(b*b-4*a*c))/(2*a) , (-b-math.sqrt(b*b-4*a*c))/(2*a));
	
	local dest = (t+0.35)*v + y;

	if GetUnitToLocationDistance(npcBot,dest)>nCastRange or npcBot:GetMana()<100+nManaCost then
		return nil;
	end
	
	if enemy:GetMovementDirectionStability()<0.4 or ((not utils.IsFacingLocation(enemy,utils.Fountain(GetOpposingTeam()),60)) ) then
		dest=utils.VectorTowards(y,utils.Fountain(GetOpposingTeam()),180);
	end

	if mutils.IsDisabled(true, enemy) then
		dest=enemy:GetLocation();
	end
	
	return dest;
	
end

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt('whirling_radius');
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
		or ( bot:GetActiveMode() == BOT_MODE_LANING and mutils.CanSpamSpell(bot, manaCost) )
	then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nRadius, true);
		if #creeps >= 3 then
			return BOT_ACTION_DESIRE_MODERATE;
		end	
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nRadius)	
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

local function ConsiderW()
	if  mutils.CanBeCast(abilities[2]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nRadius 	 = abilities[2]:GetSpecialValueInt( "chain_radius" );
	local manaCost   = abilities[2]:GetManaCost();
	local nSpeed	 = abilities[2]:GetSpecialValueInt( "speed" );
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nDamage	 = abilities[2]:GetSpecialValueInt("damage");

	if mutils.IsStuck(bot)
	then
		local BRTree = GetBestRetreatTree(bot, nCastRange);
		if BRTree ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, GetTreeLocation(BRTree);
		end
	end
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) and bot:DistanceFromFountain() > 1000 
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			local BRTree = GetBestRetreatTree(bot, nCastRange);
			if BRTree ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, GetTreeLocation(BRTree);
			end
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nCastRange+nRadius, true);
		for i=1, #creeps do
			if creeps[i] ~= nil 
				and bot:IsFacingLocation(creeps[i]:GetLocation(),10) == true
				and CanCastOnCreep(creeps[i]) == true
			then	
				local n_creeps = GetNumEnemyCreepsAroundTarget(creeps[i], false, nRadius)
				if n_creeps >= 3 then
					return BOT_ACTION_DESIRE_MODERATE;
				end	
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nCastRange)
			and utils.AreTreesBetween( target:GetLocation(),nRadius ) == false
		then
			local BTree = GetBestTree(bot, target, nCastRange, nRadius);
			if BTree ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, GetTreeLocation(BTree);
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderE()
	if  mutils.CanBeCast(abilities[3]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[4]:GetCastPoint();
	local nRadius		= abilities[4]:GetSpecialValueFloat( "radius" );
	local nSpeed 		= abilities[4]:GetSpecialValueFloat( "speed" );
	local nCastRange 	= mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nManaCost 	= abilities[4]:GetManaCost( );
	local nDamage 		= 2*abilities[4]:GetSpecialValueInt("pass_damage");
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange-150) 
		then
			local Loc = GetUltLoc(bot, target, nManaCost, nCastRange, nSpeed)
			if Loc ~= nil then
				local eta = GetUnitToLocationDistance(bot, Loc) / nSpeed;
				return BOT_ACTION_DESIRE_MODERATE, Loc, eta;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire		  	 		= ConsiderQ();
	castWDesire, wTarget 		= ConsiderW();
	castEDesire			 		= ConsiderE();
	castRDesire, rTarget, eta	= ConsiderR();
	
	if castQDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbility(abilities[1]);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbilityOnLocation(abilities[2], wTarget);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	
	if castRDesire > 0 then
		bot:Action_ClearActions(false);	
		bot:Action_UseAbilityOnLocation(abilities[4], rTarget);		
		return
	end
	
end