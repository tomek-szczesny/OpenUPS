/*
    OpenUPS Case Copyright 2023 Edward A. Kisiel hominoid@cablemi.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    Code released under GPLv3: http://www.gnu.org/licenses/gpl.html

    202304xx version 0.9 OpenUPS Case
    
    hdd35_ups_top(length=147, width=101.6, top_height)    
    hdd35_ups_bottom(length=147,width=101.6, bottom_height)
    ups_pcb(pcbsize, pcb_position)
    bat_pcb(batpcbsize, batpcb_position)
    battery_placement(bat_layout, bat_num, bat_space, bat_type, bat_dia, bat_len)
    battery_clip(bat_dia = 18.4)
    led(ledcolor = "red")
    battery(type)
    jst_xh(num_pin)
    jst_sh(num_pin)
    standoff(standoff[radius,height,holesize,supportsize,supportheight,sink,style,i_dia,i_depth])
    slab(size, radius)
    slot(hole,length,depth)
    fan_mask(size, thick, style)
    heatsink(type,soc1size_z)
    
*/

use <./lib/fillets.scad>;

case_style = "drivebay";        //"drivebay", "standalone"
heatsink_type = "c4_oem";       // "c4_oem", "xu4_oem"

pcb_enable = true;
top_enable = true;
label_enable = true;

// pcb size and placement
pcbsize = [90, 62, 1.6];
pcb_position = [0, 0, 6];
batpcbsize = [90, 82, 1.6];
batpcb_position = [0, 63, 1];
pcb_color = "#008066";

// batteries layout and configuration
bat_num = 3;
bat_type = "21700";           // "18650", "18650_convex", "21700"
bat_layout = "3S_staggered";  // "straight", "staggered", "3S2P_staggered", "3S_staggered"
bat_space = 3;

bat_dia = bat_type=="21700" ? 21 : 18.4;
bat_len = bat_type=="21700" ? 70 : 65;

adj = .01;
$fn = 90;

