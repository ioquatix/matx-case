
include <../source/case.scad>;

translate([internal_size[0]*0.6, 0, 0]) projection() rotate([180, 0, 0]) bottom_panel();
translate([-internal_size[0]*0.6, 0, 0]) projection() top_panel();
