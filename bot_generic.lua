
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/MyUtility")

local TeamAncient = GetAncient(GetTeam());
local TeamAncientLoc = TeamAncient:GetLocation();
local EnemyAncient = GetAncient(GetOpposingTeam());
local EnemyAncientLoc = EnemyAncient:GetLocation();
local centre = Vector(0, 0, 0);

local bot = GetBot()
--print(tostring(EnemyBaseLoc));
if bot:GetUnitName() == 'npc_dota_hero_phantom_lancer' 
	or bot:GetUnitName() == 'npc_dota_hero_naga_siren' 
	or bot:GetUnitName() == 'npc_dota_hero_spectre'
	or bot:GetUnitName() == 'npc_dota_hero_chaos_knight'
	or bot:GetUnitName() == 'npc_dota_hero_terrorblade'
	or bot:GetUnitName() == 'npc_dota_hero_dark_seer'
	or bot:GetUnitName() == 'npc_dota_hero_arc_warden'
then
	return;
end	

local attackDesire = 0;
local moveDesire = 0;
local retreatDesire = 0;

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;

function IsFrozeSigil(unit_name)
	return unit_name == "npc_dota_tusk_frozen_sigil1" 
		or unit_name == "npc_dota_tusk_frozen_sigil2" 
		or unit_name == "npc_dota_tusk_frozen_sigil3" 
		or unit_name == "npc_dota_tusk_frozen_sigil4"; 
end

------------BEASTMASTER'S HAWK
function IsHawk(unit_name)
	return unit_name == "npc_dota_scout_hawk"
		or unit_name == "npc_dota_greater_hawk"
		or unit_name == "npc_dota_beastmaster_hawk"
		or unit_name == "npc_dota_beastmaster_hawk_1"
		or unit_name == "npc_dota_beastmaster_hawk_2"
		or unit_name == "npc_dota_beastmaster_hawk_3"
		or unit_name == "npc_dota_beastmaster_hawk_4";
end

function HawkThink(bot, hMinionUnit)
	return
end
 
function IsTornado(unit_name)
	return unit_name == "npc_dota_enraged_wildkin_tornado";
end 

function IsHealingWard(unit_name)
	return unit_name == "npc_dota_juggernaut_healing_ward";
end

function IsBear(unit_name)
	return unit_name == "npc_dota_lone_druid_bear1"
		or unit_name == "npc_dota_lone_druid_bear2"
		or unit_name == "npc_dota_lone_druid_bear3"
		or unit_name == "npc_dota_lone_druid_bear4";
end

function IsFamiliar(unit_name)
	return unit_name == "npc_dota_visage_familiar1"
		or unit_name == "npc_dota_visage_familiar2"
		or unit_name == "npc_dota_visage_familiar3";
end

function IsMinionWithNoSkill(unit_name)
	return unit_name == "npc_dota_lesser_eidolon"
		or unit_name == "npc_dota_eidolon"
		or unit_name == "npc_dota_greater_eidolon"
		or unit_name == "npc_dota_dire_eidolon"
		or unit_name == "npc_dota_furion_treant"
		or unit_name == "npc_dota_furion_treant_1"
		or unit_name == "npc_dota_furion_treant_2"
		or unit_name == "npc_dota_furion_treant_3"
		or unit_name == "npc_dota_furion_treant_4"
		or unit_name == "npc_dota_furion_treant_large"
		or unit_name == "npc_dota_invoker_forged_spirit"
		or unit_name == "npc_dota_broodmother_spiderling"
		or unit_name == "npc_dota_broodmother_spiderite"
		or unit_name == "npc_dota_wraith_king_skeleton_warrior"
		or unit_name == "npc_dota_warlock_golem_1"
		or unit_name == "npc_dota_warlock_golem_2"
		or unit_name == "npc_dota_warlock_golem_3"
		or unit_name == "npc_dota_warlock_golem_scepter_1"
		or unit_name == "npc_dota_warlock_golem_scepter_2"
		or unit_name == "npc_dota_warlock_golem_scepter_3"
		or unit_name == "npc_dota_beastmaster_boar"
		or unit_name == "npc_dota_beastmaster_greater_boar"
		or unit_name == "npc_dota_beastmaster_boar_1"
		or unit_name == "npc_dota_beastmaster_boar_2"
		or unit_name == "npc_dota_beastmaster_boar_3"
		or unit_name == "npc_dota_beastmaster_boar_4"
		or unit_name == "npc_dota_lycan_wolf1"
		or unit_name == "npc_dota_lycan_wolf2"
		or unit_name == "npc_dota_lycan_wolf3"
		or unit_name == "npc_dota_lycan_wolf4"
		or unit_name == "npc_dota_neutral_kobold"
		or unit_name == "npc_dota_neutral_kobold_tunneler"
		or unit_name == "npc_dota_neutral_kobold_taskmaster"
		or unit_name == "npc_dota_neutral_centaur_outrunner"
		or unit_name == "npc_dota_neutral_fel_beast"
		or unit_name == "npc_dota_neutral_polar_furbolg_champion"
		or unit_name == "npc_dota_neutral_ogre_mauler"
		or unit_name == "npc_dota_neutral_giant_wolf"
		or unit_name == "npc_dota_neutral_alpha_wolf"
		or unit_name == "npc_dota_neutral_wildkin"
		or unit_name == "npc_dota_neutral_jungle_stalker"
		or unit_name == "npc_dota_neutral_elder_jungle_stalker"
		or unit_name == "npc_dota_neutral_prowler_acolyte"
		or unit_name == "npc_dota_neutral_rock_golem"
		or unit_name == "npc_dota_neutral_granite_golem"
		or unit_name == "npc_dota_neutral_small_thunder_lizard"
		or unit_name == "npc_dota_neutral_gnoll_assassin"
		or unit_name == "npc_dota_neutral_ghost"
		or unit_name == "npc_dota_wraith_ghost"
		or unit_name == "npc_dota_neutral_dark_troll"
		or unit_name == "npc_dota_neutral_forest_troll_berserker"
		or unit_name == "npc_dota_neutral_harpy_scout"
		or unit_name == "npc_dota_neutral_black_drake"
		or unit_name == "npc_dota_dark_troll_warlord_skeleton_warrior"
		or unit_name == "npc_dota_necronomicon_warrior_1"
		or unit_name == "npc_dota_necronomicon_warrior_2"
		or unit_name == "npc_dota_necronomicon_warrior_3";
end

