part = "LCD_PANEL"; // ["MAIN_BODY", "LCD_PANEL", "PANEL_SUPPORT", "LCD_CUTOUT_POSITIVE", "DRIVE_BRACKET_RIGHT", "DRIVE_BRACKET_LEFT"]
overhang_support_width = 0.5;
wall_thickness = 2;

/* [LCD Cutout] */
lcd_cutout_body_z_prop = 3;
lcd_cutout_view_z_prop = 3;
lcd_cutout_body_z = 5.22;
lcd_cutout_body_x = 86;
lcd_cutout_body_y = 56.5;
lcd_cutout_view_x = 73;
lcd_cutout_view_y = 49;
lcd_cutout_view_off_x = 8.5;
lcd_cutout_view_off_y = 4;
lcd_cutout_v_tabs = [
		     [19, 10.2, 2.5, 1.6], //[18.4...
		     [56.5, 10.2, 2.5, 1.6],
		     [2, 4, 3, 1],
		     [41, 4, 3, 1],
		     [79, 4, 3, 1]
		     ];

/* [LCD Panel] */
lcd_panel_width = 125;
lcd_panel_height = 80;
lcd_panel_mount_screw = "num6"; // ["num6", "m4", "m3"]
lcd_panel_mount_screw_offset = 3;
lcd_panel_lcd_body_height = 56.5;
lcd_panel_lcd_body_width = 86;
lcd_cutout_offset = [-10, 0];
display_text = [["   Oreo", "Arial", 6], ["   Mendel90", "Arial", 4], ["       Sturdy", "Arial", 3]];

/* [LCD Support] */
lcd_back_cutout_offset = [-16.5, 0];
lcd_back_cutout_width = 58;
lcd_back_cutout_height = 56;
pi_offset = [-10, 0];

$fn = $preview ? 36 : 360;
$over = 1;

use <unfy_fasteners.scad>

module LCD_Cutout(
		  center = true,
		  body_z_prop = 3,
		  view_z_prop = 3,
		  body_z = 5.22,
		  body_x = 86,
		  body_y = 56.5,
		  view_x = 73,
		  view_y = 49,
		  view_off_x = 8.5,
		  view_off_y = 4,
		  v_tabs = [
			    [19, 10.2, 2.5, 1.6], //[18.4...
			    [56.5, 10.2, 2.5, 1.6],
			    [2, 4, 3, 1],
			    [41, 4, 3, 1],
			    [79, 4, 3, 1]
			    ],
		  ){
  function p(tab) = tab[0];
  function w(tab) = tab[1];
  function l(tab) = tab[2];
  function h(tab) = tab[3];
   
  translate([center ? (-body_x/2) : 0, center ? (body_y/2) : body_y, body_z + body_z_prop]){
    rotate([180, 0, 0]){

      // main body
      cube([body_x, body_y, body_z + body_z_prop]);
   
      // view window
      translate([view_off_x, view_off_y, 0]){
	cube([view_x, view_y, view_z_prop + body_z + body_z_prop]);
      }
   
      // tabs
      for (tab = v_tabs){
	translate([p(tab), -l(tab), 0]){
	  cube([w(tab), body_y + (2*l(tab)), h(tab)+body_z_prop]);
	}
      }

    }
  }
}

