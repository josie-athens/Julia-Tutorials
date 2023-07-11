# This file was generated, do not modify it. # hide
@chain wcgs begin
	select(:ncigs, :smoker)
	first(5)
end

@chain smokers begin
	select(Not([:id, :type_chd, :ncigs, :beh_pat]))
	size
end