local remnant = {
	"npc_dota_stormspirit_remnant",
	"npc_dota_ember_spirit_remnant",
	"npc_dota_earth_spirit_stone",
	"npc_dota_aether_remnant"
}

local trap = {
	"npc_dota_templar_assassin_psionic_trap",
	"npc_dota_techies_remote_mine",
	"npc_dota_techies_land_mine",
	"npc_dota_techies_stasis_trap"
}

local independent = {
	"npc_dota_brewmaster_earth_1",
	"npc_dota_brewmaster_earth_2",
	"npc_dota_brewmaster_earth_3",
	"npc_dota_brewmaster_storm_1",
	"npc_dota_brewmaster_storm_2",
	"npc_dota_brewmaster_storm_3",
	"npc_dota_brewmaster_fire_1",
	"npc_dota_brewmaster_fire_2",
	"npc_dota_brewmaster_fire_3"
}

function IsTrap(unit_name)
	return unit_name == "npc_dota_templar_assassin_psionic_trap"
		or unit_name == "npc_dota_techies_remote_mine"
		or unit_name == "npc_dota_techies_land_mine"
		or unit_name == "npc_dota_techies_stasis_trap"
end

function IsRemnant(unit_name)
	return unit_name == "npc_dota_stormspirit_remnant"
		or unit_name == "npc_dota_ember_spirit_remnant"
		or unit_name == "npc_dota_earth_spirit_stone"
		or unit_name == "npc_dota_aether_remnant"
end

function IsBrewLink(unit_name)
	return unit_name == "npc_dota_brewmaster_earth_1"
		or unit_name ==  "npc_dota_brewmaster_earth_2"
		or unit_name ==  "npc_dota_brewmaster_earth_3"
		or unit_name ==  "npc_dota_brewmaster_storm_1"
		or unit_name ==  "npc_dota_brewmaster_storm_2"
		or unit_name ==  "npc_dota_brewmaster_storm_3"
		or unit_name ==  "npc_dota_brewmaster_fire_1"
		or unit_name ==  "npc_dota_brewmaster_fire_2"
		or unit_name ==  "npc_dota_brewmaster_fire_3"
end

function IsValidUnit(unit)
	return unit ~= nil 
	   and unit:IsNull() == false 
	   and unit:IsAlive();
end

function IsValidTarget(target)
	return target ~= nil 
	   and target:IsNull() == false 
	   and target:CanBeSeen() 
	   and target:IsInvulnerable() == false 
	   and target:IsAlive();
end

function IsInRange(unit, target, range)
	return GetUnitToUnitDistance(unit, target) <= range;
end

function CanCastOnTarget(target, ability)
	if CheckFlag(ability:GetTargetFlags(), ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) then
		return target:IsHero() and target:IsIllusion() == false;
	else
		return target:IsHero() and target:IsIllusion() == false and target:IsMagicImmune() == false;
	end 
end

local globRadius = 1600; 

function GetWeakest(units)
	local target = nil;
	local minHP = 10000;
	if #units > 0 then
		for i=1, #units do
			if IsValidTarget(units[i]) then
				local hp = units[i]:GetHealth();
				if hp <= minHP then
					target = units[i];
					minHP  = hp;
				end
			end
		end
	end
	return target;
end

function GetWeakestHero(radius, hMinionUnit)
	local enemies = hMinionUnit:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
	return GetWeakest(enemies);
end

function GetWeakestCreep(radius, hMinionUnit)
	local creeps = hMinionUnit:GetNearbyLaneCreeps(radius, true);
	return GetWeakest(creeps);
end

function GetWeakestTower(radius, hMinionUnit)
	local towers = hMinionUnit:GetNearbyTowers(radius, true);
	return GetWeakest(towers);
end

function GetWeakestBarracks(radius, hMinionUnit)
	local barracks = hMinionUnit:GetNearbyBarracks(radius, true);
	return GetWeakest(barracks);
end

function GetIllusionAttackTarget(bot, hMinionUnit)
	local target = bot:GetAttackTarget();
	if target == nil then
		target = bot:GetTarget();
	end
	if target == nil or bot:GetActiveMode() == BOT_MODE_RETREAT then
		target = GetWeakestHero(globRadius, hMinionUnit);
		if target == nil then target = GetWeakestCreep(globRadius, hMinionUnit); end
		if target == nil then target = GetWeakestTower(globRadius, hMinionUnit); end
		if target == nil then target = GetWeakestBarracks(globRadius, hMinionUnit); end
	end
	return target;	
end


function IsBusy(unit)
	return unit:IsUsingAbility() or unit:IsCastingAbility() or unit:IsChanneling();
end

function CantMove(unit)
	return unit:IsStunned() or unit:IsRooted() or unit:IsNightmared() or unit:IsInvulnerable();	
end

function CantAttack(unit)
	return unit:IsStunned() or unit:IsRooted() or unit:IsNightmared() or unit:IsDisarmed() or unit:IsInvulnerable(); 	
end

------------ILLUSION ACT
function ConsiderIllusionAttack(bot, hMinionUnit)
	if CantAttack(hMinionUnit) then return BOT_MODE_DESIRE_NONE, nil; end
	local target = GetIllusionAttackTarget(bot, hMinionUnit);
	if target ~= nil then
		return BOT_MODE_DESIRE_HIGH, target; 
	end
	return BOT_MODE_DESIRE_NONE, nil;
end

function ConsiderIllusionMove(bot, hMinionUnit)
	if CantMove(hMinionUnit) then return BOT_MODE_DESIRE_NONE, nil; end
	if bot:IsAlive() == true and bot:GetActiveMode() ~= BOT_MODE_RETREAT then
		return BOT_MODE_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(TeamAncientLoc, 300); 
	elseif bot:IsAlive() == false then
		local target = GetIllusionAttackTarget(bot, hMinionUnit);
		if target == nil then
			return BOT_MODE_DESIRE_HIGH, EnemyAncientLoc; 
		end
	end
	return BOT_MODE_DESIRE_NONE, nil;
end

function IllusionThink(bot,hMinionUnit)
	hMinionUnit.attackDesire, hMinionUnit.target = ConsiderIllusionAttack(bot, hMinionUnit);
	hMinionUnit.moveDesire, hMinionUnit.loc      = ConsiderIllusionMove(bot, hMinionUnit);
	if hMinionUnit.attackDesire > 0 then
		hMinionUnit:Action_AttackUnit(hMinionUnit.target, true);
		return
	end
	if hMinionUnit.moveDesire > 0 then
		hMinionUnit:Action_MoveToLocation(hMinionUnit.loc);
		return
	end
