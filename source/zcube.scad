
// This function creates a cube with a given x/y either above (f=1) or below (f=-1) the z axis.
module zcube(dimensions, z=0, f=1) {
	translate([0, 0, dimensions[2]/2 * f + z]) cube(dimensions, true);
}

module zring(dimensions, thickness, z=0, f=1) {
	render() difference() {
		zcube([dimensions[0]+thickness/2, dimensions[1]+thickness/2, dimensions[2]], z=z, f=f);
		zcube([dimensions[0]-thickness/2, dimensions[1]-thickness/2, dimensions[2]], z=z, f=f);
	}
}

module rcube(dimensions, d = 1, z=0, f=1) {
	dx = dimensions[0]/2 - d/2;
	dy = dimensions[1]/2 - d/2;
	dz = dimensions[2]/2 * (f-1) + z;
	
	hull() {
		translate([-dx, -dy, dz]) cylinder(h=dimensions[2], d=d);
		translate([-dx, dy, dz]) cylinder(h=dimensions[2], d=d);
		translate([dx, -dy, dz]) cylinder(h=dimensions[2], d=d);
		translate([dx, dy, dz]) cylinder(h=dimensions[2], d=d);
	}
}

module zcorners() {
	children();
	mirror([1, 0, 0]) children();
	mirror([0, 1, 0]) children();
	mirror([1, 0, 0]) mirror([0, 1, 0]) children();
}

module reflect(axis = [1, 0, 0]) {
	children();
	mirror(axis) children();
}

module zsides(dimensions, thickness, inset=0) {
	reflect([1, 0, 0]) {
		translate([thickness/2+dimensions[0]/2, 0, dimensions[2]/2]) cube([thickness, dimensions[1]-inset*2, dimensions[2]], true);
	}
	
	reflect([0, 1, 0]) {
		translate([0, thickness/2+dimensions[1]/2, dimensions[2]/2]) cube([dimensions[0]-inset*2, thickness, dimensions[2]], true);
	}
}