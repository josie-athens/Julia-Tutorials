# This file was generated, do not modify it. # hide
wcgs.smoker = wcgs.ncigs .> 0;

wcgs.smoker = categorical(
	recode(wcgs.smoker, 0 => "Non-Smoker", 1 => "Smoker"),
	ordered=true
);