end

function CanBeAttacked( target )
	return target:CanBeSeen() and not target:IsInvulnerable();
end

-----------BEAR ACT
function ConsiderBearUseAbilities(bot, hMinionUnit, ability)
	if ability:GetName() == 'lone_druid_spirit_bear_return' then
		if hMinionUnit.retreat == true then
			return BOT_ACTION_DESIRE_NONE;
		end
		if GetUnitToUnitDistance(hMinionUnit, bot) > 2500 then
			return BOT_ACTION_DESIRE_HIGH, nil, 'no_target';
		end
	elseif ability:GetName() == 'lone_druid_savage_roar_bear' then
		local radius = 375;
		if hMinionUnit.retreat == true then
			local enemies = hMinionUnit:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
			if enemies ~= nil and #enemies > 0 then
				return BOT_ACTION_DESIRE_HIGH, nil, 'no_target';
			end	
		end
		if mutil.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0)
		then
			local enemies = hMinionUnit:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
			if enemies ~= nil and #enemies > 0 then
				return BOT_ACTION_DESIRE_HIGH, nil, 'no_target';
			end	
		end
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderBearAttack(bot, hMinionUnit)
	local has_scepter = bot:HasScepter();
	local mode = bot:GetActiveMode();
	local attack_range = bot:GetAttackRange() + 200;
	local proximity_range = 1000;
	if has_scepter == true then proximity_range = 50000; end
	if hMinionUnit.retreat == true then return BOT_ACTION_DESIRE_NONE, nil; end
	local target = bot:GetTarget();
	
	if target == nil or target:IsTower() or target:IsBuilding() then
		target = bot:GetAttackTarget();
	end
	
	if target ~= nil and GetUnitToUnitDistance(hMinionUnit, bot) <= proximity_range then
		return BOT_ACTION_DESIRE_MODERATE, target;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderBearMove(bot, hMinionUnit)
	local has_scepter = bot:HasScepter();
	local mode = bot:GetActiveMode();
	local attack_range = bot:GetAttackRange() + 200;
	local target = hMinionUnit:GetAttackTarget();
	local proximity_range = 1000;
	if has_scepter == true then proximity_range = 50000; end
	
	if hMinionUnit.retreat == true then 
		return BOT_ACTION_DESIRE_HIGH, mutil.GetEscapeLoc2(hMinionUnit)
	else
		local target = bot:GetAttackTarget();
	
		if target == nil 
			or ( target ~= nil and CanBeAttacked(target) == false ) 
			or ( target ~= nil and GetUnitToUnitDistance(target, bot) > proximity_range ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, bot:GetXUnitsTowardsLocation(TeamAncient:GetLocation(), 200);
		end
	end
	
	return BOT_MODE_DESIRE_NONE, nil;
end

-----------BREW LINK ACT
function ConsiderBrewLinkUseAbilities(bot, hMinionUnit, ability)
	if ability:GetName() == 'brewmaster_earth_hurl_boulder' then
		local nCastRange = mutil.GetProperCastRange(false, hMinionUnit, ability:GetCastRange());
		
		local target = mutil.GetVulnerableWeakestUnit(true, true, nCastRange, hMinionUnit);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target, 'unit';
		end
	elseif ability:GetName() == 'brewmaster_thunder_clap' then
		local nRadius = ability:GetSpecialValueInt( "radius" );

		local enemies = hMinionUnit:GetNearbyHeroes( nRadius-100, true, BOT_MODE_NONE );
		
		if ( enemies ~= nil and #enemies >= 1 ) then
			return BOT_ACTION_DESIRE_HIGH, nil, 'no_target';
		end
	elseif ability:GetName() == 'brewmaster_drunken_brawler' then
		local nRange = hMinionUnit:GetAttackRange();
		local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( nRange+200, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) then
			return BOT_ACTION_DESIRE_HIGH, nil, 'no_target';
		end
	elseif ability:GetName() == 'brewmaster_storm_dispel_magic' then
		local nCastRange = mutil.GetProperCastRange(false, hMinionUnit, ability:GetCastRange());
		
		local allies = hMinionUnit:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for i=1, #allies do
			if mutil.IsDisabled(false, allies[i])
			then
				return BOT_ACTION_DESIRE_LOW, allies[i]:GetLocation(), 'point';
			end
		end
		
		local enemies = hMinionUnit:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if enemies ~= nil and #enemies == 1 and enemies[1]:HasModifier("modifier_brewmaster_storm_cyclone") then
			return BOT_ACTION_DESIRE_LOW, enemies[1]:GetLocation(), 'point';
		end
	elseif ability:GetName() == 'brewmaster_storm_cyclone' then
		local nCastRange = mutil.GetProperCastRange(false, hMinionUnit, ability:GetCastRange());
		local target = mutil.GetStrongestUnit(nCastRange, hMinionUnit, true, false, 5.0);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target, 'unit';
		end
		local enemies = hMinionUnit:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	
		for i=1, #enemies do
			if ( mutil.IsValidTarget(enemies[i]) and enemies[i]:IsChanneling() and mutil.CanCastOnNonMagicImmune(enemies[i]) ) 
			   or ( mutil.IsValidTarget(enemies[i]) and mutil.IsDisabled(true, enemies[i]) and mutil.CanCastOnNonMagicImmune(enemies[i]) )
			then
				return BOT_ACTION_DESIRE_LOW, enemies[i], 'unit';
			end
		end
	elseif ability:GetName() == 'brewmaster_storm_wind_walk' then
		local creeps = hMinionUnit:GetNearbyLaneCreeps( 1200, true );
		local enemies = hMinionUnit:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		
		if ( #creeps == 0 and #enemies == 0 ) then
			return BOT_ACTION_DESIRE_HIGH, nil, 'no_target';
		end
	elseif ability:GetName() == 'brewmaster_cinder_brew' then
		local nCastRange = mutil.GetProperCastRange(false, hMinionUnit, ability:GetCastRange());
		local target = mutil.GetStrongestUnit(nCastRange, hMinionUnit, true, false, 5.0);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation(), 'point';
		end
	end
	return BOT_MODE_DESIRE_NONE;
end

function ConsiderBrewLinkRetreat(bot, hMinionUnit)
	if IsBusy(hMinionUnit) or CantMove(hMinionUnit) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	if hMinionUnit:GetUnitName() ~= 'npc_dota_brewmaster_earth' then return BOT_ACTION_DESIRE_NONE, 0; end
	local allies = hMinionUnit:GetNearbyHeroes( globRadius, false, BOT_MODE_NONE );
	local enemies = hMinionUnit:GetNearbyHeroes( globRadius, true, BOT_MODE_NONE );
	if #allies == 0 and #enemies >= 2 then
		local location = mutil.GetEscapeLoc2(hMinionUnit)
		return BOT_ACTION_DESIRE_LOW, location;
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderBrewLinkAttack(bot, hMinionUnit)
	if IsBusy(hMinionUnit) or CantAttack(hMinionUnit) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local units = hMinionUnit:GetNearbyHeroes(globRadius, true, BOT_MODE_NONE);
	
	if units == nil or #units == 0 then
		units = hMinionUnit:GetNearbyLaneCreeps(globRadius, true);
	end
	if units == nil or #units == 0 then
		units = hMinionUnit:GetNearbyTowers(globRadius, true);
	end
	if units == nil or #units == 0 then
		units = hMinionUnit:GetNearbyBarracks(globRadius, true);
	end
	
	if units ~= nil and #units > 0 then
		target = GetWeakest(units);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target; 	
		end	
	end
	
	if target == nil and GetUnitToUnitDistance(hMinionUnit, EnemyAncient) < 1000 then
		return BOT_ACTION_DESIRE_HIGH, target;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderBrewLinkMove(bot, hMinionUnit)
	local NearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( globRadius, true, BOT_MODE_NONE );
	local NearbyEnemyCreeps = hMinionUnit:GetNearbyLaneCreeps( globRadius, true );
	local NearbyEnemyTowers = hMinionUnit:GetNearbyTowers( globRadius, true );
	local NearbyEnemyBarracks = hMinionUnit:GetNearbyBarracks( globRadius, true );
	
	if #NearbyEnemyHeroes == 0 and #NearbyEnemyCreeps == 0 and #NearbyEnemyTowers == 0 and #NearbyEnemyBarracks == 0 then
		local ancient = GetAncient(GetOpposingTeam());
		if ancient ~= nil then
			return BOT_ACTION_DESIRE_HIGH, ancient:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

-----------FAMILIAR ACT
function ConsiderFamiliarUseAbilities(bot, hMinionUnit, ability)
	if ability:GetName() == 'visage_summon_familiars_stone_form' then
		if hMinionUnit:HasModifier("modifier_visage_summon_familiars_stone_form_buff") 	
		then
			return BOT_ACTION_DESIRE_NONE;
		end
		local nRadius = ability:GetSpecialValueInt("stun_radius");
		local nHealth = hMinionUnit:GetHealth() / hMinionUnit:GetMaxHealth();
		if nHealth < 0.55 then
			return BOT_ACTION_DESIRE_HIGH, nil, 'no_target';
		end
		if mutil.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0)
		then
			local enemies = hMinionUnit:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
			if enemies ~= nil and #enemies > 0 then
				return BOT_ACTION_DESIRE_HIGH, nil, 'no_target';
			end
		end
		local enemies = hMinionUnit:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for i = 1, #enemies do
			if enemies[i]:IsChanneling() == true and mutil.CanCastOnNonMagicImmune(enemies[i]) == true then
				return BOT_ACTION_DESIRE_HIGH, nil, 'no_target';
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderFamiliarAttack(bot, hMinionUnit)
	if hMinionUnit:HasModifier("modifier_visage_summon_familiars_stone_form_buff") 	
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	
	
	local ProxRange = 1500;
	local target = bot:GetTarget();
	local AR = hMinionUnit:GetAttackRange();
	local OAR = bot:GetAttackRange();
	local AD = hMinionUnit:GetAttackDamage();
	
	if target == nil or target:IsTower() or target:IsBuilding() then
		target = bot:GetAttackTarget();
	end
	
	if target ~= nil and CanBeAttacked(target) and GetUnitToUnitDistance(hMinionUnit, bot) <= ProxRange then
		return BOT_ACTION_DESIRE_MODERATE, target;	
	end
	
	local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
	if not bot:IsAlive() or ( bot:GetActiveMode() == BOT_MODE_RETREAT and #enemies == 0 ) then
		local followTarget = nil;
		local closest = nil;
		local closestDist = 100000;
		for i,id in pairs(GetTeamPlayers(GetTeam())) do
			local member = GetTeamMember(i);
			if member ~= nil and member:IsAlive() then
				local target =  member:GetTarget();
				if target == nil or target:IsTower() or target:IsBuilding() then
					target = member:GetAttackTarget();
				end
				local distance = GetUnitToUnitDistance(member, hMinionUnit);
				if target ~= nil and GetUnitToUnitDistance(member, target) <= ProxRange and distance < closestDist then
					closest = member;
					closestDist = distance;
					followTarget = target;
				end
			end
		end
		if closest ~= nil and followTarget ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, followTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderFamiliarMove(bot, hMinionUnit)
	if hMinionUnit:HasModifier("modifier_visage_summon_familiars_stone_form_buff") or not bot:IsAlive() or GetUnitToUnitDistance(hMinionUnit, bot) < 150
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	
	
	local ProxRange = 1500;
	local target = bot:GetAttackTarget()
	
	if target == nil 
		or ( target ~= nil and CanBeAttacked(target) == false ) 
		or (target ~= nil and GetUnitToUnitDistance(target, bot) > ProxRange) then
		return BOT_ACTION_DESIRE_MODERATE, bot:GetXUnitsTowardsLocation(TeamAncient:GetLocation(), 200);
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderFamiliarRetreat(bot, hMinionUnit)
	
	if hMinionUnit:HasModifier("modifier_visage_summon_familiars_stone_form_buff") or hMinionUnit:DistanceFromFountain() == 0 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	

	if not bot:IsAlive() then
		local loc = mutil.GetEscapeLoc2(hMinionUnit)
		return BOT_ACTION_DESIRE_HIGH, loc;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

-----------ATTACKING WARD LIKE UNIT
function IsAttackingWard(unit_name)
	return unit_name == "npc_dota_shadow_shaman_ward_1"
		or unit_name == "npc_dota_shadow_shaman_ward_2"
		or unit_name == "npc_dota_shadow_shaman_ward_3"
		or unit_name == "npc_dota_venomancer_plague_ward_1"
		or unit_name == "npc_dota_venomancer_plague_ward_2"
		or unit_name == "npc_dota_venomancer_plague_ward_3"
		or unit_name == "npc_dota_venomancer_plague_ward_4"
		or unit_name == "npc_dota_witch_doctor_death_ward";
end

function GetWardAttackTarget(bot, hMinionUnit)
	local range = hMinionUnit:GetAttackRange() - 50;
	local target = bot:GetAttackTarget();
	if target == nil then
		target = bot:GetTarget();
	end
	if IsValidTarget(target) == false or (IsValidTarget(target) and GetUnitToUnitDistance(hMinionUnit, target) > range) then
		target = GetWeakestHero(range, hMinionUnit);
		if target == nil then target = GetWeakestCreep(range, hMinionUnit); end
		if target == nil then target = GetWeakestTower(range, hMinionUnit); end
		if target == nil then target = GetWeakestBarracks(range, hMinionUnit); end
		if target == nil and GetUnitToUnitDistance(hMinionUnit, EnemyAncient) < range then target = EnemyAncient; end
	end
	return target;
end

function ConsiderWardAttack(bot, hMinionUnit)
	local target = GetWardAttackTarget(bot, hMinionUnit);
	if target ~= nil then
		return BOT_MODE_DESIRE_HIGH, target; 
	end
	return BOT_MODE_DESIRE_NONE, nil;
end

function AttackingWardThink(bot, hMinionUnit)
	hMinionUnit.attackDesire, hMinionUnit.target = ConsiderWardAttack(bot, hMinionUnit);
	if hMinionUnit.attackDesire > 0 then
		hMinionUnit:Action_AttackUnit(hMinionUnit.target, true);
		return
	end
end

----------CAN'T BE CONTROLLED UNIT
function CantBeControlled(unit_name)
	return unit_name == "npc_dota_zeus_cloud"
		or unit_name == "npc_dota_unit_tombstone1"
		or unit_name == "npc_dota_unit_tombstone2"
		or unit_name == "npc_dota_unit_tombstone3"
		or unit_name == "npc_dota_unit_tombstone4"
		or unit_name == "npc_dota_pugna_nether_ward_1"
		or unit_name == "npc_dota_pugna_nether_ward_2"
		or unit_name == "npc_dota_pugna_nether_ward_3"
		or unit_name == "npc_dota_pugna_nether_ward_4"
		or unit_name == "npc_dota_rattletrap_cog"
		or unit_name == "npc_dota_rattletrap_rocket"
		or unit_name == "npc_dota_broodmother_web"
		or unit_name == "npc_dota_unit_undying_zombie"
		or unit_name == "npc_dota_unit_undying_zombie_torso"
		or unit_name == "npc_dota_weaver_swarm"
		or unit_name == "npc_dota_death_prophet_torment"
		or unit_name == "npc_dota_gyrocopter_homing_missile"
		or unit_name == "npc_dota_plasma_field"
		or unit_name == "npc_dota_wisp_spirit"
		or unit_name == "npc_dota_beastmaster_axe"
		or unit_name == "npc_dota_troll_warlord_axe"
		or unit_name == "npc_dota_phoenix_sun"
		or unit_name == "npc_dota_techies_minefield_sign"
		or unit_name == "npc_dota_treant_eyes"
		or unit_name == "dota_death_prophet_exorcism_spirit"
		or unit_name == "npc_dota_dark_willow_creature"
		or unit_name == "npc_dota_clinkz_skeleton_archer"
		or unit_name == "npc_dota_ignis_fatuus";
end

function CantBeControlledThink(hMinionUnit)
	return
end

-----------MINION WITH SKILLS
function IsMinionWithSkill(unit_name)
	return unit_name == "npc_dota_neutral_centaur_khan"
		or unit_name == "npc_dota_neutral_polar_furbolg_ursa_warrior"
		or unit_name == "npc_dota_neutral_mud_golem"
		or unit_name == "npc_dota_neutral_mud_golem_split"
		or unit_name == "npc_dota_neutral_mud_golem_split_doom"
		or unit_name == "npc_dota_neutral_ogre_magi"
		or unit_name == "npc_dota_neutral_enraged_wildkin"
		or unit_name == "npc_dota_neutral_satyr_soulstealer"
		or unit_name == "npc_dota_neutral_satyr_hellcaller"
		or unit_name == "npc_dota_neutral_prowler_shaman"
		or unit_name == "npc_dota_neutral_big_thunder_lizard"
		or unit_name == "npc_dota_neutral_dark_troll_warlord"
		or unit_name == "npc_dota_neutral_satyr_trickster"
		or unit_name == "npc_dota_neutral_forest_troll_high_priest"
		or unit_name == "npc_dota_neutral_harpy_storm"
		or unit_name == "npc_dota_neutral_black_dragon"
		or unit_name == "npc_dota_necronomicon_archer_1"
		or unit_name == "npc_dota_necronomicon_archer_2"
		or unit_name == "npc_dota_necronomicon_archer_3";
end

function InitiateAbility(hMinionUnit)
	hMinionUnit.abilities = {};
	for i=0, 3 do
		hMinionUnit.abilities [i+1] = hMinionUnit:GetAbilityInSlot(i);
	end
end

function CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1
end 

function CanCastAbility(ability)
	return ability ~= nil and ability:IsFullyCastable() and ability:IsPassive() == false;
end

function ConsiderUnitTarget(bot, hMinionUnit, ability)
	local castRange = ability:GetCastRange()+200;
	if bot:GetActiveMode() == BOT_MODE_RETREAT and bot:WasRecentlyDamagedByAnyHero(2.0) then
		local enemies = hMinionUnit:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
		if #enemies > 0 then
			for i=1, #enemies do
				if mutil.IsValidTarget(enemies[i]) and mutil.CanCastOnNonMagicImmune(enemies[i]) then
					return BOT_ACTION_DESIRE_HIGH, enemies[i];
				end
			end
		end
	else
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) and IsInRange(hMinionUnit, target, castRange) then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderPointTarget(bot, hMinionUnit, ability)
	local castRange = ability:GetCastRange()+200;
	if bot:GetActiveMode() == BOT_MODE_RETREAT and bot:WasRecentlyDamagedByAnyHero(2.0) then
		local enemies = hMinionUnit:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
		if #enemies > 0 then
			for i=1, #enemies do
				if mutil.IsValidTarget(enemies[i]) and mutil.CanCastOnNonMagicImmune(enemies[i]) then
					return BOT_ACTION_DESIRE_HIGH, enemies[i]:GetLocation();
				end
			end
		end
	elseif bot:GetActiveMode() == BOT_MODE_ATTACK or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY then
		local target = bot:GetAttackTarget();
		if mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) and IsInRange(hMinionUnit, target, castRange) then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end


function ConsiderNoTarget(bot, hMinionUnit, ability)
	local nRadius = ability:GetSpecialValueInt("radius");
	if bot:GetActiveMode() == BOT_MODE_RETREAT and bot:WasRecentlyDamagedByAnyHero(3.5) then
		local enemies = hMinionUnit:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	elseif bot:GetActiveMode() == BOT_MODE_ATTACK or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) and IsInRange(hMinionUnit, target, nRadius) then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

