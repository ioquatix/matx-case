
// This function creates a cube with a given x/y either above (f=1) or below (f=-1) the z axis.
module zcube(dimensions, z=0, f=1) {
	translate([0, 0, dimensions[2]/2 * f + z]) cube(dimensions, true);
}