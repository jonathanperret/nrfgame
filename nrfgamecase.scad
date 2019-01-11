$fn = 16;
epsilon = 0.01;

module board() {
}

pcb_length = 70.1;
pcb_width = 50.2;
pcb_thickness = 1.6;
pcb_pad_pitch = 2.54;
pcb_pad_diameter = 2;
pcb_pad_hole_diameter = 1;
pcb_pad_count_x = 24;
pcb_pad_count_y = 18;
pcb_pad_start_x = (pcb_length - (pcb_pad_count_x - 1) * pcb_pad_pitch) / 2;
pcb_pad_start_y = (pcb_width - (pcb_pad_count_y - 1) * pcb_pad_pitch) / 2;
pcb_mounting_hole_diameter = 2.5;
pcb_mounting_hole_offset = 2;

module pcb() {
  difference() {
    union() {
      color("green")
      cube([pcb_length, pcb_width, pcb_thickness]);

      color("silver")
      for(x=[pcb_pad_start_x:pcb_pad_pitch:pcb_pad_start_x + pcb_pad_count_x * pcb_pad_pitch - .1])
        translate([x, 0, 0])
        for(y=[pcb_pad_start_y:pcb_pad_pitch:pcb_pad_start_y + pcb_pad_count_y * pcb_pad_pitch - .1])
          translate([0, y, -.1])
          cylinder(d=pcb_pad_diameter, h=pcb_thickness+.2);
    }

    for(x=[pcb_mounting_hole_offset, pcb_length - pcb_mounting_hole_offset])
      for(y=[pcb_mounting_hole_offset, pcb_width - pcb_mounting_hole_offset])
        translate([x, y, -1])
        cylinder(d=pcb_mounting_hole_diameter, h=10);
  }

}

pin_diameter = 0.8;
pin_height = 6;

holder_cube_length = 7.3;
holder_cube_width = 3.3;
holder_cube_height = 9;
holder_cylinder_diameter = 22.2;
holder_cylinder_thickness = 10.6 - pcb_thickness;
holder_total_width = 24.3;
holder_wall_thickness = 1;

module battery_holder() {
  $fn = 32;

  difference() {
    union() {
      translate([-holder_cube_length / 2, -holder_cube_width / 2, 0])
      cube([holder_cube_length, holder_cube_width, holder_cube_height]);

      translate([0, holder_total_width - holder_cube_width / 2 - holder_cylinder_diameter / 2, 0])
      cylinder(d=holder_cylinder_diameter, h=holder_cylinder_thickness);
    }

    translate([0, holder_total_width - holder_cube_width / 2 - holder_cylinder_diameter / 2, holder_wall_thickness])
    cylinder(d=holder_cylinder_diameter - 2 * holder_wall_thickness, h=2 * holder_cylinder_thickness);

    translate([-holder_cube_length / 2 + holder_wall_thickness, -holder_cube_width / 2 + holder_wall_thickness, holder_wall_thickness])
    cube([holder_cube_length - 2 * holder_wall_thickness, holder_cube_width, 2 * holder_cube_height]);

    holder_cutout_diameter = 43;
    holder_cutout_depth = 5;
    translate([0, holder_total_width - holder_cube_width / 2 - battery_diameter / 2, holder_cylinder_thickness + holder_cutout_diameter / 2 - holder_cutout_depth])
    rotate([22.5, 0, 0])
    rotate([0, 90, 0])
    cylinder(d=holder_cutout_diameter, h=50, center=true, $fn=8);
  }

  battery_diameter = 20;
  battery_thickness = 3.2;
  color("silver")
  translate([0, holder_total_width - holder_cube_width / 2 - holder_cylinder_diameter / 2, holder_cylinder_thickness - battery_thickness - holder_wall_thickness])
  cylinder(d=.99*battery_diameter, h=battery_thickness, $fn=64);

  // pins
  translate([0, 0, -pin_height])
  cylinder(d=pin_diameter, h=pin_height);
  translate([0, 8 * pcb_pad_pitch, -pin_height])
  cylinder(d=pin_diameter, h=pin_height);
}

battery_holder_pos = [pcb_pad_start_x + 11 * pcb_pad_pitch, pcb_pad_start_y + 1 * pcb_pad_pitch, 0];

module board() {
  pcb();

  translate(battery_holder_pos)
  rotate([0, 180, 0])
  battery_holder();
}