function CastThink(bot, hMinionUnit, ability)
	if CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET) and ability:IsFullyCastable() then
		if ability:GetName() == "ogre_magi_frost_armor" then
			local castRange = ability:GetCastRange();
			local allies = hMinionUnit:GetNearbyHeroes(castRange+200, false, BOT_MODE_NONE);
			if #allies > 0 then
				for i=1, #allies do
					if mutil.IsValidTarget(allies[i]) and mutil.CanCastOnNonMagicImmune(allies[i]) 
					   and allies[i]:HasModifier("modifier_ogre_magi_frost_armor") == false
					then
						hMinionUnit:Action_UseAbilityOnEntity(ability, allies[i]);
						return
					end
				end
			end
		else
			hMinionUnit.castDesire, target = ConsiderUnitTarget(bot, hMinionUnit, ability);
			if hMinionUnit.castDesire > 0 then
				-- print(bot:GetUnitName()..' '..hMinionUnit:GetUnitName()..tostring(hMinionUnit.castDesire).." Use Ability "..ability:GetName().." Target "..target:GetUnitName())
				hMinionUnit:ActionPush_UseAbilityOnEntity(ability, target);
				return
			end	
		end	
	elseif CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT) and ability:IsFullyCastable() then	
		hMinionUnit.castDesire, loc = ConsiderPointTarget(bot, hMinionUnit, ability);
		if hMinionUnit.castDesire > 0 then
			-- print(bot:GetUnitName()..' '..hMinionUnit:GetUnitName()..tostring(hMinionUnit.castDesire).." Use Ability "..ability:GetName().." Target "..tostring(loc))
			hMinionUnit:ActionPush_UseAbilityOnLocation(ability, loc);
			return
		end	
	elseif CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET) and ability:IsFullyCastable() then
		hMinionUnit.castDesire = ConsiderNoTarget(bot, hMinionUnit, ability);
		if hMinionUnit.castDesire > 0 then
			-- print(bot:GetUnitName()..' '..hMinionUnit:GetUnitName()..tostring(hMinionUnit.castDesire).." Use Ability "..ability:GetName())
			hMinionUnit:ActionPush_UseAbility(ability);
			return
		end	
	end
