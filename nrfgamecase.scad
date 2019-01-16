$fn = 16;
epsilon = 0.01;

module roundcube(size, radius, top_radius=-1, top=false, bottom=false, $fn=8) {
  bottom_radius = radius;
  real_top_radius = top_radius < 0 ? radius : top_radius;
  hull() {
    for(x=[radius, size.x - radius],
        y=[radius, size.y - radius])
    translate([x, y, 0])
    {
      translate([0, 0, bottom ? radius : 0])
      cylinder(r1=bottom_radius, r2=real_top_radius, h=size.z - (top ? real_top_radius : 0) - (bottom ? bottom_radius : 0));

      if (bottom) {
        translate([0, 0, bottom_radius])
        sphere(r=bottom_radius);
      }
      
      if (top) {
        translate([0, 0, size.z - real_top_radius])
        sphere(r=real_top_radius);
      }
    }
  }
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

      *color("silver")
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
pin_height = 3;

module pin() {
  cylinder(d=pin_diameter, h=pin_height);
}

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
  pin();

  translate([0, 8 * pcb_pad_pitch, -pin_height])
  pin();
}

module battery_holder_cutout() {
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

button_body_length = 5;
button_body_width = 3;
button_body_height = 3.3;
button_interpin = 3 * pcb_pad_pitch;

module button() {
  color("white")
  translate([-button_body_length / 2, -button_body_width / 2, 0]) {
    cube([button_body_length, button_body_width, button_body_height]);

    translate([button_body_length / 4, button_body_width / 3, 0])
    cube([button_body_length / 2, button_body_width / 3, button_body_height * 1.4]);
  }
  
  translate([-button_interpin / 2, -pin_diameter / 2, 0]) {
    cube([button_interpin, pin_diameter, pin_diameter]);
  }

  translate([-button_interpin / 2, 0, -pin_height + pcb_thickness / 2]) {
    pin();

    translate([button_interpin, 0, 0])
    pin();
  }
}

function pcb_pos(x, y) = [ pcb_pad_start_x + (x - 1) * pcb_pad_pitch, pcb_pad_start_y + (y - 1) * pcb_pad_pitch ];

battery_holder_pos = pcb_pos(13, 17);

button_down_pos = pcb_pos(2, 3) + [button_interpin / 2, 0, 0];
button_up_pos = pcb_pos(2, 8) + [button_interpin / 2, 0, 0];
button_left_pos = pcb_pos(1, 4) + [0, button_interpin / 2, 0];
button_right_pos = pcb_pos(6, 4) + [0, button_interpin / 2, 0];

button_a_pos = pcb_pos(19, 4) + [button_interpin / 2, 0, 0];
button_b_pos = pcb_pos(21, 6) + [button_interpin / 2, 0, 0];

module board() {
  pcb();

  // battery holder
  translate(battery_holder_pos)
  rotate([0, 180, 180])
  battery_holder();

  // buttons
  translate([0, 0, pcb_thickness]) {
    for (pos=[button_down_pos, button_up_pos, button_a_pos, button_b_pos])
      translate(pos)
      button();

    for (pos=[button_left_pos, button_right_pos])
      translate(pos)
      rotate([0, 0, 90])
      button();
  }
}

case_edge_thickness = 1.05; // actual 1.2
case_edge_margin = 0.5;
case_height = 11;
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
screw_length = 6;
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

    translate([epsilon-case_edge_margin, epsilon-case_edge_margin, case_bottom_support_height + epsilon])
    cube([
      case_bottom_inner_length - 2 * epsilon,
      case_bottom_inner_width - 2 * epsilon,
      case_height - 2 * case_bottom_thickness
    ]);

  }
}

dpad_pos = (button_left_pos + button_right_pos + button_up_pos + button_down_pos) / 4;
dpad_arm_width = (button_right_pos.x - button_left_pos.x) / 2;
dpad_length = dpad_arm_width * 3;
dpad_margin = 0.5;

