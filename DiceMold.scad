// name of the die; d10, d20, etc
die_name = 10;
text_font = "DejaVu Sans:style=Bold";
text_depth = 1;
text_size = 4;


// Whether or not to generate the shell
create_shell = true;
// Whether or not to generate the bottom
create_base = true;

// Height of bottom mold
base_h = 1.6;
// Radius of the mold
radius = 20;

// Height of the pedestal
ped_height = 4.5;
// Ratio by which to taper the pedestal
ped_ratio = 0.875;
// Offset from edge of die to the pedestal
ped_off = 1.0;

// Height of the lip
lip_height = 3;
// Lip wall thickness
lip_wall = 0.20;
// Ratio of lip height to width
lip_ratio =  0.875;

// Height of the outer shell
shell_height = 75;
// Wall width of the outer shell
shell_width = 1;
// Tolerance of shell to inner
shell_off = 0.4;
// Inner radius of the shell
shell_rad = radius + shell_off;

// How many sides the circles have
circle_prec = 64;
$fn=circle_prec;
// Begin list of die parameters
// - First = rough size of face      -Second = number of sides.     -third = scale on X (used on D10 and D100)
d20 = [11.50,3,1];
d12 = [12.50,5,1];
d100 =[13.20,3,0.8];
d10 = [13.20,3,0.8];
// Ratio of main triangle to secondary on D10/D100
d10ratio = 0.25;
d8 =  [17.15,3,1];
d6 =  [17.15,4,1];
d4 =  [19.70,3,1];

// TODO: Size of pedestal

function size_info(die_name) = 
die_name == 20 ? d20:
die_name == 12 ? d12:
die_name ==100 ? d100:
die_name == 10 ? d10:
die_name ==  8 ? d8:
die_name ==  6 ? d6:
die_name ==  4 ? d4: 
[0,0,0];

size = size_info(die_name);


// TODO: Outside part
// Begin generating the inside bottom mold
if (create_base) {
    inside_bot();
}
if (create_shell) {
    shell();
}
module inside_bot() {
      
    difference() {
        linear_extrude(height=base_h+lip_height)
        profile(radius);
        lip();
    } 
    
    
    // Finally, apply the pedestal
    pedestal();
    
    // Put some text on!
    make_text();
}

module lip() {
//    rotate_extrude()
//    translate([radius - lip_width,base_h,0])
//
//    polygon(points=[[0,0],[lip_width,0],[lip_width,lip_height]]);
    hgt = lip_height + 0.01;
    translate([0,0,base_h+hgt])
    rotate([0,180,180])
    linear_extrude(
    height=hgt, 
    scale=[lip_ratio,lip_ratio],
    slices=1, 
    twist=0)
    profile(radius-lip_wall);
}


module profile(rad) {
    // Width of the point (triangle)
    point_wid = rad / 3;
    // Amount by which to stretch the point
    point_stretch = 1.9125;

    scale([1,point_stretch,1])
    translate([rad,0,0])
    circle(r=point_wid,$fn=3);
    circle(r=rad);
    
}
module pedestal() {
    // rotate point away from the mold point
    deg = size[1] % 2 == 1 
    ? 180 : 45;
    rotate([0,0,deg])
    scale([1,size[2],1])
    translate([0,0,base_h])
    linear_extrude(
    height=ped_height, 
    scale=[ped_ratio,ped_ratio],
    slices=1, 
    twist=0)
    pedestal_profile();
}
module pedestal_profile() {
    is10 = die_name == 10 || die_name == 100;
    rad0 = (size[0] - ped_off) / ped_ratio / 2;
    rad = is10 ? (rad0 + (rad0 * d10ratio)): rad0;
    off = is10 ?(rad + (rad * d10ratio))/2 : 0;

    circle(r=rad, $fn=size[1]);
    // Make the other triangle for d10 and 100
    if(is10) {

        translate([-off,0,0])
        rotate([0,0,180])
        scale([d10ratio,1,1])
        circle(r=rad, $fn=size[1]);
    }
}
module make_text() {
    val = str("d",die_name);
    off = text_size * len(val)/2.5;
    translate([radius* 0.8,off,base_h])
    rotate([0,0,90])
    scale([-1,1,1])

    linear_extrude(height=text_depth)
    text(
        val,
        size=text_size,
        font=text_font
    );
}
module shell() {
    
    linear_extrude(height=shell_height)
    difference(){
        profile(shell_rad + shell_width);

        profile(shell_rad);
    };
}