# This file was generated, do not modify it. # hide
kfm_mat = Matrix(
	@chain kfm begin
		select(Not(1, 3, 5))
	end
);

kfm |> size

kfm_mat |> size

kfm_mat[1:5, :]