// U-shaped strip that sits between a DDR pad's L-bracket (top) and sensor
// (bottom), with two solid contact-pad arms, upward-tapered outer stops, an
// open middle for full sensor clearance and warp-free printing, and a downward
// side lip that tucks into the sensor crevice.
//
// Modeled directly in print orientation: Z = 0..strip_len, Y = 0..total_width.

// all constants are in mm

bracket_width = 71;
strip_len = 25;
base_thickness = 0.6;

pad_width = 12;
pad_thickness = 1.7;

stop_width = 10;
stop_lip = 1;
stop_tip_thickness = 0.8;

lip_depth = 4;
lip_thickness = 1;

bridge_height = 5;
corner_gusset = 4;

total_width = bracket_width + 2 * stop_width;
mid_start = stop_width + pad_width;
base_x = lip_depth;
seat_x = base_x + base_thickness;
pad_x = seat_x - pad_thickness;
stop_top_x = seat_x + stop_lip;
stop_tip_x = stop_top_x - stop_tip_thickness;

difference() {
	union() {
		// main profile standing in Z
		linear_extrude(height = strip_len) {
			polygon([
				[stop_tip_x, 0],
				[base_x, stop_width],
				[pad_x, stop_width],
				[pad_x, mid_start],
				[base_x, mid_start],
				[base_x, total_width - mid_start],
				[pad_x, total_width - mid_start],
				[pad_x, total_width - stop_width],
				[base_x, total_width - stop_width],
				[stop_tip_x, total_width],
				[stop_top_x, total_width],
				[stop_top_x, total_width - stop_width],
				[seat_x, total_width - stop_width],
				[seat_x, stop_width],
				[stop_top_x, stop_width],
				[stop_top_x, 0],
			]);
		}
		// downward crevice lip / built-in print-bed base (Z = 0..lip_thickness)
		linear_extrude(height = lip_thickness) {
			polygon([
				[0, 0],
				[0, total_width],
				[stop_top_x, total_width],
				[stop_top_x, total_width - stop_width],
				[seat_x, total_width - stop_width],
				[seat_x, stop_width],
				[stop_top_x, stop_width],
				[stop_top_x, 0],
			]);
		}
	}
	// open U-cutout in the middle above bridge_height with 45-degree corner gussets
	translate([base_x - 1, 0, 0]) {
		rotate([90, 0, 90]) {
			linear_extrude(height = base_thickness + 2) {
				polygon([
					[mid_start + corner_gusset, bridge_height],
					[total_width - mid_start - corner_gusset, bridge_height],
					[total_width - mid_start, bridge_height + corner_gusset],
					[total_width - mid_start, strip_len + 1],
					[mid_start, strip_len + 1],
					[mid_start, bridge_height + corner_gusset],
				]);
			}
		}
	}
}
