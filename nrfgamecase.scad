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
case_bottom_height = 4.4;
case_bottom_overheight = 1.6;
case_bottom_thickness = .8;
case_bottom_support_width = 7.35;
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

module case_bottom() {
  difference() {
    // case exterior
    hull() {
      for(x=[-case_edge_margin, pcb_length + case_edge_margin],
          y=[-case_edge_margin, pcb_width + case_edge_margin])
      translate([x, y, 0])
      {
        h = case_bottom_overheight - case_edge_thickness;
        translate([0, 0, -h])
        cylinder(r=case_edge_thickness, h=h, $fn=16);

        translate([0, 0, -(case_bottom_height - case_edge_thickness)])
        sphere(r=case_edge_thickness, $fn=16);
      }
    }

    // case inner space
    difference() {
      translate([-case_edge_margin, -case_edge_margin, -case_bottom_height + case_bottom_thickness - epsilon])
      cube([case_bottom_inner_length, case_bottom_inner_width, case_bottom_height]);

      // board supports
      for(x=[-case_edge_margin, pcb_length + case_edge_margin],
          y=[-case_edge_margin, pcb_width + case_edge_margin])
      {
        translate([x, y, -case_bottom_height])
        cylinder(
          r = case_bottom_support_width,
          h = case_bottom_height - pcb_thickness
        );
      }
    }

    // battery holder cutout
    translate(battery_holder_pos)
    {
      translate([
        -holder_cube_length / 2 - battery_holder_case_cutout_margin,
        -holder_cube_width / 2 - battery_holder_case_cutout_margin,
        -holder_cube_height
      ])
      cube([
        holder_cube_length + battery_holder_case_cutout_margin * 2,
        holder_cube_width + battery_holder_case_cutout_margin * 2,
        holder_cube_height
      ]);

      translate([
        0,
        holder_total_width - holder_cube_width / 2 - holder_cylinder_diameter / 2,
        -holder_cylinder_thickness
      ])
      cylinder(
        d=holder_cylinder_diameter + battery_holder_case_cutout_margin * 2,
        h=holder_cylinder_thickness,
        $fn=32
      );
    }

    // screw holes
    translate([0, 0, -case_bottom_height - epsilon])
    for(x=[pcb_mounting_hole_offset, pcb_length - pcb_mounting_hole_offset],
        y=[pcb_mounting_hole_offset, pcb_width - pcb_mounting_hole_offset])
    {
      translate([x, y, 0]) {
        cylinder(h=case_bottom_height, d=screw_hole_diameter);
        cylinder(h=screw_head_thickness, d=screw_head_diameter);
      }
    }
  }
}


%#translate([0, 0, -pcb_thickness])
board();

case_bottom();