if(case_style == "drivebay") {
    length = 147;
    width = 101.6;
    top_height = 14;
    bottom_height = 12;
    height = top_height+bottom_height;
    top_standoff = [7,25,3.5,10,4,1,0,1,0,4.5,5];
    bottom_standoff = [7,10,3.5,10,4,4,1,0,1,4.5,5];
    pcb_standoff = [7,pcb_position[2],3.5,10,4,1,1,0,0,0,0];
    support_standoff = [7,10,3.5,15,3,4,1,0,0,0,0];

    if(pcb_enable) {
        ups_pcb(pcbsize, pcb_position);
        bat_pcb(batpcbsize, batpcb_position);
        translate([batpcb_position[0]+4, batpcb_position[1]+6, batpcb_position[2]+batpcbsize[2]]) 
            battery_placement(bat_layout, bat_num, bat_space, bat_type, bat_dia, bat_len);
    }
    difference() {
        color("dimgrey") translate([-6,length,0]) rotate([0,0,270]) hdd35_ups_bottom(length, width, bottom_height);
        color("dimgrey") translate([pcb_position[0],adj+pcb_position[1]+(147-length)/2,pcb_position[2]]) 
            slab([pcbsize[0],pcbsize[1],20], 3);
        color("dimgrey") translate([batpcb_position[0],adj+batpcb_position[1]+(147-length)/2,batpcb_position[2]]) 
            slab([batpcbsize[0],batpcbsize[1],20], 3);
        
        // ups psb standoff holes
        color("dimgrey") translate([pcb_position[0]+4, pcb_position[1]+13, -1]) 
            cylinder(d=6.5, h=4);
        color("dimgrey") translate([pcb_position[0]+4, pcb_position[1]+pcbsize[1]-4, -1]) 
            cylinder(d=6.5, h=4);
        color("dimgrey") translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+pcbsize[1]-4, -1]) 
            cylinder(d=6.5, h=4);
        color("dimgrey") translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, -1]) 
            cylinder(d=6.5, h=4);
        
        // battery psb holes
        color("dimgrey") translate([batpcb_position[0]+4, batpcb_position[1]+4, -1]) 
            cylinder(d=3.5, h=4);
        color("dimgrey") translate([batpcb_position[0]+4, batpcb_position[1]+batpcbsize[1]-4, -1]) 
            cylinder(d=3.5, h=4);
        color("dimgrey") translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+batpcbsize[1]-4, -1]) 
            cylinder(d=3.5, h=4);
        color("dimgrey") translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+4, -1]) 
            cylinder(d=3.5, h=4);
            
        // power plug
        color("dimgrey") translate([77,-1, pcb_position[2]]) cube([10.5,14,9.5+pcbsize[2]]);
        // terminal blocks
        color("dimgrey") translate([26,-1, pcb_position[2]]) cube([34,10,10+pcbsize[2]]);
        // sata1 & sata2
        color("dimgrey") translate([2.5,-1, pcb_position[2]]) cube([23.5,10,6+pcbsize[2]]);
        // fan1 & fan2
        color("dimgrey") translate([59,-1, pcb_position[2]]) cube([18.5,10,7+pcbsize[2]]);
        // i2c
        color("dimgrey") translate([61,-1,pcb_position[2]-2*pcbsize[2]]) cube([5.25,10,4]);
        color("dimgrey") translate([70,-1,pcb_position[2]-2*pcbsize[2]]) cube([5.25,10,4]);

    }
    // ups standoffs
    color("dimgrey") translate([pcb_position[0]+4, pcb_position[1]+13, 0]) standoff(pcb_standoff);
    color("dimgrey") translate([pcb_position[0]+4, pcb_position[1]+pcbsize[1]-4, 0]) standoff(pcb_standoff);
    color("dimgrey") translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+pcbsize[1]-4, 0]) standoff(pcb_standoff);
    color("dimgrey") translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, 0]) standoff(pcb_standoff);
    
    // top
    if(top_enable) {
        difference() {
            color("dimgrey") translate([-6, 147-length, top_height+bottom_height]) rotate([0,180,270]) 
                hdd35_ups_top(length, width, top_height);
            // ups psb standoff holes
//            color("dimgrey") translate([pcb_position[0]+4, pcb_position[1]+13, height-3]) cylinder(d=6.5, h=4);
//            color("dimgrey") translate([pcb_position[0]+4, pcb_position[1]+pcbsize[1]-4, height-3]) cylinder(d=6.5, h=4);
//            color("dimgrey") translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+pcbsize[1]-4, height-3]) 
//                cylinder(d=6.5, h=4);
//            color("dimgrey") translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, height-3]) cylinder(d=6.5, h=4);

            // power plug
            color("dimgrey") translate([77,-1, pcb_position[2]]) cube([10.5,14,9.5+pcbsize[2]]);
            // terminal blocks
            color("dimgrey") translate([26,-1, pcb_position[2]]) cube([34,10,10+pcbsize[2]]);
            color("dimgrey") translate([30,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            color("dimgrey") translate([35,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            color("dimgrey") translate([41,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            color("dimgrey") translate([46,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            color("dimgrey") translate([52,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            color("dimgrey") translate([57,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            if(label_enable) {
                color("black") translate([27.5,0,top_height+bottom_height-4]) rotate([90,0,0]) text("+5V",3);
                color("red") translate([28.5,0,top_height+bottom_height-8]) rotate([90,0,0]) text("+",3);
                color("black") translate([33,0,top_height+bottom_height-8.5]) rotate([90,0,0]) text("-",5);
                color("black") translate([38,0,top_height+bottom_height-4]) rotate([90,0,0]) text("+12V",3);
                color("red") translate([39.5,0,top_height+bottom_height-8]) rotate([90,0,0]) text("+",3);
                color("black") translate([44,0,top_height+bottom_height-8.5]) rotate([90,0,0]) text("-",5);
                color("black") translate([49.5,0,top_height+bottom_height-4]) rotate([90,0,0]) text("+Vin",3);
                color("red") translate([50.5,0,top_height+bottom_height-8]) rotate([90,0,0]) text("+",3);
                color("black") translate([55,0,top_height+bottom_height-8.5]) rotate([90,0,0]) text("-",5);
            }
            // sata1 & sata2
            color("dimgrey") translate([2.5,-1, pcb_position[2]]) cube([23.5,10,6+pcbsize[2]]);
            // fan1 & fan2
            color("dimgrey") translate([59,-1, pcb_position[2]]) cube([18.5,10,7+pcbsize[2]]);
            
        }
    }
}


/* 3.5" hd bay ups holder top*/
module hdd35_ups_top(length=147, width=101.6, top_height) {
    
    wallthick = 2;
    floorthick = 1;
    height = top_height;
    hd35_x = length;                    // 145mm for 3.5" drive
    hd35_y = width;
    adjust = .1;    
    $fn=90;
    
    difference() {
        union() {
            difference() {
                translate([(hd35_x/2),(hd35_y/2),(height/2)])         
                    cube_fillet_inside([hd35_x,hd35_y,height], 
                        vertical=[3,3,3,3], top=[0,0,0,0], bottom=[0,0,0,0], $fn=90);      
                translate([(hd35_x/2),(hd35_y/2),(height/2)+floorthick])           
                    cube_fillet_inside([hd35_x-(wallthick*2),hd35_y-(wallthick*2),height], 
                        vertical=[2,2,2,2], top=[0,0,0,0], bottom=[2,2,2,2], $fn=90);
                if(case_style != "drivebay") {
                    // bottom vents
                    for ( r=[15:40:hd35_x-40]) {
                        for (c=[hd35_y-76:4:75]) {
                            translate ([r,c,-adjust]) cube([35,2,wallthick+(adjust*2)]);
                        }
                    }
                }
                else {
                    // bottom vents
                    for ( r=[60:40:hd35_x-40]) {
                        for (c=[hd35_y-90:4:90]) {
                            translate ([r,c,-adjust]) cube([35,2,wallthick+(adjust*2)]);
                        }
                    }
                    translate([10,-20+width/2,0]) fan_mask(40, 4, 2);
                }
            }
            if(bat_layout == "3S_staggered") {
                translate([length-wallthick,4,17-adjust]) cube([wallthick,94,7+adjust]);
            }
        }
    }
}


/* 3.5" hd bay ups holder */
module hdd35_ups_bottom(length=147,width=101.6, bottom_height) {
    
    wallthick = 3;
    floorthick = 2;
    hd35_x = length;                    // 147mm for 3.5" drive
    hd35_y = width;
    hd35_z = bottom_height;
    adjust = .1;    
    $fn=90;
    
    difference() {
        union() {
            difference() {
                translate([(hd35_x/2),(hd35_y/2),(hd35_z/2)])         
                    cube_fillet_inside([hd35_x,hd35_y,hd35_z], 
                        vertical=[3,3,3,3], top=[0,0,0,0], bottom=[0,0,0,0], $fn=90);      
                translate([(hd35_x/2),(hd35_y/2),(hd35_z/2)+floorthick])           
                    cube_fillet_inside([hd35_x-(wallthick*2),hd35_y-(wallthick*2),hd35_z], 
                        vertical=[2,2,2,2], top=[0,0,0,0], bottom=[2,2,2,2], $fn=90);
                   
                // bottom vents
                for ( r=[15:40:hd35_x-40]) {
                    for (c=[hd35_y-76:4:75]) {
                        translate ([r,c,-adjust]) cube([35,2,wallthick+(adjust*2)]);
                    }
                }       
            }

        // side nut holder support    
        translate([16,wallthick-adjust,7]) rotate([-90,0,0]) cylinder(d=10,h=3);
        translate([76,wallthick-adjust,7]) rotate([-90,0,0])  cylinder(d=10,h=3);
            if(length >= 120) {
                translate([117.5,wallthick-adjust,7]) rotate([-90,0,0])  cylinder(d=10,h=3);
                translate([117.5,hd35_y-wallthick+adjust,7]) rotate([90,0,0])  cylinder(d=10,h=3);
            }
        translate([76,hd35_y-wallthick+adjust,7]) rotate([90,0,0])  cylinder(d=10,h=3);
        translate([16,hd35_y-wallthick+adjust,7]) rotate([90,0,0])  cylinder(d=10,h=3);
        
        // bottom-side support
//        translate([wallthick,wallthick,floorthick-2]) rotate([45,0,0]) cube([hd35_x-(wallthick*2),3,3]);
//        translate([wallthick,hd35_y-wallthick+adjust,floorthick-2]) rotate([45,0,0]) cube([hd35_x-(wallthick*2),3,3]);
         
        }
        // side screw holes
        translate([16,-adjust,7]) rotate([-90,0,0]) cylinder(d=3.6,h=7);
        translate([76,-adjust,7]) rotate([-90,0,0])  cylinder(d=3.6,h=7);
        translate([117.5,-adjust,7]) rotate([-90,0,0])  cylinder(d=3.6,h=7);
        translate([117.5,hd35_y+adjust,7]) rotate([90,0,0])  cylinder(d=3.6,h=7);
        translate([76,hd35_y+adjust,7]) rotate([90,0,0])  cylinder(d=3.6,h=7);
        translate([16,hd35_y+adjust,7]) rotate([90,0,0])  cylinder(d=3.6,h=7);
        
        // side nut trap    
        translate([16,wallthick-adjust,7]) rotate([-90,0,0]) cylinder(r=3.30,h=5,$fn=6);
        translate([76,wallthick-adjust,7]) rotate([-90,0,0])  cylinder(r=3.30,h=5,$fn=6);
        translate([117.5,wallthick-adjust,7]) rotate([-90,0,0])  cylinder(r=3.30,h=5,$fn=6);
        translate([117.5,hd35_y-wallthick-adjust,7]) rotate([90,0,0])  cylinder(r=3.30,h=5,$fn=6);
        translate([76,hd35_y-wallthick-adjust,7]) rotate([90,0,0])  cylinder(r=3.30,h=5,$fn=6);
        translate([16,hd35_y-wallthick-adjust,7]) rotate([90,0,0])  cylinder(r=3.30,h=5,$fn=6);
    }
}


/* open ups pcb */
module ups_pcb(pcbsize, pcb_position) {
    
    adj = .01;
    $fn = 90;

    difference() {
        color(pcb_color) translate(pcb_position) slab(pcbsize, 3);
        color("dimgrey") translate([pcb_position[0]+4, pcb_position[1]+13, pcb_position[2]-1]) 
            cylinder(d=3.5, h=4);
        color("dimgrey") translate([pcb_position[0]+4, pcb_position[1]+pcbsize[1]-4,pcb_position[2]-1]) 
            cylinder(d=3.5, h=4);
        color("dimgrey") translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+pcbsize[1]-4,
            pcb_position[2]-1]) cylinder(d=3.5, h=4);
        color("dimgrey") translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, pcb_position[2]-1]) 
            cylinder(d=3.5, h=4);
        color("dimgrey") translate([pcb_position[0]+20, pcb_position[1]+40, pcb_position[2]-1]) cylinder(d=3.5, h=4);
        color("dimgrey") translate([pcb_position[0]+71, pcb_position[1]+20, pcb_position[2]-1]) cylinder(d=3.5, h=4);
    }
    /// power jack
    color("grey") translate([pcb_position[0]+pcbsize[0]-13, pcb_position[1]+13, pcb_position[2]+pcbsize[2]-3])
        rotate([90, 0, 0]) import("lib/PJ-063AH.stl");
    
    // +vout green terminal block
    color("lightgreen") translate([pcb_position[0]+54, pcb_position[1]+4, pcb_position[2]+pcbsize[2]+3]) 
        rotate([0, 0, 180]) import("lib/691213710002.stl");
    // +12v green terminal block    
    color("lightgreen") translate([pcb_position[0]+43, pcb_position[1]+4, pcb_position[2]+pcbsize[2]+3]) 
        rotate([0, 0, 180]) import("lib/691213710002.stl");
    // +5v green terminal block    
    color("lightgreen") translate([pcb_position[0]+32, pcb_position[1]+4, pcb_position[2]+pcbsize[2]+3]) 
        rotate([0, 0, 180]) import("lib/691213710002.stl");
    
    // sata 1
    translate([pcb_position[0]+3, pcb_position[1]+7, pcb_position[2]+pcbsize[2]]) rotate([90, 0, 0]) jst_xh(4);
    // sata 2
    translate([pcb_position[0]+14.5, pcb_position[1]+7, pcb_position[2]+pcbsize[2]]) rotate([90, 0, 0]) jst_xh(4);
    
    // i2c
    translate([pcb_position[0]+61, pcb_position[1]+4.25, pcb_position[2]+pcbsize[2]-4.5]) 
        rotate([90, 0, 0]) jst_sh(4);
    translate([pcb_position[0]+70, pcb_position[1]+4.25, pcb_position[2]+pcbsize[2]-4.5]) 
        rotate([90, 0, 0]) jst_sh(4);
        
    // fan 1
    translate([pcb_position[0]+pcbsize[0]-17.5, pcb_position[1]+8, pcb_position[2]+pcbsize[2]+3.25]) 
        rotate([180, 0, 0]) import("lib/22053031.stl");
    color("black") translate([pcb_position[0]+pcbsize[0]-21, pcb_position[1]+1, pcb_position[2]+pcbsize[2]]) 
         linear_extrude(height = .5) text("FAN 1", size=2);

    // front fan2
    translate([pcb_position[0]+pcbsize[0]-26.5, pcb_position[1]+8, pcb_position[2]+pcbsize[2]+3.25]) 
        rotate([180, 0, 0]) import("lib/22053031.stl");
    color("black") translate([pcb_position[0]+pcbsize[0]-30, pcb_position[1]+1, pcb_position[2]+pcbsize[2]]) 
         linear_extrude(height = .5) text("FAN 2", size=2);
         
    // front leds
    translate([pcb_position[0]+25, pcb_position[1]+pcbsize[1]-3, pcb_position[2]+pcbsize[2]]) led();
    color("black") translate([pcb_position[0]+28.5, pcb_position[1]+pcbsize[1]-4, pcb_position[2]+pcbsize[2]]) 
        rotate([0, 0, 180]) linear_extrude(height = .5) text("PWR", size=1.25);
    translate([pcb_position[0]+30, pcb_position[1]+pcbsize[1]-3, pcb_position[2]+pcbsize[2]]) led("yellow");
    color("black") translate([pcb_position[0]+33.5, pcb_position[1]+pcbsize[1]-4, pcb_position[2]+pcbsize[2]]) 
        rotate([0, 0, 180]) linear_extrude(height = .5) text("CHR", size=1.25);
    translate([pcb_position[0]+35, pcb_position[1]+pcbsize[1]-3, pcb_position[2]+pcbsize[2]]) led("green");
    color("black") translate([pcb_position[0]+38.5, pcb_position[1]+pcbsize[1]-4, pcb_position[2]+pcbsize[2]]) 
        rotate([0, 0, 180]) linear_extrude(height = .5) text("FULL", size=1.25);
        
    // front usb-c
    translate([pcb_position[0]+54, pcb_position[1]+pcbsize[1]-9.5, pcb_position[2]+pcbsize[2]+2]) 
         import("lib/usb-c.stl");
    // heatsink
    translate([pcb_position[0]+20,pcb_position[1]+40,pcb_position[2]+0]) heatsink(heatsink_type,1.6);


}


/* battery pcb */
module bat_pcb(batpcbsize, batpcb_position) {
    
    adj = .01;
    $fn = 90;

    difference() {
        color(pcb_color) translate(batpcb_position) slab(batpcbsize, 3);
        color("dimgrey") translate([batpcb_position[0]+4, batpcb_position[1]+4, batpcb_position[2]-1]) 
            cylinder(d=3.5, h=4);
        color("dimgrey") translate([batpcb_position[0]+4, batpcb_position[1]+batpcbsize[1]-4, batpcb_position[2]-1]) 
            cylinder(d=3.5, h=4);
        color("dimgrey") translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+batpcbsize[1]-4,
            batpcb_position[2]-1]) cylinder(d=3.5, h=4);
        color("dimgrey") translate([batpcb_position[0]+pcbsize[0]-4, batpcb_position[1]+4, batpcb_position[2]-1]) 
            cylinder(d=3.5, h=4);
    }
}


module battery_placement(bat_layout, bat_num, bat_space, bat_type, bat_dia, bat_len) {

    if(bat_layout == "straight") {
        translate([bat_len, bat_dia/2, .38+(bat_dia/2)]) {
            for( b = [0:1:bat_num-1]) {
                translate([0, b*bat_dia+b*bat_space, 1]) rotate([-90, 0, 90]) battery(bat_type);
                color("dimgrey") translate([-2, b*bat_dia+b*bat_space, 1]) rotate([0, 0, 90]) battery_clip(bat_dia);
                color("dimgrey") translate([-bat_len+2, b*bat_dia+b*bat_space, 1]) rotate([0, 0, 270]) battery_clip(bat_dia);

            }
        }
    }
    if(bat_layout == "staggered") {
        translate([bat_len,bat_dia/2,.38+(bat_dia/2)]) {
            for( b = [0:1:bat_num-1]) {
                if(b == 0 || b == 2 || b == 4) {
                    translate([0,b*bat_dia+b*bat_space,1]) rotate([-90,0,90]) battery(bat_type);
                    color("dimgrey") translate([-2,b*bat_dia+b*bat_space,1]) rotate([0,0,90]) battery_clip(bat_dia);
                    color("dimgrey") translate([-bat_len+2,b*bat_dia+b*bat_space,1]) 
                        rotate([0,0,270]) battery_clip(bat_dia);
                }
                if(b == 1 || b == 3 || b == 5) {
                    translate([16,b*bat_dia+b*bat_space,1]) rotate([-90,0,90]) battery(bat_type);
                    color("dimgrey") translate([14,b*bat_dia+b*bat_space,1]) rotate([0,0,90]) battery_clip(bat_dia);
                    color("dimgrey") translate([-bat_len+18,b*bat_dia+b*bat_space,1]) 
                        rotate([0,0,270]) battery_clip(bat_dia);
                }

            }
        }
    }
    if(bat_layout == "3S2P_staggered") {
        translate([bat_len,bat_dia/2,.38+(bat_dia/2)]) {
            for( b = [0:1:bat_num-1]) {
                if(b == 0 || b == 1 || b == 4 || b == 5) {
                    translate([0,b*bat_dia+b*bat_space,1]) rotate([-90,0,90]) battery(bat_type);
                    color("dimgrey") translate([-2,b*bat_dia+b*bat_space,1]) rotate([0,0,90]) battery_clip(bat_dia);
                    color("dimgrey") translate([-bat_len+2,b*bat_dia+b*bat_space,1]) 
                        rotate([0,0,270]) battery_clip(bat_dia);
                }
                if(b == 2 || b == 3) {
                    translate([16-bat_len,b*bat_dia+b*bat_space,1]) rotate([-90,0,270]) battery(bat_type);
                    color("dimgrey") translate([14,b*bat_dia+b*bat_space,1]) rotate([0,0,90]) battery_clip(bat_dia);
                    color("dimgrey") translate([-bat_len+18,b*bat_dia+b*bat_space,1]) 
                        rotate([0,0,270]) battery_clip(bat_dia);
                }

            }
        }
    }
    if(bat_layout == "3S_staggered") {
        translate([bat_len,bat_dia/2,.38+(bat_dia/2)]) {
            for( b = [0:1:bat_num-1]) {
                if(b == 0 || b == 2 || b == 4) {
                    translate([0,b*bat_dia+b*bat_space,1]) rotate([-90,0,90]) battery(bat_type);
                    color("dimgrey") translate([-2,b*bat_dia+b*bat_space,1]) rotate([0,0,90]) battery_clip(bat_dia);
                    color("dimgrey") translate([-bat_len+2,b*bat_dia+b*bat_space,1]) 
                        rotate([0,0,270]) battery_clip(bat_dia);
                }
                if(b == 1 || b == 3 || b == 5) {
                    translate([13-bat_len,b*bat_dia+b*bat_space,1]) rotate([-90,0,270]) battery(bat_type);
                    color("dimgrey") translate([11,b*bat_dia+b*bat_space,1]) rotate([0,0,90]) battery_clip(bat_dia);
                    color("dimgrey") translate([-bat_len+18,b*bat_dia+b*bat_space,1]) 
                        rotate([0,0,270]) battery_clip(bat_dia);
                }

            }
        }
    }
}


module battery_clip(bat_dia = 18.4) {
    
    mat = .38;
    width = 9.5;
    tab = 8.9;
    bat_holder = bat_dia+2*mat;
    adj = .1;

    difference() {
        translate([0,width,0]) rotate([90,0,0]) cylinder(d=bat_holder, h=9.5);
        translate([0,width+adj,0]) rotate([90,0,0]) cylinder(d=bat_dia, h=10.5);
        translate([mat/2-11.1/2,-adj,mat-1.3-bat_dia/2]) cube([11.1-mat,width+2*adj,3]);
        translate([0,width+adj,0]) rotate([90,-45,0]) cube([bat_dia,bat_dia,bat_holder]);
    }
    difference() {
        translate([-11.1/2,0,-1.3-bat_dia/2]) cube([11.1,width,3]);
        translate([mat-11.1/2,-adj,mat/2-1.3-bat_dia/2]) cube([11.1-2*mat,width+2*adj,3]);
    }
    difference() {
        translate([-(tab/2),-3.5,-1-bat_dia/2]) rotate([-5,0,0]) cube([tab,3.5,10]);
        translate([-(tab/2)-adj,-3.5+mat,mat-1-bat_dia/2]) rotate([-5,0,0]) cube([tab+2*adj,3.5+mat,10]);
    }    
    translate([0,-2.225,0]) rotate([85,0,0]) cylinder(d=tab, h=mat);
    difference() {
        translate([0,-2.75,0]) sphere(d=3);
        translate([-5,-2.75,-5]) rotate([85,0,0]) cube([tab,10,10]);
    }
}


module led(ledcolor = "red") {
    
    color(ledcolor) cube([3,1.5,.4]);
    color("silver") cube([.5,1.5,.5]);
    color("silver") translate([2.5,0,0]) cube([.5,1.5,.5]);
}


module battery(type) {

    adj = .01;
    if(type == "18650") {
        difference() {
            cylinder(d=18.4, h=65);
            translate([0,0,65-4]) difference() {
                cylinder(d=18.5, h=2);
                cylinder(d=17.5, h=3);
            }
        }
    }
    if(type == "18650_convex") {
        difference() {
            cylinder(d=18.4, h=68);
            translate([0,0,65-4]) difference() {
                cylinder(d=18.5, h=2);
                cylinder(d=17.5, h=3);
            }
            translate([0,0,65-adj]) difference() {
                cylinder(d=18.5, h=3+2*adj);
                cylinder(d=14.4, h=3+2*adj);
            }
        }
    }
    if(type == "21700") {
        difference() {
            cylinder(d=21, h=70);
            translate([0,0,70-4]) difference() {
                cylinder(d=21.1, h=2);
                cylinder(d=20.1, h=3);
            }
        }
    }
}


// JST-PH connector class
module jst_xh(num_pin) {
    
    size_x = 2.4+(num_pin*2);
    size_y = 5.75;

    union() {
        difference() {
            color("white") cube([size_x, size_y, 7]);
            color("white") translate([.5, .5, .5]) cube([size_x-1, size_y-1, 7]);
            color("white") translate([1, -.1,6]) cube([0.25*num_pin, size_y-2, 7]);
            color("white") translate([size_x-2, -.1,6]) cube([0.25*num_pin, size_y-2, 7]);
            color("white") translate([-.1,1,6]) cube([size_y-2,0.25*num_pin,7]);
            color("white") translate([size_x-2,1,6]) cube([size_y-2,0.25*num_pin,7]);
        }
        translate([1.25, 0, 0]) union() {
            for(ind=[0:num_pin-1]) {
                color("silver") translate([ind*2.5, 2.4, .5]) cube([.5, .5, 4]);
            }
        }
    }
}


// JST-SH connector class
module jst_sh(num_pin) {
    
    size_x = 1+(num_pin);
    size_y = 2.9;

    union() {
        difference() {
            color("white") cube([size_x, size_y, 4.25]);
            color("white") translate([.25, .25, .25]) cube([size_x-.5, size_y-.5, 4.25]);
        }
        difference() {
            color("white") translate([-.4, 0, 2.75]) cube([.5, 1, 1.5]);
            color("white") translate([-1, .5, 2.25]) cube([1, 1, 1.5]);            
        }
        difference() {
            color("white") translate([size_x-.1, 0, 2.75]) cube([.5, 1, 1.5]);
            color("white") translate([size_x, .5, 2.25]) cube([1, 1, 1.5]);            
        }
        translate([1, 0, 0]) union() {
            for(ind=[0:num_pin-1]) {
                color("silver") translate([(ind*1)-.125, 1, .5]) cube([.25, .25, 3.5]);
            }
        }
    }
}


/* standoff module
    standoff(standoff[radius,height,holesize,supportsize,supportheight,sink,style,reverse,insert_e,i_dia,i_depth])
        sink=0 none
        sink=1 countersink
        sink=2 recessed hole
        sink=3 nut holder
        sink=4 blind hole
        
        style=0 hex shape
        style=1 cylinder
*/
module standoff(stand_off){

    radius = stand_off[0];
    height = stand_off[1];
    holesize = stand_off[2];
    supportsize = stand_off[3];
    supportheight = stand_off[4];
    sink = stand_off[5];
    style = stand_off[6];
    reverse = stand_off[7];
    insert_e = stand_off[8];
    i_dia = stand_off[9];
    i_depth = stand_off[10];
    
    adjust = 0.1;
    
    difference (){ 
        union () { 
            if(style == 0 && reverse == 0) {
                rotate([0,0,30]) cylinder(d=radius*2/sqrt(3),h=height,$fn=6);
            }
            if(style == 0 && reverse == 1) {
                translate([0,0,-height]) rotate([0,0,30]) cylinder(d=radius*2/sqrt(3),h=height,$fn=6);
            }
            if(style == 1 && reverse == 0) {
                cylinder(d=radius,h=height,$fn=90);
            }
            if(style == 1 && reverse == 1) {
                translate([0,0,-height]) cylinder(d=radius,h=height,$fn=90);
            }
            if(reverse == 1) {
                translate([0,0,-supportheight]) cylinder(d=(supportsize),h=supportheight,$fn=60);
            }
            else {
                cylinder(d=(supportsize),h=supportheight,$fn=60);
            }
        }
        // hole
        if(sink <= 3  && reverse == 0) {
                translate([0,0,-adjust]) cylinder(d=holesize, h=height+(adjust*2),$fn=90);
        }
        if(sink <= 3  && reverse == 1) {
                translate([0,0,-adjust-height]) cylinder(d=holesize, h=height+(adjust*2),$fn=90);
        }
        // countersink hole
        if(sink == 1 && reverse == 0) {
            translate([0,0,-adjust]) cylinder(d1=6.5, d2=(holesize), h=3);
        }
        if(sink == 1 && reverse == 1) {
            translate([0,0,+adjust-2.5]) cylinder(d1=(holesize), d2=6.5, h=3);
        }
        // recessed hole
        if(sink == 2 && reverse == 0) {
            translate([0,0,-adjust]) cylinder(d=6.5, h=3);
        }
        if(sink == 2 && reverse == 1) {
            translate([0,0,+adjust-3]) cylinder(d=6.5, h=3);
        }
        // nut holder
        if(sink == 3 && reverse == 0) {
            translate([0,0,-adjust]) cylinder(r=3.3,h=3,$fn=6);     
        }
        if(sink == 3 && reverse == 1) {
            translate([0,0,+adjust-3]) cylinder(r=3.3,h=3,$fn=6);     
        }
        // blind hole
        if(sink == 4 && reverse == 0) {
            translate([0,0,2]) cylinder(d=holesize, h=height,$fn=90);
        }
        if(sink == 4 && reverse == 1) {
            translate([0,0,-height-2-adjust]) cylinder(d=holesize, h=height,$fn=90);
        }
        if(insert_e > 0 && reverse == 0) {
            translate([0,0,height-i_depth]) cylinder(d=i_dia, h=i_depth+adjust,$fn=90);
        }
        if(insert_e > 0 && reverse == 1) {
            translate([0,0,-height-adjust]) cylinder(d=i_dia, h=i_depth+adjust,$fn=90);
        }
    }
}


/* slab module */
module slab(size, radius) {
    
    x = size[0];
    y = size[1];
    z = size[2];   
    linear_extrude(height=z)
    hull() {
        translate([0+radius ,0+radius, 0]) circle(r=radius);	
        translate([0+radius, y-radius, 0]) circle(r=radius);	
        translate([x-radius, y-radius, 0]) circle(r=radius);	
        translate([x-radius, 0+radius, 0]) circle(r=radius);
    }  
}


/* slot module */
module slot(hole,length,depth) {
    
    hull() {
        cylinder(d=hole,h=depth);
        translate([length,0,0]) cylinder(d=hole,h=depth);        
        }
    }
    
    
/* fan mask to create opening */
module fan_mask(size, thick, style) {

    $fn=90;
    
    if(style == 1) {
        translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-2);
        if(size == 40) {
            // mount holes
            translate ([size-4,size-4,-1]) cylinder(h=thick+2, d=3);
            translate ([size-4,4,-1]) cylinder(h=thick+2, d=3);
            translate ([4,size-4,-1]) cylinder(h=thick+2, d=3);
            translate ([4,4,-1]) cylinder(h=thick+2, d=3);
        }
        if(size == 60) {
            // mount holes
            translate ([size-5,size-5,-1]) cylinder(h=thick+2, d=3);
            translate ([size-5,5,-1]) cylinder(h=thick+2, d=3);
            translate ([5,size-5,-1]) cylinder(h=thick+2, d=3);
            translate ([5,5,-1]) cylinder(h=thick+2, d=3);
        }
        if(size >= 80) {
            // mount holes
            translate ([size-3.75,size-3.75,-1]) cylinder(h=thick+2, d=3);
            translate ([size-3.75,3.75,-1]) cylinder(h=thick+2, d=3);
            translate ([3.75,size-3.75,-1]) cylinder(h=thick+2, d=3);
            translate ([3.75,3.75,-1]) cylinder(h=thick+2, d=3);
        }
    }
    if(style == 2 && size == 40) {
        difference() {
            union () {
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-2);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-6);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-10);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-14);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-18);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-22);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-26);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-30);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-34);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-38);
                }
                // mount holes
                translate ([size-4,size-4,-1]) cylinder(h=thick+2, d=3);
                translate ([size-4,4,-1]) cylinder(h=thick+2, d=3);
                translate ([4,size-4,-1]) cylinder(h=thick+2, d=3);
                translate ([4,4,-1]) cylinder(h=thick+2, d=3);
            }
            translate([6.5,5,-2]) rotate([0,0,45]) cube([size,2,thick+4]);
            translate([4.5,size-6,-2]) rotate([0,0,-45]) cube([size,2,thick+4]);
        } 
    }
    if(style == 2 && size == 60) {
        difference() {
            union () {
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-2);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-6);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-10);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-14);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-18);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-22);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-26);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-30);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-34);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-38);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-42);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-46);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-50);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-54);
                }
                // mount holes
                translate ([size-5,size-5,-1]) cylinder(h=thick+2, d=3);
                translate ([size-5,5,-1]) cylinder(h=thick+2, d=3);
                translate ([5,size-5,-1]) cylinder(h=thick+2, d=3);
                translate ([5,5,-1]) cylinder(h=thick+2, d=3);
            }
            translate([9.5,8,-2]) rotate([0,0,45]) cube([size,2,thick+4]);
            translate([8.5,size-10,-2]) rotate([0,0,-45]) cube([size,2,thick+4]);
        } 
    }
    if(style == 2 && size >= 80) {
        difference() {
            union () {
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-2);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-8);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-14);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-20);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-26);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-32);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-38);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-44);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-50);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-56);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-62);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-68);
                }
                difference() {
                    translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-74);
                    translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-79);
                }
                if(size == 92) {
                    difference() {
                        translate ([size/2,size/2,-1]) cylinder(h=thick+2, d=size-86);
                        translate ([size/2,size/2,-2]) cylinder(h=thick+4, d=size-92);
                    }
                }
                // mount holes
                translate ([size-3.75,size-3.75,-1]) cylinder(h=thick+2, d=3);
                translate ([size-3.75,3.75,-1]) cylinder(h=thick+2, d=3);
                translate ([3.75,size-3.75,-1]) cylinder(h=thick+2, d=3);
                translate ([3.75,3.75,-1]) cylinder(h=thick+2, d=3);
            }
            translate([6.5,4.25,-2]) rotate([0,0,45]) cube([size*1.2,3,thick+4]);
            translate([4.25,size-6.5,-2]) rotate([0,0,-45]) cube([size*1.2,3,thick+4]);
        } 
    }
}


