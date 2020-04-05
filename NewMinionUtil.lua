local BotsInit = require( "game/botsinit" );
local MyModule = BotsInit.CreateGeneric();

local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/MyUtility")

local TeamAncient = GetAncient(GetTeam());
local TeamAncientLoc = TeamAncient:GetLocation();
local EnemyAncient = GetAncient(GetOpposingTeam());
local EnemyAncientLoc = EnemyAncient:GetLocation();
local centre = Vector(0, 0, 0);

--print(tostring(EnemyBaseLoc));

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

function HawkThink(bot, minion)
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
	"npc_dota_earth_spirit_stone"
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

function GetWeakestHero(radius, minion)
	local enemies = minion:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
	return GetWeakest(enemies);
end

function GetWeakestCreep(radius, minion)
	local creeps = minion:GetNearbyLaneCreeps(radius, true);
	return GetWeakest(creeps);
end

function GetWeakestTower(radius, minion)
	local towers = minion:GetNearbyTowers(radius, true);
	return GetWeakest(towers);
end

function GetWeakestBarracks(radius, minion)
	local barracks = minion:GetNearbyBarracks(radius, true);
	return GetWeakest(barracks);
end

function GetIllusionAttackTarget(bot, minion)
	local target = bot:GetAttackTarget();
	if target == nil and bot:GetActiveMode() == BOT_MODE_RETREAT then
		target = GetWeakestHero(globRadius, minion);
		if target == nil then target = GetWeakestCreep(globRadius, minion); end
		if target == nil then target = GetWeakestTower(globRadius, minion); end
		if target == nil then target = GetWeakestBarracks(globRadius, minion); end
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
function ConsiderIllusionAttack(bot, minion)
	if CantAttack(minion) then return BOT_MODE_DESIRE_NONE, nil; end
	local target = GetIllusionAttackTarget(bot, minion);
	if target ~= nil then
		return BOT_MODE_DESIRE_HIGH, target; 
	end
	return BOT_MODE_DESIRE_NONE, nil;
end

function ConsiderIllusionMove(bot, minion)
	if CantMove(minion) then return BOT_MODE_DESIRE_NONE, nil; end
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT then
		return BOT_MODE_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(TeamAncientLoc, 300); 
	end
	return BOT_MODE_DESIRE_NONE, nil;
end

function IllusionThink(bot,minion)
	minion.attackDesire, minion.target = ConsiderIllusionAttack(bot, minion);
	minion.moveDesire, minion.loc      = ConsiderIllusionMove(bot, minion);
	if minion.attackDesire > 0 then
		minion:Action_AttackUnit(minion.target, true);
		return
	end
	if minion.moveDesire > 0 then
		minion:Action_MoveToLocation(minion.loc);
		return
	end
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

function GetWardAttackTarget(bot, minion)
	local range = minion:GetAttackRange();
	local target = bot:GetAttackTarget();
	if IsValidTarget(target) == false or (IsValidTarget(target) and GetUnitToUnitDistance(minion, target) < range) then
		target = GetWeakestHero(range, minion);
		if target == nil then target = GetWeakestCreep(range, minion); end
		if target == nil then target = GetWeakestTower(range, minion); end
		if target == nil then target = GetWeakestBarracks(range, minion); end
	end
	return target;
end

function ConsiderWardAttack(bot, minion)
	local target = GetWardAttackTarget(bot, minion);
	if target ~= nil then
		return BOT_MODE_DESIRE_HIGH, target; 
	end
	return BOT_MODE_DESIRE_NONE, nil;
end

function AttackingWardThink(bot, minion)
	minion.attackDesire, minion.target = ConsiderWardAttack(bot, minion);
	if minion.attackDesire > 0 then
		minion:Action_AttackUnit(minion.target, true);
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
		or unit_name == "npc_dota_clinkz_skeleton_archer";
end

function CantBeControlledThink(minion)
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

function InitiateAbility(minion)
	minion.abilities = {};
	for i=0, 3 do
		minion.abilities [i+1] = minion:GetAbilityInSlot(i);
	end
end

function CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1
end 

function CanCastAbility(ability)
	return ability ~= nil and ability:IsFullyCastable() and ability:IsPassive() == false;
end

function ConsiderUnitTarget(bot, minion, ability)
	local castRange = ability:GetCastRange()+200;
	if bot:GetActiveMode() == BOT_MODE_RETREAT and bot:WasRecentlyDamagedByAnyHero(2.0) then
		local enemies = minion:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
		if #enemies > 0 then
			for i=1, #enemies do
				if IsValidTarget(enemies[i]) and CanCastOnTarget(enemies[i], ability) then
					return BOT_ACTION_DESIRE_HIGH, enemies[i];
				end
			end
		end
	else
		local target = bot:GetTarget();
		if IsValidTarget(target) and IsInRange(minion, target, castRange) then
			print('cast unit')
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderPointTarget(bot, minion, ability)
	local castRange = ability:GetCastRange()+200;
	if bot:GetActiveMode() == BOT_MODE_RETREAT and bot:WasRecentlyDamagedByAnyHero(2.0) then
		local enemies = minion:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
		if #enemies > 0 then
			for i=1, #enemies do
				if IsValidTarget(enemies[i]) and CanCastOnTarget(enemies[i], ability) then
					return BOT_ACTION_DESIRE_HIGH, enemies[i]:GetLocation();
				end
			end
		end
	elseif bot:GetActiveMode() == BOT_MODE_ATTACK or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY then
		local target = bot:GetAttackTarget();
		if IsValidTarget(target) and CanCastOnTarget(target, ability) and IsInRange(minion, target, castRange) then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end


