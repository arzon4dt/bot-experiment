local mutil = require(GetScriptDirectory() ..  "/MyUtility")
local bot = GetBot();
local cAbility = nil;

function GetDesire()
	
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
	end
	
	return 0.0;
	
end

function Think()
	
	if bot:GetUnitName() == "npc_dota_hero_shadow_shaman" 
	or  bot:GetUnitName() == "npc_dota_hero_keeper_of_the_light" 
	or  bot:GetUnitName() == "npc_dota_hero_pugna" 
	or  bot:GetUnitName() == "npc_dota_hero_elder_titan" 
	or  bot:GetUnitName() == "npc_dota_hero_elder_titan" 
	or  bot:GetUnitName() == "npc_dota_hero_puck" 
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
	end
	
end