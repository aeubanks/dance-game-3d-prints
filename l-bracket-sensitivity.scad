// Strip that sits between a DDR pad's L-bracket (top) and sensor (bottom),
// with bottom pads to reduce sensor contact area, top outer stops to keep it
// from shifting under the L-bracket, and a downward side lip that tucks into
// the sensor crevice and doubles as a built-in brim when printed on edge.

// all constants are in mm

bracket_width = 71;
strip_len = 20;
base_thickness = 1;

pad_width = 12;
pad_thickness = 1.7;

stop_width = 10;
stop_thickness = 2;

lip_depth = 4;
lip_thickness = 0.8;

total_width = bracket_width + 2 * stop_width;
base_z = lip_depth;

// rotated for printing: standing on the lip edge (Z = 0..20), 91 mm along Y
rotate([90, 0, 90]) {
	union() {
		// main strip; top sits flush against the underside of the L-bracket
		translate([0, 0, base_z]) {
			cube([total_width, strip_len, base_thickness]);
		}
		// bottom pads pressing down onto the sensor
		for (x = [stop_width, total_width - stop_width - pad_width]) {
			translate([x, 0, base_z + base_thickness - pad_thickness]) {
				cube([pad_width, strip_len, pad_thickness]);
			}
		}
		// top outer stops cradling both ends of the L-bracket
		for (x = [0, total_width - stop_width]) {
			translate([x, 0, base_z]) {
				cube([stop_width, strip_len, stop_thickness]);
			}
		}
		// downward side lip into sensor crevice (print-bed base at Z = 0..0.8)
		cube([total_width, lip_thickness, base_z + base_thickness]);
	}
}