module heatsink(type,soc1size_z) {
    // type c series
    if(type == "c4_oem") {
        translate([5.5,-23.5,soc1size_z])
        difference() {
            union() {        
                color("gray",1) cube([40,32,10]);
                if(type=="hc4_oem") {
                    color("gray",1) translate([39.99,5,0]) cube([5.5,7,2]);
                    color("gray",1) translate([45.75,8.5,0]) cylinder(d=7, h=2);
                    color("gray",1) translate([-5.49,25,0]) cube([5.5,7,2]);
                    color("gray",1) translate([-5.5,28.5,0]) cylinder(d=7, h=2);
                    }
                    else {
                        color("gray",1) translate([39.99,0,0]) cube([5.5,7,2]);
                        color("gray",1) translate([45.75,3.5,0]) cylinder(d=7, h=2);
                        color("gray",1) translate([-5.49,20,0]) cube([5.5,7,2]);
                        color("gray",1) translate([-5.5,23.5,0]) cylinder(d=7, h=2);
                    }
                }
            // center channel and fins
            color("gray",1) translate([17.5,-1,2]) cube([5,34,9]);
            color("gray",1) translate([1.5,-1,2]) cube([1.25,34,9]);
            for (i=[3.5:2.25:38]) {
                color("gray",1) translate([i,-1,2]) cube([1.5,34,9]);
            }
            // fin elevations
            color("gray",1) translate([4,-1,9]) cube([8,34,2]);
            color("gray",1) translate([28,-1,9]) cube([8,34,2]);
            color("gray",1) translate([11,-1,8]) cube([2,34,3]);
            color("gray",1) translate([27,-1,8]) cube([2,34,3]);
            color("gray",1) translate([13,-1,7]) cube([2,34,4]);
            color("gray",1) translate([25,-1,7]) cube([2,34,4]);
            color("gray",1) translate([16,-1,6]) cube([2,34,5]);
            color("gray",1) translate([22,-1,6]) cube([2,34,5]);
            // holes
            if(type == "hc4_oem") {
                color("gray",1) translate([45.75,8.5,-1]) cylinder(d=3, h=4);
                color("gray",1) translate([-5.5,28.5,-1]) cylinder(d=3, h=4);
                }
                else {
                    color("gray",1) translate([45.75,3.5,-1]) cylinder(d=3, h=4);
                    color("gray",1) translate([-5.5,23.5,-1]) cylinder(d=3, h=4);
                }
        }
    }
    if(type == "xu4_oem") {
        $fn=60;
        translate([5.5,-30,soc1size_z])
        difference() {
            union() {
                color("DeepSkyBlue",.6) cube([40, 40, 9.8]);
                color("DeepSkyBlue",.6) translate([39.99,6.5,0]) cube([5.5,7,2]);
                color("DeepSkyBlue",.6) translate([45.5,10,0]) cylinder(d=7, h=2);
                color("DeepSkyBlue",.6) translate([-5.49,26.5,0]) cube([5.5,7,2]);
                color("DeepSkyBlue",.6) translate([-5.5,30,0]) cylinder(d=7, h=2);
            }
            // fins
            for (i=[1.5:2.25:38.5]) {
                    color("DeepSkyBlue",.6) translate([i,-1,2]) cube ([1.25,42,12]);
            }
            // cross opening
            color("DeepSkyBlue",.6) translate([17.5,-1,2]) cube([5,42,10]);
            color("DeepSkyBlue",.6) translate([-1,17.5,2]) cube([42,5,10]);
            // fin elevations
            color("DeepSkyBlue",.6) translate([4,-1,9]) cube([8,42,2]);
            color("DeepSkyBlue",.6) translate([28,-1,9]) cube([8,42,2]);
            color("DeepSkyBlue",.6) translate([11,-1,8]) cube([2,42,3]);
            color("DeepSkyBlue",.6) translate([27,-1,8]) cube([2,42,3]);
            color("DeepSkyBlue",.6) translate([13,-1,7]) cube([2.5,42,4]);
            color("DeepSkyBlue",.6) translate([25,-1,7]) cube([2,42,4]);
            color("DeepSkyBlue",.6) translate([16,-1,6]) cube([2,42,5]);
            color("DeepSkyBlue",.6) translate([22,-1,6]) cube([2.5,42,5]);
            // fan cut out
            color("DeepSkyBlue",.6) translate([20,20,2]) cylinder(r=18, h=13.5, $fn=100);

            // holes
            color("DeepSkyBlue",.6) translate([45.5,10,-1]) cylinder(d=3, h=4);
            color("DeepSkyBlue",.6) translate([-5.5,30,-1]) cylinder(d=3, h=4);
        }
    }
}