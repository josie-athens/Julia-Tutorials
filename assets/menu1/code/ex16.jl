# This file was generated, do not modify it. # hide
@chain smokers begin
	select(Not([:id, :type_chd, :ncigs, :beh_pat]))
	size
end