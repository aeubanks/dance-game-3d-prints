// Small ITG stamina pad for a 277x277x9mm hollow-bottom center metal panel,
// using two opposing square FSRs (Adafruit 1075) per hinged arrow panel.
// Prints support-free and hardware-free on a Prusa MK4S (250x210x220mm):
//   - 4x quadrant       (center support grid + FSR/wire pockets + keyhole hinges)
//   - 4x panel          (1-piece 277mm panel, pre-angled 37.52 deg to fit bed)
//   - 8x butterfly_key  (locks base quadrants across seams beneath panels)

$fa = 2;
$fs = 0.4;

// all constants are in mm

// ---- center metal panel & vertical stack ----
center_size = 277;
center_h = 9;
center_wall = 2;
center_fit_clear = 0.4;

pad_h = 14;
panel_h = 7;
ridge_gap = 0.8;
wire_floor_z = 2.2;

// ---- FSR & wire channels ----
fsr_head = 45;
fsr_pocket_depth = 1;
fsr_neck_len = 18;
tail_d0 = 15;
chan_w = 18;
bend_chamfer = 14;
side_rim = 10;
exit_chan_w = 12;

// ---- arrow radial layout & keyhole cam hinge ----
metal_pocket_gap = 1.0;
panel_gap = 1.7;
inner_rim = 2.3;
outer_rim = 2.5;
panel_corner_chamfer = 8;
panel_print_deg = 37.52;

cam_r = 3.2;
cam_half_h = 2.2;
cam_root_chamfer = 0.7;
sock_r = 3.45;
sock_chamfer = 0.9;
base_knuckle_r = 6.6;
hinge_radial_clear = 0.5;
knuckle_floor_clear = 0.3;

pin_len = 4;
sock_depth = 4.5;
knuckle_gap = 0.5;
k_end = 20;
k_panel = 34;

lift_bevel = 3.5;
lift_len = 22;

// ---- center support grid & butterfly joints ----
frame_beam_w = 18;
boss_w = 14;
rib_w = 11;
gusset_ext = 18;
boss_corner_trim = 24;

joint_clear = 0.12;
key_len = 24;
key_waist = 10;
key_end = 15;
key_pull_d = 3.2;

// ---- derived dimensions ----
half_c = center_size / 2;
base_h = pad_h - panel_h;
boss_top_z = pad_h - center_wall;
rim_shelf_z = pad_h - center_h - ridge_gap;

boss_outer = half_c - center_wall - center_fit_clear;
boss_inner = boss_outer - boss_w;
highway_inner = boss_inner - chan_w;
window_max = highway_inner - rib_w;
rib_start = (frame_beam_w + window_max - rib_w) / 2;
win_size = rib_start - frame_beam_w;

d_fsr = panel_gap + inner_rim;
d_panel_end = d_fsr + fsr_head + outer_rim;
z_hinge = pad_h - cam_half_h;
panel_knuckle_r = z_hinge - base_h - knuckle_floor_clear;
d_hinge = d_panel_end + base_knuckle_r + hinge_radial_clear;
d_outer = d_hinge + base_knuckle_r;

u_fsr_outer = half_c - side_rim;
u_fsr_inner = u_fsr_outer - fsr_head;
u_neck_inner = u_fsr_inner - fsr_neck_len;

k_p1 = k_end + knuckle_gap;
k_b2 = k_p1 + k_panel + knuckle_gap;
k_p2 = half_c - k_p1 - k_panel;

key_slot_depth = base_h - wire_floor_z;
key_h = key_slot_depth - 0.2;
key_r_inner = rib_start + rib_w / 2;
key_r_outer = half_c + (tail_d0 + chan_w + d_panel_end) / 2 + 0.8;

// ---- view / export controls ----
part = "assembly";
open_east_deg = 180;

module mirror_xy() {
	children();
	mirror([1, -1, 0]) {
		children();
	}
}

module mirror_x() {
	children();
	mirror([1, 0, 0]) {
		children();
	}
}

module cyl_x(r, h) {
	rotate([0, 90, 0]) {
		cylinder(r = r, h = h);
	}
}

module butterfly_2d(shrink = 0) {
	offset(delta = -shrink) {
		polygon([
			[-key_len / 2, -key_end / 2],
			[0, -key_waist / 2],
			[key_len / 2, -key_end / 2],
			[key_len / 2, key_end / 2],
			[0, key_waist / 2],
			[-key_len / 2, key_end / 2]
		]);
	}
}