module full_case() {
  difference() {
    // case exterior
    translate([-case_edge_margin - case_edge_thickness, -case_edge_margin - case_edge_thickness, 0])
    roundcube(
      [
        pcb_length + 2 * (case_edge_margin + case_edge_thickness),
        pcb_width + 2 * (case_edge_margin + case_edge_thickness),
        case_height
      ],
      radius=case_edge_thickness, top=true, bottom=true, $fn=16
    );
    
    // case inner space
    union() {
      difference() {
        translate([-case_edge_margin, -case_edge_margin, case_bottom_thickness])
        cube([case_bottom_inner_length, case_bottom_inner_width, case_height - 2 * case_bottom_thickness]);

        // board supports
        for(x=[-case_edge_margin, pcb_length + case_edge_margin],
            y=[-case_edge_margin, pcb_width + case_edge_margin])
        {
          translate([x, y, 0])
          cylinder(
            r = case_bottom_support_width,
            h = case_height
          );
        }
      }

      // board space (top/bottom support distance)
      translate([-case_edge_margin, -case_edge_margin, case_bottom_support_height])
      cube([pcb_length + 2 * case_edge_margin, pcb_width + 2 * case_edge_margin, pcb_thickness]);
    }

    // battery holder cutout
    translate(battery_holder_pos)
    rotate([0, 0, 180])
    battery_holder_cutout();
    
    // dpad cutout
    dpad_cutout();
    
    // button cutouts
    button_cutouts();
    
    // screen cutout
    screen_length = 9 * pcb_pad_pitch;
    screen_width = 5 * pcb_pad_pitch;
    screen_roundness = 0.5;
    translate([0, 0, case_height - case_bottom_thickness - epsilon])
    translate(pcb_pos(8, 11.5))
    roundcube([screen_length, screen_width, case_bottom_thickness + epsilon], radius=0, top_radius=screen_roundness);
    
    // switch cutout
    translate([0, 0, case_height - case_bottom_thickness - epsilon])
    translate(pcb_pos(0.5, 15))
    roundcube([pcb_pad_pitch, 2 * pcb_pad_pitch, 2 * case_bottom_thickness], screen_roundness);    

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

dpad_lip_thickness = 0.4;
dpad_lip_width = 1.5;
dpad_thickness = 3;
dpad_roundness = .8;

module dpad() {
  color("red")
  translate(dpad_pos)
  difference() {
    union() {
      translate([-dpad_length / 2 - dpad_lip_width, -dpad_arm_width / 2 - dpad_lip_width, 0])
      roundcube([dpad_length + dpad_lip_width * 2, dpad_arm_width + dpad_lip_width * 2, dpad_lip_thickness], dpad_roundness);

      translate([-dpad_length / 2, -dpad_arm_width / 2, 0])
      roundcube([dpad_length, dpad_arm_width, dpad_thickness], dpad_roundness, top=true);

      translate([-dpad_arm_width / 2 - dpad_lip_width, -dpad_length / 2 - dpad_lip_width, 0])
      roundcube([dpad_arm_width + dpad_lip_width * 2, dpad_length + dpad_lip_width * 2, dpad_lip_thickness], dpad_roundness);

      translate([-dpad_arm_width / 2, -dpad_length / 2, 0])
      roundcube([dpad_arm_width, dpad_length, dpad_thickness], dpad_roundness, top=true);
    }
    
    translate([0, 0, dpad_thickness + dpad_arm_width * .9])
    sphere(d = 2*dpad_arm_width);
  }
}

module dpad_cutout() {
  translate([0, 0, case_height - case_bottom_thickness - epsilon])
  translate(dpad_pos) {
    translate([-dpad_length / 2 - dpad_margin, -dpad_arm_width / 2 - dpad_margin, 0])
    roundcube([dpad_length + 2 * dpad_margin, dpad_arm_width + 2 * dpad_margin, 2 * case_bottom_thickness], dpad_roundness);

    translate([-dpad_arm_width / 2 - dpad_margin, -dpad_length / 2 - dpad_margin, 0])
    roundcube([dpad_arm_width + 2 * dpad_margin, dpad_length + 2 * dpad_margin, 2 * case_bottom_thickness], dpad_roundness);
  }
}

button_cover_margin = 0.3;
button_cover_diameter = 4;
button_cover_lip_width = dpad_lip_width;
button_cover_thickness = dpad_thickness;
button_cover_lip_thickness = dpad_lip_thickness;
button_cover_sphere_diameter = 10;

module button_covers() {
  color("red")
  for(pos=[button_a_pos, button_b_pos])
    translate(pos)
    button_cover();
}

module button_cover() {
  cylinder(d=button_cover_diameter + 2 * button_cover_lip_width, h=button_cover_lip_thickness);
  intersection() {
    cylinder(d=button_cover_diameter, h=dpad_thickness);
    
    translate([0, 0, button_cover_thickness - button_cover_sphere_diameter / 2])
    sphere(d=button_cover_sphere_diameter, $fn=64);
  }
}

module button_cutouts() {
  for(pos=[button_a_pos, button_b_pos]) {
    translate(pos)
    translate([0, 0, case_height - case_bottom_thickness - epsilon])
    cylinder(d=button_cover_diameter + 2 * button_cover_margin, h=2 * case_bottom_thickness);
  }
}

module cutout(enable=false) {
  if (enable) {
    intersection() {
      union() {
        children();
      }
      rotate([0, 0, 60])
      translate([0, 0, -10])
      cube([90,150,100], center=true);
    }
  } else {
    children();
  }
}

module assembly(open=0, cut=false) {
  cutout(cut) {

    //%#!
    *translate([0, 0, case_bottom_support_height])
    board();

    //translate([0, pcb_width * 1.2, 0])
    case_bottom();

    translate([0, 0, open])
    union() {
      case_top();
      translate([0, 0, case_height - case_bottom_thickness - button_cover_lip_thickness - .1]) {
        dpad();
        button_covers();
      }
    }

    *translate([0, 0, case_height])
    mirror([0, 0, 1])
    case_top();

    *full_case();
  }
}

module platter() {
  case_bottom();
  
  translate([-10, 0, case_height])
  rotate([0, 180, 0])
  case_top();
  
  translate([0, pcb_width * 1.2, 0]) {
    dpad();
    button_covers();
  }
}

part = "none";

if (part == "dpad") {
  dpad();
} else if (part == "button") {
  button_cover();
} else if (part == "bottom") {
  case_bottom();
} else if (part == "top") {
  translate([-10, 0, case_height])
  rotate([180, 0, 0])
  case_top();
} else {
  *assembly(open=5, cut=false);
  *platter();
  *projection() { case_top(); }
  case_top();
}
// 1:1 distance = 330
