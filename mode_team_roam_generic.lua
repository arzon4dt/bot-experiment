local mutil = require(GetScriptDirectory() ..  "/MyUtility")
local items = require(GetScriptDirectory() .. "/ItemUtility" )
local bot = GetBot();
local cAbility = nil;
local camps = {};
local chenCreeps = {};
local castTime = 0;
local distance = 1000;
local targetShrine = nil;
local alreadyFoundCreep = false;
local pLane;
local targetTree = nil;
local targetLoc = nil;
local treeThrowTarget = nil;

if bot:GetUnitName() == "npc_dota_hero_earthshaker" 
	--or bot:GetUnitName() == "npc_dota_hero_abaddon" 
	--or bot:GetUnitName() == "npc_dota_hero_abyssal_underlord" 
then
	bot.data = {
		['enemies']  = {};
		['allies']   = {};
		['e_creeps'] = {};
		['a_creeps'] = {};
	}
end

function GetProperLane(pId)
	local lane = -1;
	local idx = -1;
	
	for i,id in pairs(GetTeamPlayers(GetTeam())) do	
		if id == pId then
			idx = i;
			break;
		end
	end
	
	if idx == 1 then
		lane = LANE_MID ;
	elseif ( idx == 2 or idx == 3 ) then
		lane = LANE_TOP;
	elseif ( idx == 4 or idx == 5 ) then
		lane = LANE_BOT;	
	end
	
	return lane;
	
end
local droppedCheck = -90;
local cheeseCheck = -90;
local refShardCheck = -90;
local pickedItem = nil;
local lastBootSlotCheck = -90;

local function CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1
end