function ConsiderNoTarget(bot, minion, ability)
	local nRadius = ability:GetSpecialValueInt("radius");
	if bot:GetActiveMode() == BOT_MODE_RETREAT and bot:WasRecentlyDamagedByAnyHero(3.5) then
		local enemies = minion:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	elseif bot:GetActiveMode() == BOT_MODE_ATTACK or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY then
		local target = bot:GetTarget();
		if IsValidTarget(target) and IsInRange(minion, target, nRadius) then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

function CastThink(bot, minion, ability)
	if CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET) and ability:IsFullyCastable() then
		if ability:GetName() == "ogre_magi_frost_armor" then
			local castRange = ability:GetCastRange();
			local allies = minion:GetNearbyHeroes(castRange+200, false, BOT_MODE_NONE);
			if #allies > 0 then
				for i=1, #allies do
					if IsValidTarget(allies[i]) and CanCastOnTarget(allies[i], ability) 
					   and allies[i]:HasModifier("ogre_magi_frost_armor") == false
					then
						minion:Action_UseAbilityOnEntity(ability, allies[i]);
						return
					end
				end
			end
		else
			minion.castDesire, target = ConsiderUnitTarget(bot, minion, ability);
			if minion.castDesire > 0 then
				print(bot:GetUnitName()..' '..minion:GetUnitName()..tostring(minion.castDesire).." Use Ability "..ability:GetName().." Target "..target:GetUnitName())
				minion:ActionPush_UseAbilityOnEntity(ability, target);
				return
			end	
		end	
	elseif CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT) and ability:IsFullyCastable() then	
		minion.castDesire, loc = ConsiderPointTarget(bot, minion, ability);
		if minion.castDesire > 0 then
			print(bot:GetUnitName()..' '..minion:GetUnitName()..tostring(minion.castDesire).." Use Ability "..ability:GetName().." Target "..tostring(loc))
			minion:ActionPush_UseAbilityOnLocation(ability, loc);
			return
		end	
	elseif CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET) and ability:IsFullyCastable() then
		-- minion.castDesire = ConsiderNoTarget(bot, minion, ability);
		-- if minion.castDesire > 0 then
			print(bot:GetUnitName()..' '..minion:GetUnitName()..tostring(minion.castDesire).." Use Ability "..ability:GetName())
			minion:ActionPush_UseAbility(ability);
			return
		-- end	
	end
end

function CastAbilityThink(bot, minion)
	if CanCastAbility(minion.abilities[1]) then
		CastThink(bot, minion, minion.abilities[1]);
	end
	if CanCastAbility(minion.abilities[2]) then
		CastThink(bot, minion, minion.abilities[2]);
	end
	if CanCastAbility(minion.abilities[3]) then
		CastThink(bot, minion, minion.abilities[3]);
	end
	if CanCastAbility(minion.abilities[4]) then
		CastThink(bot, minion, minion.abilities[4]);
	end
end	

function MinionWithSkillThink(bot, minion)
	if IsBusy(minion) then return; end
	if minion.abilities == nil then InitiateAbility(minion); end
	CastAbilityThink(bot, minion);
	minion.attackDesire, minion.target = ConsiderIllusionAttack(bot,minion);
	minion.moveDesire, minion.loc      = ConsiderIllusionMove(bot, minion);
	if minion.attackDesire > 0 then
		minion:Action_AttackUnit(minion.target, true);
		return
	end
	if minion.moveDesire > 0 then
		minion:Action_MoveToLocation(minion.loc);
		return
	end
end

function MinionThink(  bot, hMinionUnit ) 
	if IsValidUnit(hMinionUnit) then
		if hMinionUnit:IsIllusion() then
			IllusionThink(bot, hMinionUnit);
		elseif IsAttackingWard(hMinionUnit:GetUnitName()) then
			AttackingWardThink(bot, hMinionUnit);
		elseif CantBeControlled(hMinionUnit:GetUnitName()) or IsHawk(hMinionUnit:GetUnitName()) then
			CantBeControlledThink(hMinionUnit);
		elseif IsMinionWithNoSkill(hMinionUnit:GetUnitName()) then
			IllusionThink(bot, hMinionUnit);
		elseif IsMinionWithSkill(hMinionUnit:GetUnitName()) then
			MinionWithSkillThink(bot, hMinionUnit);	
		end
	end
end	


return MyModule;