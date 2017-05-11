mode_attack_generic = dofile( GetScriptDirectory().."/ps/mode_attack" )

function OnStart()
	mode_attack_generic.OnStart();
end

function OnEnd()
	mode_attack_generic.OnEnd();
end

function GetDesire()
	return mode_attack_generic.GetDesire();
end

function Think()
	mode_attack_generic.Think();
end
