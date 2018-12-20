$fn = 16;

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

    hole_diameter = 2.5;
    hole_offset = 1 + hole_diameter / 2;
    for(x=[hole_offset, pcb_length - hole_offset])
      for(y=[hole_offset, pcb_width - hole_offset])
        translate([x, y, -1])
        cylinder(d=hole_diameter, h=10);
  }

}

pin_diameter = 0.8;
pin_height = 6;

module battery_holder() {
  holder_cube_length = 7.3;
  holder_cube_width = 3.3;
  holder_cube_height = 9;
  holder_cylinder_diameter = 22.2;
  holder_cylinder_thickness = 7.9 - pcb_thickness;
  holder_total_width = 24.3;
  holder_wall_thickness = 1;
  $fn = 32;

  difference() {
    hull() {
      translate([-holder_cube_length / 2, -holder_cube_width / 2, 0])
      cube([holder_cube_length, holder_cube_width, holder_cube_height]);

      translate([0, holder_total_width - holder_cube_width / 2 - holder_cylinder_diameter / 2, 0])
      cylinder(d=holder_cylinder_diameter, h=holder_cylinder_thickness);
    }

    translate([0, holder_total_width - holder_cube_width / 2 - holder_cylinder_diameter / 2, holder_wall_thickness])
    cylinder(d=holder_cylinder_diameter - 2 * holder_wall_thickness, h=2 * holder_cylinder_thickness);

    translate([-holder_cube_length / 2 + holder_wall_thickness, -holder_cube_width / 2 + holder_wall_thickness, holder_wall_thickness])
    cube([holder_cube_length - 2 * holder_wall_thickness, holder_cube_width, 2 * holder_cube_height]);

    holder_cutout_diameter = 30;
    holder_cutout_depth = 3;
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

module board() {
  pcb();

  translate([pcb_pad_start_x + 12 * pcb_pad_pitch, pcb_pad_start_y + 1 * pcb_pad_pitch, 0])
  rotate([0, 180, 0])
  battery_holder();
}

board();