module LCD_Panel(
		 width = 125,
		 height = 80,
		 mount_screw = "num6",
		 mount_screw_offset = 3,
		 lcd_body_height = 56.5,
		 lcd_body_width = 86,
		 overhang_support_width = 0.5,
		 lcd_cutout_offset = [-10, 0],
		 panel_thickness = 7,
		 wall_thickness = 2,
		 hooks_right = false,
		 display_text = [[" Raspi", "Arial", 8], ["  3D Printer", "Arial", 4], ["  Controller", "Arial", 4]]
		 ){
      
  module hook(hooks_right = true){
    translate([0, hooks_right ? 0 : 6, 0])
      rotate([0, 0, hooks_right ? 0 : -180]){
      hook_gap_offset = (overhang_support_width > 0) ? -overhang_support_width : 1;
      h_height = panel_thickness + (2*wall_thickness);
      difference(){
	translate([-6, 6, 0]){
	  rotate([90, 0, 0]){
	    linear_extrude(height=6){
	      polygon([[0, 0], [0, panel_thickness], [4, h_height], [wall_thickness + 8, h_height], [wall_thickness + 8, 0]]);
	    }
	  }
	}
	translate([wall_thickness-2, -hook_gap_offset, 0]){
	  cube([4+hook_gap_offset, 6 + (2*hook_gap_offset), panel_thickness + wall_thickness]);              
	}
	translate([wall_thickness-2, 7, panel_thickness+wall_thickness]){
	  rotate([90, 0, 0]){
	    cylinder(d=1, h=8);
	  }
	}
      }
    }
  } //end module hooks
         
  difference(){
    union(){
      //main body
      translate([0, 0, 3.5]){
	cube([width, height, panel_thickness], center=true);
      }

      //hooks
      hook_positions = [
			[(-width/6), (height/2) - 9, 0],
			[(width/6) ,  (height/2) - 9, 0],
			[(-width/6), 3 - (height/2), 0],
			[(width/6) ,  3 - (height/2), 0],
			];
      for (hook_position = hook_positions){
	translate(hook_position){
	  hook(hooks_right = hooks_right);
	}
      }
    }

    //lcd cutout
    translate([lcd_cutout_offset.x, lcd_cutout_offset.y, 1.66]){
      LCD_Cutout(center = true);
    }

    //display text
    spacing = ((width/2)-(lcd_body_width/2)-lcd_cutout_offset.x)/(len(display_text)+1);
    translate([(lcd_body_width/2)+lcd_cutout_offset.x, -height/2, -1]){
      linear_extrude((panel_thickness/2) + 1 ){
	rotate([180, 0, 0]){
	  for (i = [0:len(display_text)-1]){
	    translate([spacing * (i+1), 0, 0]){
	      text(text=display_text[i][0], font=display_text[i][1], size=display_text[i][2], direction="ttb");
	    }
	  }
	}
      }
    }
    
    //mounting screws
    mount_screw_diameter = ufn_csk_head_diameter(mount_screw);
    mount_screw_x = (width/2) - (mount_screw_diameter/2) - mount_screw_offset;
    mount_screw_y = (height/2) - (mount_screw_diameter/2) - mount_screw_offset;
    for (point = [
		  [mount_screw_x, mount_screw_y],
		  [mount_screw_x, -mount_screw_y],
		  [-mount_screw_x, mount_screw_y],
		  [-mount_screw_x, -mount_screw_y]
		  ]){
      translate(point) ufn_csk(screw = mount_screw);
    }
      
  }
}

module Panel_Support(
		     center = true,
		     width = 125,
		     height = 70,
		     mount_screw = "num6",
		     mount_screw_offset = 3,
		     thickness = 2,
		     lcd_back_cutout_offset = [-16.5, 0],
		     lcd_back_cutout_height = 56,
		     lcd_back_cutout_width = 58,
		     post_positions = [3.5, 61.5],
		     post_height = 35,
		     pi_offset = [-10, 0]
		     ){
  shaft_d = ufn_csk_shaft_diameter(mount_screw);
      
  translate([center?(-width/2):0, center?(-height/2):0, 0]){
      
    difference(){
      union(){
	//Main Body
	cube([width, height, thickness]);
               
	//Support Ridges
	ridge_locations = [[width/6, 9, 0], [width/6, height-11, 0]];
	for (ridge_location = ridge_locations){
	  translate(ridge_location){
	    rotate([90, 0, 90]){
	      linear_extrude(2 * width / 3){
		polygon([[0, 0], [0, thickness], [1, 2*thickness], [2, thickness], [2, 0]]);
	      }
	    }
	  }
	}

      }

      //LCD Back Cutout
      translate([(width/2) + lcd_back_cutout_offset.x - (lcd_back_cutout_width/2), (height/2) - (lcd_back_cutout_height/2) + lcd_back_cutout_offset.y, -1]){ // LCD cutout
	cube([lcd_back_cutout_width, lcd_back_cutout_height, thickness+2]);
      }
         
      //Mounting Screws
      mount_screw_diameter = ufn_csk_head_diameter(mount_screw);
      abs_screw_offset = (mount_screw_diameter/2) + mount_screw_offset;
      for (point = [
		    [abs_screw_offset, abs_screw_offset, -1],
		    [abs_screw_offset, height - abs_screw_offset, -1],
		    [width - abs_screw_offset, abs_screw_offset, -1],
		    [width - abs_screw_offset, height - abs_screw_offset, -1]
		    ]){
	translate(point) cylinder(d=ufn_csk_shaft_diameter(mount_screw), h=thickness+2);
      }
         
      //Loops (holes for the hooks to hook into)
      positions = [
		   [(width/3), 3, -1],
		   [(2*(width/3)), 3, -1],
		   [width/3, height-9, -1],
		   [(2*(width/3)), height-9, -1]
		   ];
      for (position = positions){
	translate(position){
	  cube([10, 6, thickness + 2]);
	}
      }
    }

                   
    // Posts
    pi_center = [(width/2) - (85/2) , (height/2) - (56/2)]; //pi is 85x56mm
    translate([pi_center.x + pi_offset.x, pi_center.y + pi_offset.y]){
      post_positions = [[0, 0, 0], [0, 49, 0], [58, 49, 0], [58, 0, 0]];
      for (post_position = post_positions){
	translate(post_position){
	  difference(){
	    cube([7, 7, post_height]);
	    translate([3.5, 3.5, thickness]){
	      linear_extrude(post_height - thickness + 1){
		circle(d=3, $fn=3);
	      }
	    }
	  }
	}
      }
    }

  }
}
   

   
module main_body(
		 width = 130,
		 height = 85,
		 depth = 160,
		 drive_screw_diameter = 3,
		 drive_screw_head_height = 3,
		 drive_screw_head_diameter=7,
		 wall = 2,
		 drive_screwholes = [
				     [35, 3.18, 3], //fdd bottom front left
				     [35, 98.42, 3], //fdd bottom front right
				     [105, 3.18, 3], //fdd bottom back left
				     [105, 98.42, 3], //fdd bottom back right
         
				     [29.52, 3.18, 3], //hdd bottom front left
				     [29.52, 98.42, 3], //hdd bottom front right
				     [61.27, 3.18, 3], //hdd bottom mid left
				     [61.27, 98.42, 3], //hdd bottom mid right
				     [105.72, 3.18, 3], //hdd bottom back left
				     [105.72, 98.42, 3] //hdd bottom back right
      
				     ],
		 drive_hole_support_width = 1.5,
		 drive_hole_support_spacing = 15
		 ){
  drive_width = 101.6;
  drive_height = 25.4;
  drive_depth = 147;
  difference(){
    //main body
    cube([depth, width, height]);
      
    //main opening
    translate([wall, wall, wall]){
      cube([depth - (2*wall), width - (2*wall), height]);
    }
      
    //drive bay (but not supports)
    translate([depth-(drive_depth+wall), (width/2)-(drive_width/2), wall]){
      cube([drive_depth+wall+$over, drive_width, drive_height]);
    }
    translate([depth, (width-drive_width)/2, 0]){
      for(v = drive_screwholes){
	translate([-v.x, v.y, 0]){
	  ufn_csk(screw = "M3", length = wall + (2*$over), head_ext = 1);
	}
      }
    }
  } // end difference
  //drive bay supports
  drive_hole_support_shift = ((drive_hole_support_spacing-(drive_width % drive_hole_support_spacing))/2)+(drive_hole_support_width/2); //prevents last support from intersecting edge
  translate([depth-wall, 0, 0]){
    for (space=[drive_hole_support_spacing:drive_hole_support_spacing:drive_width]){
      y = ((width-drive_width)/2)+space-drive_hole_support_shift;
      translate([0, y, 0]){
	cube([wall, drive_hole_support_width, drive_height + wall + $over]);
      }
    }
  }
}