case_edge_thickness = 1.05; // actual 1.2
case_edge_margin = 0.5;
case_height = 10;
case_bottom_height = 5.4;
case_bottom_thickness = .8;
case_bottom_support_width = 7.35;
case_bottom_support_height = 3.2;
case_bottom_inner_length = pcb_length + 2 * case_edge_margin;
case_bottom_inner_width = pcb_width + 2 * case_edge_margin;

echo("expected case outer width", case_bottom_inner_width + 2 * case_edge_thickness);
echo("expected case outer length", case_bottom_inner_length + 2 * case_edge_thickness);
echo("expected case inner width", case_bottom_inner_width);
echo("expected case inner length", case_bottom_inner_length);

battery_holder_case_cutout_margin = 0.7;

screw_hole_diameter = 2.4;
screw_head_diameter = 6;
screw_head_thickness = 1.5;
screw_length = 5;
screw_bottom_case_thickness = 0.8;

module case_bottom() {
  intersection() {
    full_case();
    case_bottom_cutter();
  }
}

module case_top() {
  difference() {
    full_case();
    case_bottom_cutter();
  }
}

module x_hex(bottom_width, length) {
  radius = bottom_width * 2;
  scale([1, radius, radius])
  translate([0, 0, sqrt(3)/4])
  rotate([-90, 0, -90])
  cylinder($fn = 6, d=1, h=length);
}

module y_hex(bottom_width, length) {
  rotate([0, 0, 90])
  x_hex(bottom_width, length);
}

module case_bottom_cutter() {
  overlap_thickness = 1.5;
  overlap_length = 10;
  difference() {
    translate([-50, -50, 0])
    cube([150, 150, case_bottom_height + overlap_thickness]);

    translate([case_bottom_inner_length / 2, -50, case_bottom_height])
    y_hex(bottom_width=pcb_length - overlap_length * 2, length=150);

    translate([-50, case_bottom_inner_width / 2, case_bottom_height])
    x_hex(bottom_width=pcb_width - overlap_length * 2, length=150);
  }
}

module full_case() {
  difference() {
    // case exterior
    hull() {
      for(x=[-case_edge_margin, pcb_length + case_edge_margin],
          y=[-case_edge_margin, pcb_width + case_edge_margin])
      translate([x, y, case_edge_thickness])
      {
        cylinder(r=case_edge_thickness, h=case_height - case_edge_thickness, $fn=16);

        for (z=[0, case_height - case_edge_thickness])
          translate([0, 0, z])
          sphere(r=case_edge_thickness, $fn=16);
      }
    }

    // case inner space
    difference() {
      translate([-case_edge_margin, -case_edge_margin, case_bottom_thickness])
      cube([case_bottom_inner_length, case_bottom_inner_width, case_height]);

      // board supports
      for(x=[-case_edge_margin, pcb_length + case_edge_margin],
          y=[-case_edge_margin, pcb_width + case_edge_margin])
      {
        translate([x, y, 0])
        cylinder(
          r = case_bottom_support_width,
          h = case_bottom_support_height
        );
      }
    }

    // battery holder cutout
    translate(battery_holder_pos)
    {
      translate([
        -holder_cube_length / 2 - battery_holder_case_cutout_margin,
        -holder_cube_width / 2 - battery_holder_case_cutout_margin,
        -epsilon
      ])
      cube([
        holder_cube_length + battery_holder_case_cutout_margin * 2,
        holder_cube_width + battery_holder_case_cutout_margin * 2,
        2 * case_bottom_thickness
      ]);

      translate([
        0,
        holder_total_width - holder_cube_width / 2 - holder_cylinder_diameter / 2,
        -epsilon
      ])
      cylinder(
        d=holder_cylinder_diameter + battery_holder_case_cutout_margin * 2,
        h=2 * case_bottom_thickness,
        $fn=32
      );
    }

    // screw holes
    translate([0, 0, -epsilon])
    for(x=[pcb_mounting_hole_offset, pcb_length - pcb_mounting_hole_offset],
        y=[pcb_mounting_hole_offset, pcb_width - pcb_mounting_hole_offset])
    {
      translate([x, y, 0]) {
        translate([0, 0, case_bottom_support_height - screw_bottom_case_thickness - epsilon])
          cylinder(h=screw_length, d=screw_hole_diameter);

        cylinder(h=case_bottom_support_height - screw_bottom_case_thickness, d=screw_head_diameter);
      }
    }
  }
}


%#translate([0, 0, case_bottom_support_height])
board();

!case_bottom();

translate([0, 0, 30])
case_top();