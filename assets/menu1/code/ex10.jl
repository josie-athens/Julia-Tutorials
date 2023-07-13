# This file was generated, do not modify it. # hide
air = rcopy(R"datasets::airquality");

air.Month = categorical(recode(
    air.Month,
    5 => "May",
    6 => "Jun",
    7 => "Jul",
    8 => "Aug",
    9 => "Sep"
), ordered=true);

air |> schema