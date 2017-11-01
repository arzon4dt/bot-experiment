print("bot_generic for "..GetBot():GetUnitName());
local a = {"1", "2", "3"};
		a[3] = nil;
		a[2] = nil;
		print(tostring(#a))

		for a, b in pairs(a) do 
			print(a .. " * " .. tostring(b))
		end