module butterfly_key() {
	difference() {
		linear_extrude(height = key_h) {
			butterfly_2d(joint_clear);
		}
		translate([0, 0, -1]) {
			cylinder(d = key_pull_d, h = key_h + 2);
		}
	}
}

// Top-truncated horizontal knuckle spanning u in [u0 .. u0 + w]
module knuckle_bar(u0, w, r, d_back, z_bot, z_c, z_top) {
	intersection() {
		translate([u0 - 1, d_back - 1, 0]) {
			cube([w + 2, d_outer + 2, z_top]);
		}
		hull() {
			translate([u0, d_hinge, z_c]) {
				cyl_x(r, w);
			}
			translate([u0, d_back, z_bot]) {
				cube([w, d_hinge + (z_bot > 0 ? r : 0) - d_back, z_bot > 0 ? z_c - z_bot : z_top]);
			}
		}
	}
}

module arrow_wing_solid() {
	cube([half_c, d_outer, rim_shelf_z]);
	translate([0, metal_pocket_gap, 0]) {
		cube([half_c, d_outer - metal_pocket_gap, base_h]);
	}
	for (seg = [[0, k_end], [k_b2, half_c - k_b2], [half_c - k_end, half_c]]) {
		knuckle_bar(seg[0], seg[1] - seg[0], base_knuckle_r, d_hinge - base_knuckle_r, rim_shelf_z, z_hinge, pad_h);
	}
}

module arrow_wing_cuts() {
	fsr_floor_z = base_h - fsr_pocket_depth;
	// FSR sensing head pocket & flat Mylar neck shelf
	translate([u_fsr_inner, d_fsr, fsr_floor_z]) {
		cube([fsr_head, fsr_head, pad_h]);
	}
	translate([u_neck_inner, tail_d0, fsr_floor_z]) {
		cube([fsr_neck_len + 1, chan_w, pad_h]);
	}
	// Continuous shared trough & wide central funnel into interior wire highway
	translate([-1, tail_d0, wire_floor_z]) {
		cube([u_neck_inner + 2, chan_w, pad_h]);
	}
	translate([-1, -(half_c - highway_inner), wire_floor_z]) {
		cube([chan_w + 1, (half_c - highway_inner) + tail_d0 + chan_w, pad_h]);
	}
	translate([0, 0, wire_floor_z]) {
		linear_extrude(height = pad_h) {
			polygon([
				[chan_w - 1, tail_d0 + 1],
				[chan_w + bend_chamfer, tail_d0 + 1],
				[chan_w - 1, tail_d0 - bend_chamfer]
			]);
		}
	}
	// Four enclosed keyhole bearing sockets with 45-deg lead-in chamfers
	for (s = [[k_end, 1], [k_b2, -1], [half_c - k_b2, 1], [half_c - k_end, -1]]) {
		u_face = s[0];
		dir = s[1];
		translate([dir > 0 ? u_face - sock_depth : u_face - 1, d_hinge, z_hinge]) {
			cyl_x(sock_r, sock_depth + 1);
		}
		translate([u_face, d_hinge, z_hinge]) {
			rotate([0, dir > 0 ? -90 : 90, 0]) {
				cylinder(r1 = sock_r + sock_chamfer, r2 = sock_r, h = sock_chamfer);
			}
		}
	}
	// Trim inner-outer corner tip above rim_shelf_z beside the 45-deg wire exit
	translate([0, 0, rim_shelf_z]) {
		linear_extrude(height = pad_h) {
			polygon([
				[u_fsr_outer + 2, 0],
				[half_c + 1, 0],
				[half_c + 1, half_c - u_fsr_outer - 1]
			]);
		}
	}
}

