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
	then
		return;	
	end
	
end