module drive_bracket(screw="m3", height=10, left=false){
   
}

if (part == "LCD_PANEL"){
  LCD_Panel(
	    width = lcd_panel_width,
	    height = lcd_panel_height,
	    mount_screw = lcd_panel_mount_screw,
	    mount_screw_offset = lcd_panel_mount_screw_offset,
	    lcd_body_height = lcd_panel_lcd_body_height,
	    lcd_body_width = lcd_panel_lcd_body_width,
	    overhang_support_width = overhang_support_width,
	    lcd_cutout_offset = lcd_cutout_offset,
	    wall_thickness = wall_thickness,
	    display_text = display_text
	    );
 }

if (part == "PANEL_SUPPORT"){
  Panel_Support(
		center = true,
		width = lcd_panel_width,
		height = lcd_panel_height,
		mount_screw = lcd_panel_mount_screw,
		mount_screw_offset = lcd_panel_mount_screw_offset,
		thickness = wall_thickness,
		lcd_back_cutout_offset = lcd_back_cutout_offset,
		lcd_back_cutout_height = lcd_back_cutout_height,
		lcd_back_cutout_width = lcd_back_cutout_width,
		pi_offset = pi_offset
		);
 }

if (part == "MAIN_BODY"){
  main_body();
 }

if (part == "LCD_CUTOUT_POSITIVE"){
  LCD_Cutout(
	     center = true,
	     body_z_prop = lcd_cutout_body_z_prop,
	     view_z_prop = lcd_cutout_view_z_prop,
	     body_z = lcd_cutout_body_z,
	     body_x = lcd_cutout_body_x,
	     body_y = lcd_cutout_body_y,
	     view_x = lcd_cutout_view_x,
	     view_y = lcd_cutout_view_y,
	     view_off_x = lcd_cutout_view_off_x,
	     view_off_y = lcd_cutout_view_off_y,
	     v_tabs = lcd_cutout_v_tabs
	     );
 }

if (part == "DRIVE_BRACKET_RIGHT"){
  drive_bracket(screw="m3", left=false);
 }

if (part == "DRIVE_BRACKET_LEFT"){
  drive_bracket(screw="m3", left=true);
 }