end

function CastAbilityThink(bot, hMinionUnit)
	if CanCastAbility(hMinionUnit.abilities[1]) then
		CastThink(bot, hMinionUnit, hMinionUnit.abilities[1]);
	end
	if CanCastAbility(hMinionUnit.abilities[2]) then
		CastThink(bot, hMinionUnit, hMinionUnit.abilities[2]);
	end
	if CanCastAbility(hMinionUnit.abilities[3]) then
		CastThink(bot, hMinionUnit, hMinionUnit.abilities[3]);
	end
	if CanCastAbility(hMinionUnit.abilities[4]) then
		CastThink(bot, hMinionUnit, hMinionUnit.abilities[4]);
	end
end	

function MinionWithSkillThink(bot, hMinionUnit)
	if IsBusy(hMinionUnit) then return; end
	if hMinionUnit.abilities == nil then InitiateAbility(hMinionUnit); end
	CastAbilityThink(bot, hMinionUnit);
	hMinionUnit.attackDesire, hMinionUnit.target = ConsiderIllusionAttack(bot,hMinionUnit);
	hMinionUnit.moveDesire, hMinionUnit.loc      = ConsiderIllusionMove(bot, hMinionUnit);
	if hMinionUnit.attackDesire > 0 then
		hMinionUnit:Action_AttackUnit(hMinionUnit.target, true);
		return
	end
	if hMinionUnit.moveDesire > 0 then
		hMinionUnit:Action_MoveToLocation(hMinionUnit.loc);
		return
	end