function GetDesire()
	
	--[[local units = GetUnitList(UNIT_LIST_ALLIED_OTHER)
	for _,unit in pairs(units) do
		print(unit:GetUnitName()..":"..tostring(unit:GetBaseMovementSpeed())..":"..tostring(unit:GetBaseDamage())..":"..tostring(unit:GetAttackPoint()))
	end]]--
	
	if bot:GetUnitName() == "npc_dota_hero_earthshaker" 
		--or bot:GetUnitName() == "npc_dota_hero_abaddon" 
		--or bot:GetUnitName() == "npc_dota_hero_abyssal_underlord" 
	then
		bot.data = {
			['enemies']  = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			['allies']   = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
			['e_creeps'] = bot:GetNearbyLaneCreeps(1600, true);
			['a_creeps'] = bot:GetNearbyLaneCreeps(1600, false);
		}
	end

	--[[local dropped = GetDroppedItemList();
	for _,drop in pairs(dropped) do
		for key,value in pairs(drop) do
			print(tostring(key)..":"..tostring(value))
		end
	end]]--
	
	if DotaTime() > 10*60 then
		if DotaTime() >= droppedCheck + 1.0 then
			local mostCDHero = mutil.GetMostUltimateCDUnit();
			if mostCDHero ~= nil and mostCDHero:IsBot() and bot == mostCDHero and items.GetEmptyInventoryAmount(bot) > 0 then
				local item = nil;
				local dropped = GetDroppedItemList();
				for _,drop in pairs(dropped) do
					if drop.item:GetName() == "item_refresher_shard" then
						item = drop;
						break;
					end
				end
				if item ~= nil then
					pickedItem = item;
					return BOT_MODE_DESIRE_VERYHIGH;
				end
			end
			droppedCheck = DotaTime();
		end	
		if 	DotaTime() >= cheeseCheck + 2.0 and bot:GetActiveMode() ~= BOT_MODE_WARD then
			local cSlot = bot:FindItemSlot('item_cheese');
			if bot:GetItemSlotType(cSlot) == ITEM_SLOT_TYPE_BACKPACK then
				local lessValItem = items.GetMainInvLessValItemSlot(bot);
				if lessValItem ~= -1 then
					bot:ActionImmediate_SwapItems( cSlot, lessValItem );
				end
			end
			cheeseCheck = DotaTime();
		end
		if 	DotaTime() >= refShardCheck + 2.0 and bot:GetActiveMode() ~= BOT_MODE_WARD then
			local rSlot = bot:FindItemSlot('item_refresher_shard');
			if bot:GetItemSlotType(rSlot) == ITEM_SLOT_TYPE_BACKPACK then
				local lessValItem = items.GetMainInvLessValItemSlot(bot);
				if lessValItem ~= -1 then
					bot:ActionImmediate_SwapItems( rSlot, lessValItem );
				end
			end
			refShardCheck = DotaTime();
		end
	end
	
	if bot:GetActiveMode() ~= BOT_MODE_WARD and DotaTime() > lastBootSlotCheck + 1.0 then
		local itemSlot = -1;
		for i=1,#items['earlyBoots'] do
			local slot = bot:FindItemSlot(items['earlyBoots'][i]);
			if slot >= 0 then
				itemSlot = slot;
				break;
			end
		end	
		if itemSlot == -1 then
			itemSlot = bot:FindItemSlot("item_boots")
		end
		if itemSlot ~= -1 and bot:GetItemSlotType(itemSlot) == ITEM_SLOT_TYPE_BACKPACK then
			local lessValItem = items.GetMainInvLessValItemSlot(bot);
			if lessValItem ~= -1 and bot:GetItemInSlot(lessValItem):GetName() ~= "item_tome_of_knowledge"	
				and GetItemCost(bot:GetItemInSlot(lessValItem):GetName()) < GetItemCost(bot:GetItemInSlot(itemSlot):GetName()) 
			then
				bot:ActionImmediate_SwapItems( itemSlot, lessValItem );
			end
		end
		local tom = bot:FindItemSlot('item_tome_of_knowledge');
		if DotaTime() > 10*60 and tom ~= -1 and bot:GetItemSlotType(tom) == ITEM_SLOT_TYPE_BACKPACK then
			local lessValItem = items.GetMainInvLessValItemSlot(bot);
			if lessValItem ~= -1 then
				bot:ActionImmediate_SwapItems( tom, lessValItem );
			end
		end
		lastBootSlotCheck = DotaTime();
	end
	
	if GetGameMode() == GAMEMODE_1V1MID and bot:GetAssignedLane() ~= LANE_MID then
		return BOT_MODE_DESIRE_ABSOLUTE;
	end
	
	if ( bot:GetUnitName() == "npc_dota_hero_elder_titan" or  bot:GetUnitName() == 'npc_dota_hero_wisp' ) and DotaTime() < 15 then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies == 0 then
			pLane = GetProperLane(bot:GetPlayerID())
			return BOT_MODE_DESIRE_MODERATE;
		end
	end
	
	if not bot:IsAlive() or bot:GetCurrentActionType() == BOT_ACTION_TYPE_DELAY then
		targetShrine = nil;
		return BOT_MODE_DESIRE_NONE;
	end
	
	if bot:GetUnitName() == "npc_dota_hero_centaur" then
		for i,id in pairs(GetTeamPlayers(GetTeam())) do
			local member = GetTeamMember(i);
			if member ~= nil and member:GetStunDuration(true) > 0 then
				--print(member:GetUnitName()..":"..tostring(member:GetStunDuration(true)));
			end
		end
	end
	
	local manaP = bot:GetMana() / bot:GetMaxMana();
	local healthP = bot:GetHealth() / bot:GetMaxHealth();
	
	if healthP < 0.35 or ( bot:HasModifier("modifier_filler_heal") and ( manaP < 0.5 or healthP < 0.75 ) ) then
		targetShrine = GetClosestShrine()
		if targetShrine ~= nil then
			local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			if bot:HasModifier("modifier_filler_heal") and #enemies > 0 then
				return BOT_MODE_DESIRE_NONE;
			else
				return BOT_MODE_DESIRE_ABSOLUTE;
			end
		end		
	end
	
	if bot:GetUnitName() == "npc_dota_hero_shadow_shaman" then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "shadow_shaman_shackles" ) end;
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end
	elseif bot:GetUnitName() == "npc_dota_hero_keeper_of_the_light" then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "keeper_of_the_light_illuminate" ) end;
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end
	elseif bot:GetUnitName() == "npc_dota_hero_pugna" then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "pugna_life_drain" ) end;
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end	
	elseif bot:GetUnitName() == "npc_dota_hero_elder_titan" then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "elder_titan_echo_stomp" ) end;
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end		
	elseif bot:GetUnitName() == "npc_dota_hero_puck" then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "puck_phase_shift" ) end;
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end		
	elseif bot:GetUnitName() == "npc_dota_hero_windrunner" then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "windrunner_powershot" ) end;
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end	
	elseif bot:GetUnitName() == "npc_dota_hero_witch_doctor" then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "witch_doctor_death_ward" ) end;
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end	
	elseif bot:GetUnitName() == "npc_dota_hero_tinker" then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "tinker_rearm" ) end;
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end
	elseif bot:GetUnitName() == "npc_dota_hero_spirit_breaker" then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "spirit_breaker_charge_of_darkness" ) end;
		if cAbility:IsInAbilityPhase() or bot:HasModifier("modifier_spirit_breaker_charge_of_darkness") then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end	
	elseif bot:GetUnitName() == "npc_dota_hero_enigma" then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "enigma_black_hole" ) end;
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end		
	elseif bot:GetUnitName() == "npc_dota_hero_batrider" and bot:HasModifier('modifier_batrider_flaming_lasso_self') then
		return BOT_MODE_DESIRE_ABSOLUTE;
	elseif bot:GetUnitName() == "npc_dota_hero_chen" then
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		if cAbility == nil then cAbility = bot:GetAbilityByName('chen_holy_persuasion') end;
		local maxUnit = cAbility:GetSpecialValueInt('max_units');
		if DotaTime() > 60 and #enemies == 0 and #chenCreeps < maxUnit and cAbility:IsFullyCastable() then
			if #camps == 0 then camps = GetNeutralSpawners(); end
			return BOT_MODE_DESIRE_MODERATE;	
		end
		if DotaTime() - castTime > 2 then
			UpdateDominatedCreeps();
		end
	elseif bot:GetUnitName() == "npc_dota_hero_enchantress" then
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		local creeps = bot:GetNearbyLaneCreeps(1600, true);
		if cAbility == nil then cAbility = bot:GetAbilityByName('enchantress_enchant') end;
		if DotaTime() > 60 and cAbility:IsFullyCastable() and #enemies == 0 and #creeps == 0 then
			if #camps == 0 then camps = GetNeutralSpawners(); end
			return BOT_MODE_DESIRE_MODERATE;	
		end
	elseif bot:GetUnitName() == "npc_dota_hero_doom_bringer" and not bot:HasModifier('modifier_doom_bringer_devour') then
		local lCreeps = bot:GetNearbyLaneCreeps(1300, true);
		if cAbility == nil then cAbility = bot:GetAbilityByName('doom_bringer_devour') end;
		if DotaTime() > 30 and #lCreeps == 0 and cAbility:IsFullyCastable() then
			if #camps == 0 then camps = GetNeutralSpawners(); end
			return BOT_MODE_DESIRE_MODERATE+0.05;	
		end	
	elseif bot:GetUnitName() == "npc_dota_hero_tiny" then
		if bot:HasModifier("modifier_tiny_craggy_exterior") == false then
			if cAbility == nil or cAbility:GetName() ~= "tiny_craggy_exterior" then cAbility = bot:GetAbilityByName('tiny_craggy_exterior') end;
			if cAbility:IsFullyCastable() and bot:GetHealth() / bot:GetMaxHealth() > 0.15 and bot:DistanceFromFountain() > 1000 then
				local trees = bot:GetNearbyTrees(500);
				if #trees > 0 and ( IsLocationVisible(GetTreeLocation(trees[1])) or IsLocationPassable(GetTreeLocation(trees[1])) ) then
					targetTree = trees[1];
					treeThrowTarget = nil;
					return BOT_MODE_DESIRE_ABSOLUTE;
				end
			end	
		elseif bot:HasModifier("modifier_tiny_craggy_exterior") == true 
		       and bot:GetModifierStackCount( bot:GetModifierByName("modifier_tiny_craggy_exterior") ) == 1 
		then
			local target = bot:GetTarget(); 
			if mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) 
			   and mutil.IsInRange(target, bot, 500) == false and mutil.IsInRange(target, bot, 1000) == true
			then   
				treeThrowTarget = target;
				cAbility = bot:GetAbilityByName('tiny_toss_tree');
				return BOT_MODE_DESIRE_ABSOLUTE;
			end		
		end	
	elseif bot:GetUnitName() == "npc_dota_hero_viper" then
		if cAbility == nil then cAbility = bot:GetAbilityByName('viper_nethertoxin') end;
		if cAbility:IsFullyCastable() then
			local nRadius = cAbility:GetSpecialValueInt("radius");
			local nCastRange = cAbility:GetCastRange()+200;
			local npcTarget = bot:GetTarget()
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, bot, nCastRange)
			then
				targetLoc = npcTarget:GetLocation();
				return BOT_MODE_DESIRE_ABSOLUTE;
			end
		end		
	elseif bot:GetUnitName() == "npc_dota_hero_skeleton_king" and bot:HasModifier("modifier_skeleton_king_mortal_strike") then
		if cAbility == nil then cAbility = bot:GetAbilityByName('skeleton_king_mortal_strike') end
		if cAbility:IsFullyCastable() then
			local stack = 0;
			local modIdx = bot:GetModifierByName("modifier_skeleton_king_mortal_strike");
			if modIdx > -1 then
				stack = bot:GetModifierStackCount(modIdx);
			end
			local nStack = cAbility:GetSpecialValueInt("max_skeleton_charges");
			if ( stack >= nStack ) 
			then
				local npcTarget = bot:GetTarget()
				if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, bot, 320)
				then
					return BOT_MODE_DESIRE_ABSOLUTE;
				end
			end
		end			
	end
	
	if alreadyFoundCreep then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies == 0 then
			return BOT_MODE_DESIRE_HIGH;
		else
			alreadyFoundCreep = false;
		end
	end
	
	return 0.0;
	
