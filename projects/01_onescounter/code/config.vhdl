configuration mealy of tb is
	for behav
		for DUT : onescounter
			use entity work.onescounter(mealy);
		end for;
	end for;
end mealy;