end

function CanAbilityBeCast(ability)
	return ability ~= nil 
		and ability:IsNull() == false 
		and ability:GetName() ~= ""
		and CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_PASSIVE) == false
		and CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_HIDDEN) == false
		and ability:IsFullyCastable()
end

function ConsiderReturn(bot, hMinionUnit, ability, ability2)
	
	if ability:IsFullyCastable() and not ability:IsHidden() and ability2:GetCooldownTimeRemaining() > 4 
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderStomp(bot, hMinionUnit, ability)

	if ( ability:IsFullyCastable() == false ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	local nRadius = ability:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = ability:GetSpecialValueInt( "stomp_damage" );

	local enemies = hMinionUnit:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	for i=1, #enemies
	do
		if ( enemies[i]:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if mutil.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.5)
	then
		local enemies = hMinionUnit:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if enemies ~= nil and #enemies > 0 then
			return BOT_ACTION_DESIRE_LOW;
		end
	end

	if mutil.IsPushing(bot) or mutil.IsDefending(bot)
	then
		local creeps = hMinionUnit:GetNearbyLaneCreeps( nRadius, true );
		if creeps ~= nil and #creeps >= 4 then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if mutil.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) and mutil.IsInRange(target, hMinionUnit, nRadius)
		then
				return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function MinionThink(  hMinionUnit ) 
	if IsValidUnit(hMinionUnit) then
		if hMinionUnit:GetUnitName() == 'npc_dota_elder_titan_ancestral_spirit' 
		then
			if bot:HasModifier('modifier_elder_titan_ancestral_spirit_buff') or not bot:IsAlive() 
			then
				castReturn = false;
			end
			
			if bot:IsAlive() 
			then
				local echo_stomp = bot:GetAbilityByName( "elder_titan_echo_stomp" )
		
				local anchestral_spirit = bot:GetAbilityByName('elder_titan_ancestral_spirit')
				
				if anchestral_spirit:IsHidden() == false then return; end
				
				if echo_stomp:IsInAbilityPhase() or bot:IsChanneling() then bot:Action_ClearActions(false) return end
				
				if ( bot:IsUsingAbility() or bot:IsCastingAbility() ) then return end
			
				local return_spirit = bot:GetAbilityByName( "elder_titan_return_spirit" );
				
				local stompDesire = ConsiderStomp(bot, hMinionUnit, echo_stomp);
				local returnDesire = ConsiderReturn(bot, hMinionUnit, return_spirit, echo_stomp); 
				
				if ( stompDesire > 0 ) 
				then
					bot:Action_UseAbility( echo_stomp );
					return;
				end
				
				if ( returnDesire > 0 and castReturn == false  ) 
				then
					castReturn = true;
					bot:Action_UseAbility( return_spirit );
					return;
				end
			end
		elseif hMinionUnit:IsIllusion() then
			IllusionThink(bot, hMinionUnit);
		elseif IsAttackingWard(hMinionUnit:GetUnitName()) then
			AttackingWardThink(bot, hMinionUnit);
		elseif CantBeControlled(hMinionUnit:GetUnitName()) 
			or IsHawk(hMinionUnit:GetUnitName()) 
			or IsRemnant(hMinionUnit:GetUnitName()) 
		then
			CantBeControlledThink(hMinionUnit);
		elseif IsMinionWithNoSkill(hMinionUnit:GetUnitName()) then
			IllusionThink(bot, hMinionUnit);
		elseif IsMinionWithSkill(hMinionUnit:GetUnitName()) 
		then
			if IsBusy(hMinionUnit) then return; end
			if hMinionUnit.abilities == nil then InitiateAbility(hMinionUnit); end
			for i = 1, #hMinionUnit.abilities do
				if CanAbilityBeCast(hMinionUnit.abilities[i]) then
					if CheckFlag(hMinionUnit.abilities[i]:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET) then
						if hMinionUnit.abilities[i]:GetName() == "ogre_magi_frost_armor" then
							local castRange = hMinionUnit.abilities[i]:GetCastRange();
							local allies = hMinionUnit:GetNearbyHeroes(castRange+200, false, BOT_MODE_NONE);
							if #allies > 0 then
								for i=1, #allies do
									if mutil.IsValidTarget(allies[i]) and mutil.CanCastOnNonMagicImmune(allies[i]) 
									   and allies[i]:HasModifier("modifier_ogre_magi_frost_armor") == false
									then
										hMinionUnit:Action_UseAbilityOnEntity(hMinionUnit.abilities[i], allies[i]);
										return
									end
								end
							end
						else
							hMinionUnit.castDesire, target = ConsiderUnitTarget(bot, hMinionUnit, hMinionUnit.abilities[i]);
							if hMinionUnit.castDesire > 0 then
								-- print(bot:GetUnitName()..' '..hMinionUnit:GetUnitName()..tostring(hMinionUnit.castDesire).." Use Ability "..hMinionUnit.abilities[i]:GetName().." Target "..target:GetUnitName())
								hMinionUnit:ActionPush_UseAbilityOnEntity(hMinionUnit.abilities[i], target);
								return
							end	
						end	
					elseif CheckFlag(hMinionUnit.abilities[i]:GetBehavior(), ABILITY_BEHAVIOR_POINT) then	
						hMinionUnit.castDesire, loc = ConsiderPointTarget(bot, hMinionUnit, hMinionUnit.abilities[i]);
						if hMinionUnit.castDesire > 0 then
							-- print(bot:GetUnitName()..' '..hMinionUnit:GetUnitName()..tostring(hMinionUnit.castDesire).." Use Ability "..hMinionUnit.abilities[i]:GetName().." Target "..tostring(loc))
							hMinionUnit:ActionPush_UseAbilityOnLocation(hMinionUnit.abilities[i], loc);
							return
						end	
					elseif CheckFlag(hMinionUnit.abilities[i]:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET) then
						hMinionUnit.castDesire = ConsiderNoTarget(bot, hMinionUnit, hMinionUnit.abilities[i]);
						if hMinionUnit.castDesire > 0 then
							-- print(bot:GetUnitName()..' '..hMinionUnit:GetUnitName()..tostring(hMinionUnit.castDesire).." Use Ability "..hMinionUnit.abilities[i]:GetName())
							hMinionUnit:ActionPush_UseAbility(hMinionUnit.abilities[i]);
							return
						end	
					end
				end	
			end
			
			hMinionUnit.attackDesire, hMinionUnit.target = ConsiderIllusionAttack(bot,hMinionUnit);
			hMinionUnit.moveDesire, hMinionUnit.loc      = ConsiderIllusionMove(bot, hMinionUnit);
			if hMinionUnit.attackDesire > 0 then
				hMinionUnit:Action_AttackUnit(hMinionUnit.target, true);
				return
			end
			if hMinionUnit.moveDesire > 0 then
				hMinionUnit:Action_MoveToLocation(hMinionUnit.loc);
				return
			end
		elseif IsBear(hMinionUnit:GetUnitName()) then 
			-- if IsBusy(hMinionUnit) then print('busy') return; end
			if hMinionUnit.abilities == nil then InitiateAbility(hMinionUnit); end
			if hMinionUnit:GetHealth() < 0.15 * hMinionUnit:GetMaxHealth() then hMinionUnit.retreat = true end
			if ( hMinionUnit:GetHealth() > 0.90 * hMinionUnit:GetMaxHealth() and hMinionUnit:DistanceFromFountain() == 0 ) 
				or hMinionUnit:GetHealth() == hMinionUnit:GetMaxHealth()
			then 
				hMinionUnit.retreat = false 
			end
			for i=1, #hMinionUnit.abilities do
				if CanAbilityBeCast(hMinionUnit.abilities[i]) == true then
					hMinionUnit.castDesire, hMinionUnit.target, target_type = ConsiderBearUseAbilities(bot, hMinionUnit, hMinionUnit.abilities[i]);
					if hMinionUnit.castDesire > BOT_ACTION_DESIRE_NONE 
					then	
						if target_type == 'no_target' then
							-- print(hMinionUnit:GetUnitName()..'cast no'..hMinionUnit.abilities[i]:GetName())
							hMinionUnit:Action_UseAbility(hMinionUnit.abilities[i]);
							return;
						end
					end
				end
			end
			hMinionUnit.attackDesire, hMinionUnit.target = ConsiderBearAttack(bot, hMinionUnit);
			hMinionUnit.moveDesire, hMinionUnit.loc = ConsiderBearMove(bot, hMinionUnit);
			
			if hMinionUnit.attackDesire > 0 then
				-- if hMinionUnit.state ~= 'attack' then
					-- hMinionUnit.state = 'attack';
					-- print('atttack')
				-- end
				hMinionUnit:Action_AttackUnit(hMinionUnit.target, true);
				return
			end
			if hMinionUnit.moveDesire > 0 then
				-- if hMinionUnit.state ~= 'move' then
					-- hMinionUnit.state = 'move';
					-- print('move')
				-- end
				hMinionUnit:Action_MoveToLocation(hMinionUnit.loc);
				return
			end
		elseif IsFamiliar(hMinionUnit:GetUnitName()) then 
			if IsBusy(hMinionUnit) then return; end
			if hMinionUnit.abilities == nil then InitiateAbility(hMinionUnit); end
			for i=1, #hMinionUnit.abilities do
				if CanAbilityBeCast(hMinionUnit.abilities[i]) == true then
					hMinionUnit.castDesire, hMinionUnit.target, target_type = ConsiderFamiliarUseAbilities(bot, hMinionUnit, hMinionUnit.abilities[i]);
					if hMinionUnit.castDesire > BOT_ACTION_DESIRE_NONE 
					then	
						if target_type == 'no_target' then
							-- print(hMinionUnit:GetUnitName()..'cast no'..hMinionUnit.abilities[i]:GetName())
							hMinionUnit:Action_UseAbility(hMinionUnit.abilities[i]);
							return;
						end
					end
				end
			end
			hMinionUnit.retreatDesire, hMinionUnit.ret_loc = ConsiderFamiliarRetreat(bot, hMinionUnit);
			hMinionUnit.attackDesire, hMinionUnit.target = ConsiderFamiliarAttack(bot, hMinionUnit);
			hMinionUnit.moveDesire, hMinionUnit.loc = ConsiderFamiliarMove(bot, hMinionUnit);
			if hMinionUnit.attackDesire > 0 then
				hMinionUnit:Action_AttackUnit(hMinionUnit.target, true);
				return
			end
			if hMinionUnit.moveDesire > 0 then
				hMinionUnit:Action_MoveToLocation(hMinionUnit.loc);
				return
			end
			if hMinionUnit.retreatDesire > 0 then
				-- print(hMinionUnit:GetUnitName()..'ret')
				hMinionUnit:Action_MoveToLocation(hMinionUnit.ret_loc);
				return
			end
		elseif IsBrewLink(hMinionUnit:GetUnitName()) then	
			if IsBusy(hMinionUnit) then return; end
			if hMinionUnit.abilities == nil then InitiateAbility(hMinionUnit); end
			for i=1, #hMinionUnit.abilities do
				if CanAbilityBeCast(hMinionUnit.abilities[i]) == true then
					hMinionUnit.castDesire, hMinionUnit.target, target_type = ConsiderBrewLinkUseAbilities(bot, hMinionUnit, hMinionUnit.abilities[i]);
					if hMinionUnit.castDesire > BOT_ACTION_DESIRE_NONE 
					then	
						if target_type == 'no_target' then
							-- print(hMinionUnit:GetUnitName()..'cast no'..hMinionUnit.abilities[i]:GetName())
							hMinionUnit:Action_UseAbility(hMinionUnit.abilities[i]);
							return;
						elseif target_type == 'point' then
							-- print(hMinionUnit:GetUnitName()..'cast point'..hMinionUnit.abilities[i]:GetName())
							hMinionUnit:Action_UseAbilityOnLocation(hMinionUnit.abilities[i], hMinionUnit.target)
							return;	
						elseif target_type == 'unit' then
							-- print(hMinionUnit:GetUnitName()..'cast unit'..hMinionUnit.abilities[i]:GetName())
							hMinionUnit:Action_UseAbilityOnEntity(hMinionUnit.abilities[i], hMinionUnit.target)
							return;	
						elseif target_type == 'tree' then
							-- print(hMinionUnit:GetUnitName()..'cast tree'..hMinionUnit.abilities[i]:GetName())
							hMinionUnit:Action_UseAbilityOnTree(hMinionUnit.abilities[i], hMinionUnit.target)
							return;	
						end
					end
				end
			end
			hMinionUnit.retreatDesire, hMinionUnit.ret_loc = ConsiderBrewLinkRetreat(bot, hMinionUnit);
			hMinionUnit.attackDesire, hMinionUnit.target = ConsiderBrewLinkAttack(bot, hMinionUnit);
			hMinionUnit.moveDesire, hMinionUnit.loc = ConsiderBrewLinkMove(bot, hMinionUnit);
			if hMinionUnit.retreatDesire > 0 then
				-- print(hMinionUnit:GetUnitName()..'ret')
				hMinionUnit:Action_MoveToLocation(hMinionUnit.ret_loc);
				return
			end
			if hMinionUnit.attackDesire > 0 then
				-- print(hMinionUnit:GetUnitName()..'at')
				hMinionUnit:Action_AttackUnit(hMinionUnit.target, true);
				return
			end
			if hMinionUnit.moveDesire > 0 then
				-- print(hMinionUnit:GetUnitName()..'move')
				hMinionUnit:Action_MoveToLocation(hMinionUnit.loc);
				return
			end
		elseif IsTornado(hMinionUnit:GetUnitName()) then
			hMinionUnit.attackDesire, hMinionUnit.target = ConsiderIllusionAttack(bot,hMinionUnit);
			if hMinionUnit.attackDesire > 0 and hMinionUnit.target ~= nil and hMinionUnit.target:IsNull() == false then
				hMinionUnit:Action_MoveToLocation(hMinionUnit.target:GetLocation());
				return
			end
			return
		elseif IsHealingWard(hMinionUnit:GetUnitName()) then
			if GetUnitToUnitDistance(hMinionUnit, bot) > 150 then
				hMinionUnit:Action_MoveToLocation(bot:GetLocation());
				return
			else
				return
			end
		elseif IsTrap(hMinionUnit:GetUnitName()) then
			if hMinionUnit:GetUnitName() == 'npc_dota_templar_assassin_psionic_trap' 
				or hMinionUnit:GetUnitName() == 'npc_dota_techies_remote_mine'
			then	
				hMinionUnit.mAbility = hMinionUnit:GetAbilityInSlot(0);
				if CanAbilityBeCast(hMinionUnit.mAbility) then
					local nRadius = 400;
					local enemies = hMinionUnit:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
					if #enemies > 0 then
						hMinionUnit:ActionPush_UseAbility(hMinionUnit.mAbility);
						return
					end
					local creeps = hMinionUnit:GetNearbyCreeps(nRadius, true)
					if #creeps >= 4 then
						hMinionUnit:ActionPush_UseAbility(hMinionUnit.mAbility);
						return
					end
				end
			else	
				return
			end	
		end
	end
end	