module quadrant() {
	difference() {
		union() {
			cube([half_c, half_c, rim_shelf_z]);
			cube([boss_outer, boss_outer, boss_top_z]);
			mirror_xy() {
				translate([0, half_c, 0]) {
					arrow_wing_solid();
				}
			}
			linear_extrude(height = rim_shelf_z) {
				polygon([
					[boss_inner, boss_inner],
					[half_c + gusset_ext, boss_inner],
					[half_c + gusset_ext, half_c],
					[half_c, half_c + gusset_ext],
					[boss_inner, half_c + gusset_ext]
				]);
			}
		}
		// Four center weight-saving windows
		for (wx = [frame_beam_w, rib_start + rib_w], wy = [frame_beam_w, rib_start + rib_w]) {
			translate([wx, wy, -1]) {
				cube([win_size, win_size, pad_h]);
			}
		}
		// Trim outer boss at corner for wire bundle exit
		translate([boss_outer - boss_corner_trim, boss_outer - boss_corner_trim, rim_shelf_z]) {
			cube([boss_corner_trim + 1, boss_corner_trim + 1, pad_h]);
		}
		// Diagonal 45-deg wire bundle exit out the open corner
		translate([highway_inner, highway_inner, wire_floor_z]) {
			rotate([0, 0, 45]) {
				translate([0, -exit_chan_w / 2, 0]) {
					cube([80, exit_chan_w, pad_h]);
				}
			}
		}
		// Wire highway, wing pockets/hinges, and seam butterfly sockets on both axes
		mirror_xy() {
			translate([-1, highway_inner, wire_floor_z]) {
				cube([boss_inner + 1, chan_w, pad_h]);
			}
			translate([0, half_c, 0]) {
				arrow_wing_cuts();
			}
			for (s = [[key_r_inner, boss_top_z], [key_r_outer, base_h]]) {
				translate([0, s[0], s[1] - key_slot_depth]) {
					linear_extrude(height = key_slot_depth + 1) {
						butterfly_2d();
					}
				}
			}
		}
	}
}

module cam_trunnion(u_shoulder, dir) {
	z_c = panel_h - cam_half_h;
	u_start = dir > 0 ? u_shoulder - 1 : u_shoulder - pin_len;
	intersection() {
		union() {
			translate([u_start, d_hinge, z_c]) {
				cyl_x(cam_r, pin_len + 1);
			}
			translate([u_shoulder, d_hinge, z_c]) {
				rotate([0, dir > 0 ? 90 : -90, 0]) {
					cylinder(r1 = cam_r + cam_root_chamfer, r2 = cam_r, h = cam_root_chamfer);
				}
			}
		}
		translate([u_start - 1, d_hinge - cam_r - 2, z_c - cam_half_h]) {
			cube([pin_len + 3, 2 * cam_r + 4, 2 * cam_half_h]);
		}
	}
}

module panel_assy() {
	z_c = panel_h - cam_half_h;
	ch = panel_corner_chamfer;
	mirror_x() {
		difference() {
			union() {
				linear_extrude(height = panel_h) {
					polygon([
						[0, panel_gap],
						[half_c - ch, panel_gap],
						[half_c, panel_gap + ch],
						[half_c, d_panel_end - ch],
						[half_c - ch, d_panel_end],
						[0, d_panel_end]
					]);
				}
				for (u0 = [k_p1, k_p2]) {
					knuckle_bar(u0, k_panel, panel_knuckle_r, d_panel_end - 2, 0, z_c, panel_h);
					cam_trunnion(u0, -1);
					cam_trunnion(u0 + k_panel, 1);
				}
			}
			// Finger-lift bevel at outer end
			translate([0, d_fsr + (fsr_head - lift_len) / 2, 0]) {
				rotate([-90, 0, 0]) {
					linear_extrude(height = lift_len) {
						polygon([
							[half_c - lift_bevel, 1],
							[half_c + 1, 1],
							[half_c + 1, -lift_bevel - 1]
						]);
					}
				}
			}
		}
	}
}

module full_arrow_panel(open_deg = 0) {
	translate([0, d_hinge, z_hinge]) {
		rotate([-open_deg, 0, 0]) {
			translate([0, -d_hinge, -(panel_h - cam_half_h)]) {
				panel_assy();
			}
		}
	}
}

module assembly() {
	for (ang = [0, 90, 180, 270]) {
		rotate([0, 0, ang]) {
			quadrant();
			for (s = [[key_r_inner, boss_top_z], [key_r_outer, base_h]]) {
				translate([0, s[0], s[1] - key_slot_depth]) {
					butterfly_key();
				}
			}
			translate([0, half_c, 0]) {
				full_arrow_panel(ang == 270 ? open_east_deg : 0);
			}
		}
	}
}

if (part == "quadrant") {
	quadrant();
} else if (part == "panel") {
	rotate([0, 0, panel_print_deg]) {
		translate([0, -(panel_gap + d_outer) / 2, panel_h]) {
			rotate([0, 180, 0]) {
				panel_assy();
			}
		}
	}
} else if (part == "butterfly_key") {
	butterfly_key();
} else {
	assembly();
}