end

function OnStart()
	
end

function OnEnd()
	camps = {};
	targetShrine = nil;
	targetTree = nil;
	targetLoc = nil;
	pickedItem = nil;
end

function Think()

	if GetGameMode() == GAMEMODE_1V1MID and bot:GetAssignedLane() ~= LANE_MID then
		bot:Action_ClearActions(true);
		return; 
	end

	if pickedItem ~= nil then
		print(bot:GetUnitName().." picking up item");
		if GetUnitToLocationDistance(bot, pickedItem.location) > 500 then
			bot:Action_MoveToLocation(pickedItem.location);
			return
		else
			bot:Action_PickUpItem(pickedItem.item);
			return
		end
	end
	
	if ( bot:GetUnitName() == 'npc_dota_hero_elder_titan' or  bot:GetUnitName() == 'npc_dota_hero_wisp' ) and DotaTime() < 15 then
		local loc  = GetLocationAlongLane(pLane, GetLaneFrontAmount( GetTeam(), pLane, false ));
		local dist = GetUnitToLocationDistance(bot, loc);
		if dist > 400 then
			bot:Action_MoveToLocation(loc);
			return
		else
			bot:Action_ClearActions(true);
			return
		end
	end

	if alreadyFoundCreep then
		local neutrals = bot:GetNearbyNeutralCreeps(800);
		if #neutrals == 0 then
			alreadyFoundCreep = false;	
		else
			for	_,neutral in pairs(neutrals) do
				if neutral ~= nil and neutral:IsAlive() then
					bot:Action_AttackUnit(neutral, true);
					return;
				end
			end
		end
	end

	if targetShrine ~= nil then
		if bot:IsChanneling() or bot:IsUsingAbility() or bot:IsCastingAbility() then
			return;
		elseif GetUnitToUnitDistance(bot, targetShrine) > 500 or bot:HasModifier("modifier_filler_heal") then
			bot:Action_MoveToLocation(targetShrine:GetLocation());
			return;
		else
			bot:Action_UseShrine(targetShrine)
			return
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_shadow_shaman" 
		or  bot:GetUnitName() == "npc_dota_hero_keeper_of_the_light" 
		or  bot:GetUnitName() == "npc_dota_hero_pugna" 
		or  bot:GetUnitName() == "npc_dota_hero_elder_titan" 
		or  bot:GetUnitName() == "npc_dota_hero_puck" 
		or  bot:GetUnitName() == "npc_dota_hero_windrunner" 
		or  bot:GetUnitName() == "npc_dota_hero_witch_doctor" 
		or  bot:GetUnitName() == "npc_dota_hero_tinker" 
		or  bot:GetUnitName() == "npc_dota_hero_enigma" 
	then
		return;	
	elseif bot:GetUnitName() == "npc_dota_hero_spirit_breaker" then
		local target = bot.chargeTarget;
		if target ~= nil and not target:IsNull() and target:IsAlive() and target:CanBeSeen() and GetUnitToLocationDistance(target, mutil.GetEnemyFountain()) < 1200
		then
			bot:ActionImmediate_Chat("Target way too close to their base", false);
			bot:Action_MoveToLocation(bot:GetLocation() + RandomVector(200));
			return;
		elseif target ~= nil and not target:IsNull() and target:IsAlive() then
			local Ally = target:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			local Enemy = target:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
			if Ally ~= nil and Enemy ~= nil and ( #Ally + 1 < #Enemy  ) then
				bot:ActionImmediate_Chat("To many enemies", false);
				bot:Action_MoveToLocation(bot:GetLocation() + RandomVector(200));
				return;
			else
				return;
			end	
		else	
			return;
		end
	elseif bot:GetUnitName() == "npc_dota_hero_batrider" then
		bot:Action_MoveToLocation(mutil.GetTeamFountain());
		return
	elseif bot:GetUnitName() == "npc_dota_hero_chen" then
		if bot:IsUsingAbility() or bot:IsCastingAbility() or bot:IsChanneling() or cAbility:IsInAbilityPhase() then return end
		local closestC, i, dist = GetClosestCamp();
		if closestC ~= nil and dist > 300 then 
			bot:Action_MoveToLocation(closestC.location);
			return
		elseif  closestC ~= nil and dist <= 300 then
			local target = GetDominatedTarget();
			if target == nil then
				table.remove(camps, i);
				return
			else
				alreadyFoundCreep = true;
				AddedToDominated(target);
				castTime = DotaTime();
				bot:Action_UseAbilityOnEntity(cAbility, target);
				return
			end
		end
	elseif bot:GetUnitName() == "npc_dota_hero_enchantress" then
		if bot:IsUsingAbility() or bot:IsCastingAbility() or bot:IsChanneling() or cAbility:IsInAbilityPhase() then return end
		local closestC, i, dist = GetClosestCamp();
		if closestC ~= nil and dist > 300 then 
			bot:Action_MoveToLocation(closestC.location);
			return
		elseif  closestC ~= nil and dist <= 300 then
			local target = GetDominatedTarget();
			if target == nil then
				table.remove(camps, i);
				return
			else
				alreadyFoundCreep = true;
				bot:Action_UseAbilityOnEntity(cAbility, target);
				return
			end
		end	
	elseif bot:GetUnitName() == "npc_dota_hero_doom_bringer" then
		if bot:IsUsingAbility() or bot:IsCastingAbility() or bot:IsChanneling() or cAbility:IsInAbilityPhase() then return end
		local closestC, i, dist = GetClosestCamp();
		if dist > 300 then 
			bot:Action_MoveToLocation(closestC.location);
			return
		elseif dist <= 300 then
			local target = GetDominatedTarget();
			if target ~= nil then
				bot:Action_UseAbilityOnEntity(cAbility, target);
				return
			else
				table.remove(camps, i);
				return
			end
		end	
	elseif bot:GetUnitName() == "npc_dota_hero_tiny" then
		if treeThrowTarget ~= nil then
			bot:Action_UseAbilityOnEntity(cAbility, treeThrowTarget);
			return;
		else
			bot:Action_UseAbilityOnTree(cAbility, targetTree);
			return;
		end
	elseif bot:GetUnitName() == "npc_dota_hero_viper" then
		bot:Action_UseAbilityOnLocation(cAbility, targetLoc);
		return;	
	elseif bot:GetUnitName() == "npc_dota_hero_skeleton_king" then
		bot:Action_UseAbility(cAbility);
		return;		
	end
end

function GetClosestCamp()
	local closest = nil;
	local cDist = 100000;
	local idx = -1;
	for i,c in pairs(camps) do
		local dist = GetUnitToLocationDistance(bot, c.location);
		if c.type ~= "ancient" and dist < cDist then
			closest = c;
			cDist = dist;
			idx = i;
		end
	end	
	return closest, idx, cDist;
end

function GetDominatedTarget()
	local target = nil;
	local neutrals = bot:GetNearbyNeutralCreeps(500);
	for _,u in pairs(neutrals) do
		if mutil.CanBeDominatedCreeps(u:GetUnitName()) then
			target = u;
			break;
		end
	end	
	return target;
end

function AddedToDominated(unit)
	if #chenCreeps == 0 then
		table.insert(chenCreeps, unit);
	else
		for _,u in pairs(chenCreeps) do
			if tostring(unit) ~= tostring(u) then
				table.insert(chenCreeps, unit);
			end
		end
	end
end

function UpdateDominatedCreeps()
	local removedkey = -1;
	for i,u in pairs(chenCreeps) do
		--print(u:GetUnitName()..tostring(u:IsAlive())..tostring(u:GetTeam())..tostring(bot:GetTeam()).. tostring(u:HasModifier('modifier_chen_holy_persuasion'))..tostring(u:IsNull())..tostring(u==nil))
		if u:IsNull() or u == nil or not u:IsAlive() or not u:HasModifier('modifier_chen_holy_persuasion') or u:GetTeam() ~= bot:GetTeam() then
			removedkey = i;
			break;
		end
	end
	if removedkey ~= -1 then
		table.remove(chenCreeps, removedkey);
	end
end

function GetClosestShrine()
	local closest = nil;
	local minDist = 100000;
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i=3,4 do	
		local shrine = GetShrine(GetTeam(), i);
		if shrine ~= nil and shrine:IsAlive() and ( GetShrineCooldown(shrine) == 0 or IsShrineHealing(shrine) ) then 
			local dist =  GetUnitToUnitDistance(bot, shrine);
			if dist < distance and dist < minDist then
				closest = shrine;
				minDist = dist;
			end
		end
	end
	return closest;
end 