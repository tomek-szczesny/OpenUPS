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
    
    drivebay_ups_top(length=147, width=101.6, bottom_height=12, top_height=14, wallthick, floorthick,
                     pcbsize, pcb_position, batpcbsize, batpcb_position)    
    drivebay_ups_bottom(length=147,width=101.6, bottom_height=12, wallthick, floorthick,
                        pcbsize, pcb_position, batpcbsize, batpcb_position)
    ups_pcb(pcbsize, pcb_position)
    bat_pcb(batpcbsize, batpcb_position)
    battery_placement(bat_layout, bat_num, bat_space, bat_type, bat_dia, bat_len)
    battery_clip(bat_dia = 18.4)
    led(ledcolor = "red")
    battery(type)
    jst_xh(num_pin)
    jst_sh(num_pin)
    jst_ph(num_pin)
    standoff(standoff[radius,height,holesize,supportsize,supportheight,sink,style,i_dia,i_depth])
    slab(size, radius)
    slot(hole,length,depth)
    fan_mask(size, thick, style)
    heatsink(type,soc1size_z)xt60(style)
    xt60(style)
    xt30(style)
    
*/

use <./lib/fillets.scad>;

/* [OpenUPS Case Configuration] */
view = "model"; // ["model", "platter"]
case_style = "drivebay"; // ["drivebay", "mini", "3S1P", "3S2P", "3S1P-LPO", "3S2P-LPO"]
heatsink_type = "c4_oem"; // ["c4_oem", "xu4_oem"]

pcb_enable = true;
top_enable = false;
label_enable = false;
bottom_vent = true;
top_vent = true;

bat_num = 3; // [1:6]
bat_type = "21700"; // ["18650", "21700"]
bat_layout = "3S_staggered"; // ["straight", "staggered", "3S2P_staggered", "3S_staggered"]
bat_space = 3; // [3:10]

bat_dia = bat_type == "21700" ? 21 : 18.4;
bat_len = bat_type == "21700" ? 70 : 65;

/* [Hidden] */
adj = .01;
$fn = 90;

if(view == "model") {
    if(case_style == "drivebay") {
        // pcb size and placement
        pcbsize = [90, 62, 1.6];
        pcb_position = [6, 0, 10];
        batpcbsize = [90, 90, 1];
        batpcb_position = [6, 54, 1];
        bat_position = ([batpcb_position[0]+4,batpcb_position[1]+12,batpcb_position[2]+batpcbsize[2]]);

        color("dimgrey") drivebay_ups_bottom(147, 101.6, 12, 3, 2, 
            pcbsize, pcb_position, batpcbsize, batpcb_position);
        if(top_enable) {
            color("dimgrey") drivebay_ups_top(147, 101.6, 12, 14, 2, 1, 
                pcbsize, pcb_position, batpcbsize, batpcb_position);
        }
        if(pcb_enable) {
            ups_pcb(pcbsize, pcb_position);
            bat_pcb(batpcbsize, batpcb_position, bat_position);
            translate(bat_position) battery_placement(bat_layout, bat_num, bat_space, bat_type, bat_dia, bat_len);
        }
        // pillars
        translate([pcb_position[0]+4, pcb_position[1]+pcbsize[1]-4, batpcb_position[2]+batpcbsize[2]]) 
            pillar(5, 8, 0);
        translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+pcbsize[1]-4, batpcb_position[2]+batpcbsize[2]])
            pillar(5, 8, 0);
        translate([pcb_position[0]+4, 147-4-7/2,  batpcb_position[2]+batpcbsize[2]]) pillar(5, 10, 0);
        translate([pcb_position[0]+pcbsize[0]-4, 147-4-7/2,  batpcb_position[2]+batpcbsize[2]]) pillar(5, 10, 0);

        if(label_enable && top_enable) {
            color("black") translate([33.5,-1,20]) rotate([90,0,0]) text("+5V",3);
            color("red") translate([34.5,0,16]) rotate([90,0,0]) text("+",3);
            color("black") translate([39,0,15.5]) rotate([90,0,0]) text("-",5);
            color("black") translate([44,0,20]) rotate([90,0,0]) text("+12V",3);
            color("red") translate([45.5,0,16]) rotate([90,0,0]) text("+",3);
            color("black") translate([50,0,15.5]) rotate([90,0,0]) text("-",5);
            color("black") translate([55.5,0,20]) rotate([90,0,0]) text("+Vin",3);
            color("red") translate([56.5,0,16]) rotate([90,0,0]) text("+",3);
            color("black") translate([61,0,15.5]) rotate([90,0,0]) text("-",5);
        }
    }
    if(case_style == "mini") {
        // pcb size and placement
        pcbsize = [90, 62, 1.6];
        pcb_position = [2.5, 0, 10.4];
        batpcbsize = [90, 82, 1.6];
        batpcb_position = [6, 63, 1];
        wallthick = 2;
        floorthick = 1;

        color("dimgrey") drivebay_ups_bottom(65, 95, 12, 2, 2, 
            pcbsize, pcb_position, batpcbsize, batpcb_position);
        if(top_enable) {
            translate([0,0,0]) color("dimgrey") drivebay_ups_top(65, 95, 12, 12, 2, 2, 
                pcbsize, pcb_position, batpcbsize, batpcb_position);
        }
        if(pcb_enable) {
            ups_pcb(pcbsize, pcb_position);
        }
    }
    if(case_style == "3S1P") {
        
        pcbsize = [90, 82, 1.6];
        pcb_position = [3, 3, 4];
        batpcbsize = [90, 90, 1];
        batpcb_position = [3, 3, 4];
        bat_position = ([batpcb_position[0]+4,batpcb_position[1]+12,batpcb_position[2]+batpcbsize[2]]);
        wallthick = 2;
        floorthick = 2;
        gap = 1;
        
        color("dimgrey") 
        drivebay_ups_bottom(batpcbsize[1]+2*(wallthick+gap), batpcbsize[0]+2*(wallthick+gap), 12, 2, 2, 
            pcbsize, pcb_position, batpcbsize, batpcb_position);
        if(top_enable) {
            translate([0,0,]) color("dimgrey") drivebay_ups_top(batpcbsize[1]+2*(wallthick+gap), 
                batpcbsize[0]+2*(wallthick+gap), 12, 18, 2, 2, pcbsize, pcb_position, batpcbsize, batpcb_position);
        }
        if(pcb_enable) {
            bat_pcb(batpcbsize, batpcb_position, bat_position);
            translate(bat_position) battery_placement(bat_layout, bat_num, bat_space, bat_type, bat_dia, bat_len);
        }
    }
    if(case_style == "3S2P") {
        
        pcbsize = [90, 147, 1];
        pcb_position = [3, 3, 4];
        batpcbsize = [90, 147, 1];
        batpcb_position = [3, 3, 4];
        bat_position = ([batpcb_position[0],batpcb_position[1],batpcb_position[2]+batpcbsize[2]]);
        wallthick = 2;
        floorthick = 2;
        gap = 1;
        
        color("dimgrey") 
        drivebay_ups_bottom(batpcbsize[1]+2*(wallthick+gap), batpcbsize[0]+2*(wallthick+gap), 12, 2, 2, 
            pcbsize, pcb_position, batpcbsize, batpcb_position);
        if(top_enable) {
            translate([0,0,]) color("dimgrey") drivebay_ups_top(batpcbsize[1]+2*(wallthick+gap), 
                batpcbsize[0]+2*(wallthick+gap), 12, 18, 2, 2, pcbsize, pcb_position, batpcbsize, batpcb_position);
        }
        if(pcb_enable) {
            bat_pcb(batpcbsize, batpcb_position);
            translate([batpcb_position[0]+bat_position[0], batpcb_position[1]+bat_position[1], batpcb_position[2]]) 
                battery_placement(bat_layout, bat_num, bat_space, bat_type, bat_dia, bat_len);
        }
    }
    if(case_style == "3S1P-LPO") {
        
        pcbsize = [90, 82, 1.6];
        pcb_position = [3, 3, 4];
        batpcbsize = [90, 90, 1];
        batpcb_position = [3, 3, 4];
        bat_position = ([batpcb_position[0]+4,batpcb_position[1]+12,batpcb_position[2]+batpcbsize[2]]);
        wallthick = 2;
        floorthick = 2;
        gap = 1;
        
        color("dimgrey") 
        drivebay_ups_bottom(batpcbsize[1]+2*(wallthick+gap), batpcbsize[0]+2*(wallthick+gap), 12, 2, 2, 
            pcbsize, pcb_position, batpcbsize, batpcb_position);
        if(top_enable) {
            translate([0,0,]) color("dimgrey") drivebay_ups_top(batpcbsize[1]+2*(wallthick+gap), 
                batpcbsize[0]+2*(wallthick+gap), 12, 18, 2, 2, pcbsize, pcb_position, batpcbsize, batpcb_position);
        }
        if(pcb_enable) {
            bat_pcb(batpcbsize, batpcb_position, bat_position);
            translate(bat_position) battery_placement(bat_layout, bat_num, bat_space, bat_type, bat_dia, bat_len);
        }
    }
}

if(view == "platter") {
    if(case_style == "drivebay") {
        // pcb size and placement
        pcbsize = [90, 62, 1.6];
        pcb_position = [6, 0, 9];
        batpcbsize = [90, 82, 1.6];
        batpcb_position = [6, 63, 1];

        drivebay_ups_bottom(147, 101.6, 12, 3, 2, 
            pcbsize, pcb_position, batpcbsize, batpcb_position);
        translate([0,-10,26]) rotate([180,0,0]) drivebay_ups_top(147, 101.6, 14, 12, 2, 1, 
            pcbsize, pcb_position, batpcbsize, batpcb_position);
    }
    if(case_style == "mini") {
        // pcb size and placement
        pcbsize = [90, 62, 1.6];
        pcb_position = [2.5, 0, 9];
        batpcbsize = [90, 82, 1.6];
        batpcb_position = [6, 63, 1];
        wallthick = 2;
        floorthick = 1;

        drivebay_ups_bottom(65, 95, 12, 2, 2, 
            pcbsize, pcb_position, batpcbsize, batpcb_position);
        translate([0,-10,24]) rotate([180,0,0]) drivebay_ups_top(65, 95, 12, 12, 2, 2, 
            pcbsize, pcb_position, batpcbsize, batpcb_position);
    }
    if(case_style == "3S1P") {
        // pcb size and placement
        pcbsize = [90, 82, 1.6];
        pcb_position = [3, 3, 4];
        batpcbsize = [90, 90, 1];
        batpcb_position = [3, 3, 4];
        bat_position = ([batpcb_position[0]+4,batpcb_position[1]+12,batpcb_position[2]+batpcbsize[2]]);
        wallthick = 2;
        floorthick = 2;
        gap = 1;

        drivebay_ups_bottom(batpcbsize[1]+2*(wallthick+gap), batpcbsize[0]+2*(wallthick+gap), 12, 2, 2, 
            pcbsize, pcb_position, batpcbsize, batpcb_position);
        translate([0,-10,24]) rotate([180,0,0]) drivebay_ups_top(batpcbsize[1]+2*(wallthick+gap), 
            batpcbsize[0]+2*(wallthick+gap), 12, 18, 2, 2, pcbsize, pcb_position, batpcbsize, batpcb_position);
    }    
    if(case_style == "3S2P") {
    }    
}
if(view == "debug") {
        batpcbsize = [90, 82, 1];
        batpcb_position = [3, 3, 4];
        wallthick = 2;
        floorthick = 2;
        gap = 1;
        
        bat_pcb(batpcbsize, batpcb_position);
        translate([batpcb_position[0]+4, batpcb_position[1]+6, batpcb_position[2]+batpcbsize[2]]) 
            battery_placement(bat_layout, bat_num, bat_space, bat_type, bat_dia, bat_len);
}

/* 3.5" hd bay ups holder top*/
module drivebay_ups_top(length=147, width=101.6, bottom_height=12, top_height=14, wallthick, floorthick, 
        pcbsize, pcb_position, batpcbsize, batpcb_position) {
                                
    height = top_height + bottom_height;
    top_standoff = [7,top_height,3.5,10,4,4,0,1,0,4.5,5];
    adjust = .1;    
    $fn=90;
    
    difference() {
        translate([(width/2),(length/2),bottom_height+(top_height/2)])         
            cube_fillet_inside([width,length,top_height], 
                vertical=[3,3,3,3], top=[0,0,0,0], bottom=[0,0,0,0], $fn=90);      
        translate([(width/2),(length/2),bottom_height+(top_height/2)-floorthick])           
            cube_fillet_inside([width-(wallthick*2),length-(wallthick*2),top_height], 
                vertical=[2,2,2,2], top=[0,0,0,0], bottom=[2,2,2,2], $fn=90);
        // top vents
        if(top_vent) {
            if(case_style == "drivebay") {
                for ( c=[15:40:length-40]) {
                    for (r=[10:4:90]) {
                        translate ([r,c,height-1-adjust]) cube([2,35,floorthick+(adjust*2)]);
                    }
                }
            }
            if(case_style == "mini") {
                for ( c=[16:40:length-40]) {
                    for (r=[5:4:90]) {
                        translate ([r,c,height-2-adjust]) cube([2,35,floorthick+(adjust*2)]);
                    }
                }
            }
            if(case_style == "3S1P") {
                for ( c=[7:40:length-10]) {
                    for (r=[5:4:90]) {
                        translate ([r,c,height-2-adjust]) cube([2,35,floorthick+(adjust*2)]);
                    }
                }
            }
            if(case_style == "3S2P") {
                for ( c=[20:40:length-40]) {
                    for (r=[5:4:90]) {
                        translate ([r,c,height-2-adjust]) cube([2,35,floorthick+(adjust*2)]);
                    }
                }
            }
        }
        // ups psb standoff holes
        if(case_style == "3S1P" || case_style == "3S2P") {
            // battery psb standoff holes
            translate([batpcb_position[0]+4, batpcb_position[1]+4, height-2]) cylinder(d=6.5, h=4);
            translate([batpcb_position[0]+4, batpcb_position[1]+batpcbsize[1]-4, height-2]) cylinder(d=6.5, h=4);
            translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+batpcbsize[1]-4, height-2]) 
                cylinder(d=6.5, h=4);
            translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+4, height-2]) cylinder(d=6.5, h=4);
        }
        if(case_style == "drivebay") {
            translate([pcb_position[0]+4, pcb_position[1]+13, height-2]) cylinder(d=6.5, h=4);
            translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, height-2]) cylinder(d=6.5, h=4);
            translate([pcb_position[0]+4, 147-4-top_standoff[0]/2, height-2]) cylinder(d=6.5, h=4);
            translate([pcb_position[0]+pcbsize[0]-4, 147-4-top_standoff[0]/2, height-2]) cylinder(d=6.5, h=4);
        }
        if(case_style == "mini") {
            translate([pcb_position[0]+4, pcb_position[1]+13, height-2]) cylinder(d=6.5, h=4);
            translate([pcb_position[0]+4, pcb_position[1]+pcbsize[1]-4, height-2]) cylinder(d=6.5, h=4);
            translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+pcbsize[1]-4, height-2]) cylinder(d=6.5, h=4);
            translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, height-2]) cylinder(d=6.5, h=4);
        }
        if(case_style == "drivebay") {
            // power plug
            color("dimgrey") translate([83,-1, pcb_position[2]+pcbsize[2]-adj]) cube([10.5,14,7.5+pcbsize[2]]);
            // terminal blocks
            translate([32,-1, pcb_position[2]]) cube([33.5,10,10+pcbsize[2]]);
            translate([36,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            translate([41,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            translate([47,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            translate([52,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            translate([58,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            translate([63,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            // sata1 & sata2
            translate([8.5,-1, pcb_position[2]]) cube([23.5,10,6+pcbsize[2]]);
            // i2c
            translate([65, -1, pcb_position[2]+pcbsize[2]]) cube([18, 10, 3.5]);
        }
        if(case_style == "mini") {
            // power plug
            translate([79.5, -1, pcb_position[2]+pcbsize[2]-adj]) cube([10.5, 14, pcbsize[2]+7.5]);
            // terminal blocks
            translate([28.5, -1, pcb_position[2]]) cube([34, 10, 10+pcbsize[2]]);
            translate([32,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            translate([37,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            translate([43,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            translate([48,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            translate([54,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            translate([59,4, top_height+bottom_height-3]) cylinder(d=4, h=4);
            // sata1 & sata2
            translate([4.5, -1, pcb_position[2]]) cube([24, 10, pcbsize[2]+6]);
            // i2c
            translate([62, -1, pcb_position[2]+pcbsize[2]]) cube([18, 10, 3.5]);
            // usb-c opening
            translate([53.5,pcbsize[1]+4,pcb_position[2]+3.25]) rotate([90,0,0]) slot(3.5,6,6);
            translate([52.5,pcbsize[1]+wallthick+4-wallthick/2,pcb_position[2]+3.25]) rotate([90,0,0]) slot(5,8,3);
            // led openings
            translate([29,pcbsize[1]+4,pcb_position[2]+2.75]) rotate([90,0,0]) cylinder(d=3, h=6);
            translate([34,pcbsize[1]+4,pcb_position[2]+2.75]) rotate([90,0,0]) cylinder(d=3, h=6);
            translate([39,pcbsize[1]+4,pcb_position[2]+2.75]) rotate([90,0,0]) cylinder(d=3, h=6);
            // xt60 opening
//            translate([pcbsize[0]+2,pcbsize[1]-26,pcb_position[2]+pcbsize[2]]) cube([6,16,9]);            
        }
    }
    // ups standoffs
    if(case_style == "3S1P" || case_style == "3S2P") {
        translate([pcb_position[0]+4, pcb_position[1]+4, height]) standoff(top_standoff);
        translate([pcb_position[0]+4, pcb_position[1]+pcbsize[1]-4, height]) standoff(top_standoff);
        translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+pcbsize[1]-4, height]) standoff(top_standoff);
        translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+4, height]) standoff(top_standoff);
        
    }
    if(case_style == "drivebay") {
        translate([pcb_position[0]+4, pcb_position[1]+13, height]) standoff(top_standoff);
        translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, height]) standoff(top_standoff);
        translate([pcb_position[0]+4, 147-4-top_standoff[0]/2, height]) standoff(top_standoff);
        translate([pcb_position[0]+pcbsize[0]-4, 147-4-top_standoff[0]/2, height]) standoff(top_standoff);
    }
    if(case_style == "mini") {
        translate([pcb_position[0]+4, pcb_position[1]+13, height]) standoff(top_standoff);
        translate([pcb_position[0]+4, pcb_position[1]+pcbsize[1]-4, height]) standoff(top_standoff);
        translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+pcbsize[1]-4, height]) standoff(top_standoff);
        translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, height]) standoff(top_standoff);
    }
}


/* 3.5" hd bay ups holder */
module drivebay_ups_bottom(length=147,width=101.6, bottom_height=12, wallthick, floorthick, 
        pcbsize, pcb_position, batpcbsize, batpcb_position) {
    
    pcb_standoff = [7,pcb_position[2],3.5,10,4,1,1,0,1,4,5];
    batpcb_standoff = [7,batpcb_position[2],3.5,10,4,1,1,0,1,4,5];
    adjust = .1;    
    $fn=90;
    
    difference() {
        union() {
            difference() {
                translate([(width/2),(length/2),(bottom_height/2)])         
                    cube_fillet_inside([width,length,bottom_height], 
                        vertical=[3,3,3,3], top=[0,0,0,0], bottom=[0,0,0,0], $fn=90);      
                translate([(width/2),(length/2),(bottom_height/2)+floorthick])           
                    cube_fillet_inside([width-(wallthick*2),length-(wallthick*2),bottom_height], 
                        vertical=[2,2,2,2], top=[0,0,0,0], bottom=[2,2,2,2], $fn=90);
                   
                // bottom vents
                if(bottom_vent == true && case_style != "3S1P" && case_style != "3S2P") {
                    for ( r=[15:40:40]) {
                        for (c=[20:4:80]) {
                            translate ([c,r,-adjust]) cube([2,35,wallthick+(adjust*2)]);
                        }
                    }
                }
            }
            if(case_style == "drivebay") {
                // side nut holder support    
                translate([wallthick-adjust+3,28.5,7]) rotate([-90,0,90]) cylinder(d=10,h=3);
                translate([wallthick-adjust+3,70.5,7]) rotate([-90,0,90])  cylinder(d=10,h=3);
                translate([wallthick-adjust+3,130.17,7]) rotate([-90,0,90])  cylinder(d=10,h=3);
                translate([width-wallthick+adjust-3,130.1,7]) rotate([90,0,90])  cylinder(d=10,h=3);
                translate([width-wallthick+adjust-3,70.5,7]) rotate([90,0,90])  cylinder(d=10,h=3);
                translate([width-wallthick+adjust-3,28.5,7]) rotate([90,0,90])  cylinder(d=10,h=3);
            }
        }
        if(case_style == "drivebay") {
            // side screw holes
            translate([wallthick-adjust+3,28.5,7]) rotate([-90,0,90]) cylinder(d=3.6,h=7);
            translate([wallthick-adjust+3,70.5,7]) rotate([-90,0,90])  cylinder(d=3.6,h=7);
            translate([wallthick-adjust+3,130.17,7]) rotate([-90,0,90])  cylinder(d=3.6,h=7);
            translate([width-wallthick+adjust-3,130.1,7]) rotate([90,0,90])  cylinder(d=3.6,h=7);
            translate([width-wallthick+adjust-3,70.5,7]) rotate([90,0,90])  cylinder(d=3.6,h=7);
            translate([width-wallthick+adjust-3,28.5,7]) rotate([90,0,90])  cylinder(d=3.6,h=7);
            
            // side nut trap    
            translate([wallthick+adjust+3,28.5,7]) rotate([-90,0,90]) cylinder(r=3.30,h=4,$fn=6);
            translate([wallthick+adjust+3,70.5,7]) rotate([-90,0,90])  cylinder(r=3.30,h=4,$fn=6);
            translate([wallthick+adjust+3,130.17,7]) rotate([-90,0,90])  cylinder(r=3.30,h=4,$fn=6);
            translate([width-wallthick+adjust-3,130.1,7]) rotate([90,0,90])  cylinder(r=3.30,h=4,$fn=6);
            translate([width-wallthick+adjust-3,70.5,7]) rotate([90,0,90])  cylinder(r=3.30,h=4,$fn=6);
            translate([width-wallthick+adjust-3.01,28.5,7]) rotate([90,0,90])  cylinder(r=3.30,h=4,$fn=6);
            
            // ups psb
            translate([pcb_position[0],-.01+pcb_position[1]+(147-length)/2,pcb_position[2]]) 
                slab([pcbsize[0],pcbsize[1],20], 3);
            // battery psb clearance and holes
            translate([batpcb_position[0],batpcb_position[1]+(147-length)/2,batpcb_position[2]]) 
                slab([batpcbsize[0],batpcbsize[1],20], 3);
            translate([batpcb_position[0]+4, batpcb_position[1]+4, -1]) cylinder(d=3.5, h=4);
            translate([batpcb_position[0]+4, batpcb_position[1]+batpcbsize[1]-4, -1]) cylinder(d=3.5, h=4);
            translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+batpcbsize[1]-4, -1]) cylinder(d=3.5, h=4);
            translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+4, -1]) cylinder(d=3.5, h=4);
            // ups psb standoff holes
            translate([pcb_position[0]+4, pcb_position[1]+13, -1]) cylinder(d=6.5, h=4);
            translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, -1]) cylinder(d=6.5, h=4);
            // fan1 & fan2
            translate([63, -1, pcb_position[2]-8]) cube([20.5, 10, pcbsize[2]+8]);
        }
        
        // mini case openings
        if(case_style == "mini") {
            // ups psb
            translate([pcb_position[0], pcb_position[1]-.01, pcb_position[2]]) slab([pcbsize[0], pcbsize[1], 20], 3);
            // standoff openings
            translate([pcb_position[0]+4, pcb_position[1]+13, -1]) cylinder(d=6.5, h=4);
            translate([pcb_position[0]+4, pcb_position[1]+pcbsize[1]-4, -1]) cylinder(d=6.5, h=4);
            translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+pcbsize[1]-4, -1]) cylinder(d=6.5, h=4);
            translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, -1]) cylinder(d=6.5, h=4);

            // fan1 & fan2
            translate([59.5, -1, pcb_position[2]-7]) cube([20.5, 10, pcbsize[2]+7]);
            // sata1 & sata2
            translate([4.5, -1, pcb_position[2]]) cube([24, 10, pcbsize[2]+6]);
            // i2c
            translate([62, -1, pcb_position[2]+pcbsize[2]]) cube([18, 10, 3.5]);
            // usb-c opening
            translate([53.5,pcbsize[1]+4,pcb_position[2]+3.25]) rotate([90,0,0]) slot(3.5,6,6);
            translate([52.5,pcbsize[1]+wallthick+4-wallthick/2,pcb_position[2]+3.25]) rotate([90,0,0]) slot(5,8,3);
            // led openings
            translate([29,pcbsize[1]+4,pcb_position[2]+2.75]) rotate([90,0,0]) cylinder(d=3, h=6);
            translate([34,pcbsize[1]+4,pcb_position[2]+2.75]) rotate([90,0,0]) cylinder(d=3, h=6);
            translate([39,pcbsize[1]+4,pcb_position[2]+2.75]) rotate([90,0,0]) cylinder(d=3, h=6);
//            // xt60 opening
//            translate([pcbsize[0]+2,pcbsize[1]-26,pcb_position[2]+pcbsize[2]]) cube([6,16,9]);            
            // xt30 opening
            translate([pcbsize[0]+2,pcbsize[1]-20,pcb_position[2]-pcbsize[2]-3.75]) cube([6,10.5,5.5]);            
            translate([pcbsize[0]+4,pcbsize[1]-22,pcb_position[2]-pcbsize[2]-5.75]) cube([6,14.5,9.5]);            
        }
        // ups psb standoff holes
        if(case_style == "3S1P" || case_style == "3S2P") {
            // battery psb standoff holes
            translate([batpcb_position[0]+4, batpcb_position[1]+4, -1]) cylinder(d=6.5, h=4);
            translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+4, -1]) cylinder(d=6.5, h=4);
            translate([batpcb_position[0]+4, batpcb_position[1]+batpcbsize[1]-4, -1]) cylinder(d=6.5, h=4);
            translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+batpcbsize[1]-4, -1]) cylinder(d=6.5, h=4);
            // i2c opening
            translate([batpcb_position[0]+89.5, batpcb_position[1]+22.5, batpcb_position[2]+batpcbsize[2]])
                rotate([0,0,0]) cube([4,7,5]);
            // xt30 opening
            translate([batpcb_position[0]+89.5, batpcb_position[1]+10, batpcb_position[2]+batpcbsize[2]])
                rotate([0,0,0]) cube([4,10,5]);
        }
    }
    // ups standoffs
    if(case_style == "3S1P" || case_style == "3S2P") {
        // pcb standoff holes
        translate([batpcb_position[0]+4, batpcb_position[1]+4, 0]) standoff(batpcb_standoff);
        translate([batpcb_position[0]+4, batpcb_position[1]+batpcbsize[1]-4, 0]) standoff(batpcb_standoff);
        translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+batpcbsize[1]-4, 0]) standoff(batpcb_standoff);
        translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+4, 0]) standoff(batpcb_standoff);
    }
    else {
        translate([pcb_position[0]+4, pcb_position[1]+13, 0]) standoff(pcb_standoff);
        translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+20, 0]) standoff(pcb_standoff);
        if(case_style == "mini") {
            translate([pcb_position[0]+4, pcb_position[1]+pcbsize[1]-4, 0]) standoff(pcb_standoff);
            translate([pcb_position[0]+pcbsize[0]-4, pcb_position[1]+pcbsize[1]-4, 0]) standoff(pcb_standoff);
        }
    }
}


/* open ups pcb */
module ups_pcb(pcbsize, pcb_position) {
    
    pcb_color = "#151515";
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
        // heatsink holes
        color("dimgrey") translate([pcb_position[0]+5, pcb_position[1]+40, pcb_position[2]-1]) cylinder(d=3.5, h=4);
        color("dimgrey") translate([pcb_position[0]+56, pcb_position[1]+20, pcb_position[2]-1]) cylinder(d=3.5, h=4);
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
    translate([pcb_position[0]+61, pcb_position[1]+4.25, pcb_position[2]+pcbsize[2]]) 
        rotate([90, 0, 0]) jst_sh(4);
    translate([pcb_position[0]+70, pcb_position[1]+4.25, pcb_position[2]+pcbsize[2]]) 
        rotate([90, 0, 0]) jst_sh(4);
        
    // fan 1
    translate([pcb_position[0]+pcbsize[0]-19, pcb_position[1]+8, pcb_position[2]-2*pcbsize[2]]) 
        rotate([0, 0, 180]) import("lib/22053031.stl");
//    color("black") translate([pcb_position[0]+pcbsize[0]-21, pcb_position[1]+1, pcb_position[2]+pcbsize[2]]) 
//         linear_extrude(height = .5) text("FAN 1", size=2);
    // front fan2
    translate([pcb_position[0]+pcbsize[0]-28, pcb_position[1]+8, pcb_position[2]-2*pcbsize[2]]) 
        rotate([0, 0, 180]) import("lib/22053031.stl");
//    color("black") translate([pcb_position[0]+pcbsize[0]-30, pcb_position[1]+1, pcb_position[2]+pcbsize[2]]) 
//         linear_extrude(height = .5) text("FAN 2", size=2);
         
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
        
    // xt30 connector
    if(case_style == "mini") {
        translate([pcb_position[0]+81, pcb_position[1]+pcbsize[1]-20, pcb_position[2]-pcbsize[2]+1.6])
            rotate([0,180,270]) xt30("XT30PW-M");
        // front usb-c
        translate([pcb_position[0]+54, pcb_position[1]+pcbsize[1]-9.5, pcb_position[2]+pcbsize[2]+pcbsize[2]]) 
             import("lib/usb-c.stl");
    }
    // battery sense
    translate([pcb_position[0]+84, pcb_position[1]+pcbsize[1]-11.5, pcb_position[2]+pcbsize[2]])
            rotate([0,0,270]) jst_ph(2);
    // heatsink
    translate([pcb_position[0]+5,pcb_position[1]+40,pcb_position[2]+0]) heatsink(heatsink_type,2.5);
}


/* battery pcb */
module bat_pcb(batpcbsize, batpcb_position, bat_position) {
    
    batpcb_color = "#008066";
    adj = .01;
    $fn = 90;

    difference() {
        color(batpcb_color) translate(batpcb_position) slab(batpcbsize, 3);
        color("dimgrey") translate([batpcb_position[0]+4, batpcb_position[1]+4, batpcb_position[2]-1]) 
            cylinder(d=3.5, h=4);
        color("dimgrey") translate([batpcb_position[0]+4, batpcb_position[1]+batpcbsize[1]-4, batpcb_position[2]-1]) 
            cylinder(d=3.5, h=4);
        color("dimgrey") translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+batpcbsize[1]-4,
            batpcb_position[2]-1]) cylinder(d=3.5, h=4);
        color("dimgrey") translate([batpcb_position[0]+batpcbsize[0]-4, batpcb_position[1]+4, batpcb_position[2]-1]) 
            cylinder(d=3.5, h=4);
    }
    if(case_style == "3S1P" || case_style == "3S2P") {
        // battery connection
        translate([batpcb_position[0]+83.5, batpcb_position[1]+20, batpcb_position[2]+batpcbsize[2]])
            rotate([0,0,270]) xt30("XT30PW-F");
        // battery sense
        translate([batpcb_position[0]+84, batpcb_position[1]+29, batpcb_position[2]+batpcbsize[2]+4.5])
            rotate([270,0,270]) jst_ph(2);
    }
    // battery sense
    if(case_style == "drivebay") {
//        translate([batpcb_position[0]+84, batpcb_position[1]+batpcbsize[1]-9.5, batpcb_position[2]+batpcbsize[2]])
//            rotate([0,0,270]) jst_ph(4);
        // battery sense
//        translate([batpcb_position[0]+84, batpcb_position[1]+29, batpcb_position[2]+batpcbsize[2]+4.5])
//            rotate([270,0,270]) jst_ph(2);
        // battery sense
        translate([batpcb_position[0]+78, batpcb_position[1]+29, batpcb_position[2]+batpcbsize[2]])
            rotate([0,0,270]) jst_ph(2);
//        translate([batpcb_position[0]+83.5, batpcb_position[1]+20, batpcb_position[2]+batpcbsize[2]])
//            rotate([0,0,270]) xt30("XT30PW-F");
    }
//    translate([batpcb_position[0]+87.5, batpcb_position[1]+25, batpcb_position[2]+batpcbsize[2]])
//    rotate([0,0,180]) xt30("XT30PW-F");
//    translate([batpcb_position[0]+78, batpcb_position[1]+9.5, batpcb_position[2]+batpcbsize[2]])
//            rotate([0,0,0]) jst_ph(4);
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
                    translate([12-bat_len,b*bat_dia+b*bat_space,1]) rotate([-90,0,270]) battery(bat_type);
                    color("dimgrey") translate([10,b*bat_dia+b*bat_space,1]) rotate([0,0,90]) battery_clip(bat_dia);
                    color("dimgrey") translate([-bat_len+14,b*bat_dia+b*bat_space,1]) 
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
                    color("dimgrey") translate([-bat_len+15,b*bat_dia+b*bat_space,1]) 
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


// JST-XH connector class
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


// JST-PH connector class
module jst_ph(num_pin) {
    size_x = 2.4+(num_pin*2);
    size_y = 4.5;
    
    union() {
        difference() {
            color("white") cube([size_x, size_y, 6]);
            color("white") translate([.5, .5, .5]) cube([size_x-1, size_y-1, 6]);
            color("white") translate([size_x/2-(0.5*num_pin)/2, -.1,.5]) cube([0.5*num_pin, size_y-2, 6]);
        }
        translate([1.95, 0, 0]) union() {
            for(ind=[0:num_pin-1]) {
                color("silver") translate([ind*2, 1.4, .5]) cube([.5, .5, 4]);
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


/* pillar module */   
module pillar(dia, height, rotation) {
    difference() {
        color("silver") rotate([0, 0, rotation]) cylinder(d=dia*2/sqrt(3), h=height, $fn=6);
        color("silver") translate([0,0,-.1]) rotate([0, 0, rotation]) cylinder(d=2.75, h=height+.2);
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
        $fn = 60;
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

//    xt60(style)
//         style = "XT60UPB-F", "XT60UPB-M", "XT60PW-F", "XT60PW-M", 
module xt60(style) {
    
    concolor = "orange";
    adj = .01;
    $fn = 90;
    
    if(style == "XT60UPB-F") {
        
        width = 15.5;
        depth = 7.9;
        height = 15.7;

        difference() {
            union() {
                color(concolor) cube([width, depth, 8]);
                color(concolor) translate([1,1,8-adj]) cube([width-2, depth-2, 7.7]);
                color(concolor) translate([7.1,2,height-adj]) cube([1, 4.5, 1]);            
            }
            // lower bevel
            color(concolor) translate([-3,2,-adj]) rotate([0,0,45]) cube([width-4, depth-4, 8+adj]);
            color(concolor) translate([-4.5,2,-adj]) rotate([0,0,-45]) cube([width-4, depth-4, 8+adj]);
            // upper bevel
            color(concolor) translate([-2,2,8-adj]) rotate([0,0,45]) cube([width-4, depth-4, 8]);
            color(concolor) translate([-3.5,2,8-adj]) rotate([0,0,-45]) cube([width-4, depth-4, 8]);
            // pin holes
            color(concolor) translate([4,depth/2,-adj]) rotate([0,0,0]) cylinder(d=4.26, h=16);
            color(concolor) translate([11.2,depth/2,-adj]) rotate([0,0,0]) cylinder(d=4.26, h=16);
            // guide
            color(concolor) translate([6.6,1-adj,8]) cube([2, .5+adj, 8+adj]);            
        }
        // pins
        difference() {
            color("gold") translate([4,depth/2,-3]) rotate([0,0,0]) cylinder(d=4.26, h=height+2.8);
            color("gold") translate([4,depth/2,-3-adj]) rotate([0,0,0]) cylinder(d=3.26, h=height+3);
        }
        difference() {
            color("gold") translate([11.2,depth/2,-3]) rotate([0,0,0]) cylinder(d=4.26, h=height+2.8);
            color("gold") translate([11.2,depth/2,-3-adj]) rotate([0,0,0]) cylinder(d=3.26, h=height+3);
        }
    }
    if(style == "XT60UPB-M") {
        
        width = 15.4;
        depth = 8;
        height = 15.9;

        difference() {
            color(concolor) cube([width, depth, height]);        
            difference() {
                color(concolor) translate([1,1,1]) cube([width-2, depth-2, height]);
                // inner bevel
                color(concolor) translate([-2,2,1]) rotate([0,0,45]) cube([width-4, depth-4, height]);
                color(concolor) translate([-3.5,2,1]) rotate([0,0,-45]) cube([width-4, depth-4, height]);
            }
            // lower bevel
            color(concolor) translate([-3,2,-adj]) rotate([0,0,45]) cube([width-4, depth-4, height+2*adj]);
            color(concolor) translate([-4.5,2,-adj]) rotate([0,0,-45]) cube([width-4, depth-4, height+2*adj]);
            // pin holes
            color(concolor) translate([4,depth/2,-adj]) rotate([0,0,0]) cylinder(d=4.26, h=16);
            color(concolor) translate([11.2,depth/2,-adj]) rotate([0,0,0]) cylinder(d=4.26, h=16);
        }
        // guide
        color(concolor) translate([6.6,6.5-adj,7]) cube([2, .5+adj, 8+adj]);
        // pins
        difference() {
            color("gold") translate([4,depth/2,-3]) rotate([0,0,0]) cylinder(d=4.26, h=height+1.8);
            color("gold") translate([4,depth/2,-3-adj]) rotate([0,0,0]) cylinder(d=3.26, h=height+3);
            color("gold") translate([4,depth/2,8-adj]) rotate([0,0,45]) cube([.5,5,height], center=true);
            color("gold") translate([4,depth/2,8-adj]) rotate([0,0,-45]) cube([.5,5,height], center=true);
        }
        difference() {
            color("gold") translate([11.2,depth/2,-3]) rotate([0,0,0]) cylinder(d=4.26, h=height+1.8);
            color("gold") translate([11.2,depth/2,-3-adj]) rotate([0,0,0]) cylinder(d=3.26, h=height+3);
            color("gold") translate([11.2,depth/2,8-adj]) rotate([0,0,45]) cube([.5,5,height], center=true);
            color("gold") translate([11.2,depth/2,8-adj]) rotate([0,0,-45]) cube([.5,5,height], center=true);
        }
    }
    if(style == "XT60PW-F") {
        
        width = 15.5;
        depth = 7.9;
        height = 17.2;
        translate([0,0,depth+.5]) rotate([270,0,0]) {
            difference() {
                union() {
                    color(concolor) cube([width, depth, height-7.7]);
                    color(concolor) translate([1,1,height-7.7-adj]) cube([width-2, depth-2.5, 7.7]);
                    color(concolor) translate([7.1,1.5,height-.5-adj]) cube([1, 4.5, 1]);            
                    color(concolor) translate([0,depth-adj,0]) cube([width, .5, height-7.7]);
                }
                // lower bevel
                color(concolor) translate([13,-7,-adj]) rotate([0,0,45]) cube([width-4, depth-4, height+2*adj]);
                color(concolor) translate([-6.5,2,-adj]) rotate([0,0,-45]) cube([width-4, depth-4, height+2*adj]);
                // upper bevel
                color(concolor) translate([13.25,-3.75,height-7.7-adj]) rotate([0,0,45]) cube([width-4, depth-4, 8]);
                color(concolor) translate([11.25,8,height-7.7-adj]) rotate([0,0,-45]) cube([width-4, depth-4, 8]);
                // pin holes
                color(concolor) translate([4,depth/2,3-adj]) rotate([0,0,0]) cylinder(d=4.26, h=16);
                color(concolor) translate([11.2,depth/2,3-adj]) rotate([0,0,0]) cylinder(d=4.26, h=16);
                // guide
                color(concolor) translate([6.6,6-adj,height-7.7]) cube([2, .5+adj, 8+adj]);            
            }
            // pins
            difference() {
                color("gold") translate([4,depth/2,3]) rotate([0,0,0]) cylinder(d=4.26, h=height-3.2);
                color("gold") translate([4,depth/2,3-adj]) rotate([0,0,0]) cylinder(d=3.26, h=height-3);
            }
            difference() {
                color("gold") translate([11.2,depth/2,3]) rotate([0,0,0]) cylinder(d=4.26, h=height-3.2);
                color("gold") translate([11.2,depth/2,3-adj]) rotate([0,0,0]) cylinder(d=3.26, h=height-3);
            }
            // pins
            color("gold") translate([4,6.9-adj+depth/2,1.85]) rotate([90,0,0]) cylinder(d=2, h=2.5);
            color("gold") translate([11.2,6.9-adj+depth/2,1.85]) rotate([90,0,0]) cylinder(d=2, h=2.5);
        }
    }
    if(style == "XT60PW-M") {
        
        width = 15.5;
        depth = 8.4;
        height = 18.2;
        
        translate([0,0,depth]) rotate([270,0,0]) {
            difference() {
                color(concolor) cube([width, depth, height]);        
                difference() {
                    color(concolor) translate([1,1,1]) cube([width-2, depth-2, height]);
                    // inner bevel
                    color(concolor) translate([-2,2,1]) rotate([0,0,45]) cube([width-4, depth-4, height]);
                    color(concolor) translate([-3.5,2,1]) rotate([0,0,-45]) cube([width-4, depth-4, height]);
                }
                // bevel
                color(concolor) translate([14,-7,-adj]) rotate([0,0,45]) cube([width-4, depth-4, height+2*adj]);
                color(concolor) translate([-7.5,2,-adj]) rotate([0,0,-45]) cube([width-4, depth-4, height+2*adj]);
                // pin holes
                color(concolor) translate([4,depth/2,2-adj]) rotate([0,0,0]) cylinder(d=4.26, h=16);
                color(concolor) translate([11.2,depth/2,2-adj]) rotate([0,0,0]) cylinder(d=4.26, h=16);
            }
            // guide
            color(concolor) translate([6.6,6.5-adj,7]) cube([2, .5+adj, 8+adj]);
            // pins
            difference() {
                color("gold") translate([4,depth/2,3]) rotate([0,0,0]) cylinder(d=4.26, h=height-4.2);
                color("gold") translate([4,depth/2,-adj]) rotate([0,0,0]) cylinder(d=3.26, h=height);
                color("gold") translate([4,depth/2,8-adj]) rotate([0,0,45]) cube([.5,5,height], center=true);
                color("gold") translate([4,depth/2,8-adj]) rotate([0,0,-45]) cube([.5,5,height], center=true);
            }
            difference() {
                color("gold") translate([11.2,depth/2,3]) rotate([0,0,0]) cylinder(d=4.26, h=height-4.2);
                color("gold") translate([11.2,depth/2,-adj]) rotate([0,0,0]) cylinder(d=3.26, h=height);
                color("gold") translate([11.2,depth/2,8-adj]) rotate([0,0,45]) cube([.5,5,height], center=true);
                color("gold") translate([11.2,depth/2,8-adj]) rotate([0,0,-45]) cube([.5,5,height], center=true);
            }
            // pins
            color("gold") translate([4,6.7-adj+depth/2,1.85]) rotate([90,0,0]) cylinder(d=2, h=2.5);
            color("gold") translate([11.2,6.7-adj+depth/2,1.85]) rotate([90,0,0]) cylinder(d=2, h=2.5);
        }
    }
}


//    xt30(style)
//         style = "XT30PB-F", "XT30PB-M", "XT30PW-F", "XT30PW-M", 
module xt30(style) {
    
    concolor = "orange";
    adj = .01;
    $fn = 90;
    
    if(style == "XT30PB-F") {
        
        width = 10.2;
        depth = 5.2;
        height = 9.4;
        pin_osize = 2.1;
        pin_isize = 1.6;

        difference() {
            union() {
                color(concolor) cube([width, depth, 3.4]);
                color(concolor) translate([1,1,3.4-adj]) cube([width-2, depth-2, 6]);
            }
            // lower bevel
            color(concolor) translate([-1.5,2,-adj]) rotate([0,0,45]) cube([width-4, depth-2, 3.4+2*adj]);
            color(concolor) translate([-3.5,2,-adj]) rotate([0,0,-45]) cube([width-4, depth-3, 3.4+2*adj]);
            // upper bevel
            color(concolor) translate([-0.25,2,3.4-adj]) rotate([0,0,45]) cube([width-4, depth-4, 7]);
            color(concolor) translate([-0.75,2,3.4-adj]) rotate([0,0,-45]) cube([width-4, depth-4, 7]);
            // pin holes
            color(concolor) translate([2.6,depth/2,-adj]) cylinder(d=pin_osize, h=16);
            color(concolor) translate([7.6,depth/2,-adj]) cylinder(d=pin_osize, h=16);
            // cutout
            color(concolor) translate([4,1-adj,3.4]) cube([2, .75+adj, 8+adj]);            
            color(concolor) translate([4,3.5-adj,3.4]) cube([2, .75+adj, 8+adj]);            
        }
        // pins
        difference() {
            color("gold") translate([2.6,depth/2,0]) cylinder(d=pin_osize, h=height-.5);
            color("gold") translate([2.6,depth/2,0-adj]) cylinder(d=pin_isize, h=height+.5);
        }
        color("gold") translate([2.6,depth/2,-2]) cylinder(d=pin_isize, h=2);
        difference() {
            color("gold") translate([7.6,depth/2,0]) cylinder(d=pin_osize, h=height-.5);
            color("gold") translate([7.6,depth/2,0-adj]) cylinder(d=pin_isize, h=height+.5);
        }
        color("gold") translate([7.6,depth/2,-2]) cylinder(d=pin_isize, h=2);
    }
    if(style == "XT30PB-M") {
        
        width = 10.2;
        depth = 5.2;
        height = 10.7;
        pin_osize = 2.1;
        pin_isize = 1.6;

        difference() {
            color(concolor) cube([width, depth, height]);        
            difference() {
                color(concolor) translate([.5,.5,1]) cube([width-1, depth-1, height]);
                // inner bevel
                color(concolor) translate([-2.5,0,1]) rotate([0,0,45]) cube([width-2, depth-2, height]);
                color(concolor) translate([-4,2,1]) rotate([0,0,-45]) cube([width-2, depth-2, height]);
            }
            // lower bevel
            color(concolor) translate([-1.5,2,-adj]) rotate([0,0,45]) cube([width-4, depth-2, height+2*adj]);
            color(concolor) translate([-3.5,2,-adj]) rotate([0,0,-45]) cube([width-4, depth-3, height+2*adj]);
            // pin holes
            color(concolor) translate([2.6,depth/2,-adj]) cylinder(d=pin_osize, h=16);
            color(concolor) translate([7.6,depth/2,-adj]) cylinder(d=pin_osize, h=16);
        }
        // pins
        difference() {
            color("gold") translate([2.6,depth/2,0]) cylinder(d=pin_osize, h=height-.5);
            color("gold") translate([2.6,depth/2,0-adj]) cylinder(d=pin_isize, h=height+.5);
            color("gold") translate([2.6,depth/2,8-adj]) rotate([0,0,45]) cube([.5,5,height], center=true);
            color("gold") translate([2.6,depth/2,8-adj]) rotate([0,0,-45]) cube([.5,5,height], center=true);
        }
        color("gold") translate([2.6,depth/2,-2]) cylinder(d=pin_isize, h=2);
        difference() {
            color("gold") translate([7.6,depth/2,0]) cylinder(d=pin_osize, h=height-.5);
            color("gold") translate([7.6,depth/2,0-adj]) cylinder(d=pin_isize, h=height+.5);
            color("gold") translate([7.6,depth/2,8-adj]) rotate([0,0,45]) cube([.5,5,height], center=true);
            color("gold") translate([7.6,depth/2,8-adj]) rotate([0,0,-45]) cube([.5,5,height], center=true);
        }
        color("gold") translate([7.6,depth/2,-2]) cylinder(d=pin_isize, h=2);
    }
    if(style == "XT30PW-F") {
        
        width = 9.9;
        depth = 5;
        height = 9.4;
        pin_osize = 2.1;
        pin_isize = 1.6;

        translate([0,0,depth]) rotate([270,0,0]) {
            difference() {
                union() {
                    color(concolor) cube([width, depth, 3.4]);
                    color(concolor) translate([1,1,3.4-adj]) cube([width-2, depth-2, 6]);
                    color(concolor) translate([-0.5,1.6,.8]) rotate([270,0,0]) cylinder(d=1.6, h=3.4);
                    color(concolor) translate([10.25,1.6,.8]) rotate([270,0,0]) cylinder(d=1.6, h=3.4);
                }
                // upper bevel
                color(concolor) translate([-0.25,2,3.4-adj]) rotate([0,0,45]) cube([width-4, depth-4, 7]);
                color(concolor) translate([-0.75,2,3.4-adj]) rotate([0,0,-45]) cube([width-4, depth-4, 7]);
                // pin holes
                color(concolor) translate([2.6,depth/2,-adj]) cylinder(d=pin_osize, h=16);
                color(concolor) translate([7.6,depth/2,-adj]) cylinder(d=pin_osize, h=16);
                // mount holes
                color(concolor) translate([-0.5,1.5,.8]) rotate([270,0,0]) cylinder(d=.8, h=4);
                color(concolor) translate([10.25,1.5,.8]) rotate([270,0,0]) cylinder(d=.8, h=4);
                // cutout
                color(concolor) translate([4,1-adj,3.4]) cube([2, .75+adj, 8+adj]);            
                color(concolor) translate([4,3.5-adj,3.4]) cube([2, .75+adj, 8+adj]);            

            }
            // pins
            difference() {
                color("gold") translate([2.6,depth/2,0]) cylinder(d=pin_osize, h=height-.5);
                color("gold") translate([2.6,depth/2,0-adj]) cylinder(d=pin_isize, h=height+.5);
            }
            color("gold") translate([2.6,depth/2,-2.25]) cylinder(d=pin_osize, h=2.25);
            rotate([180,90,0]) translate([2.2,-4.5,-2.6]) color("gold") 
                rotate_extrude(angle=90, convexity = 10) translate([2, 0, 0]) circle(d = 1.6, $fn = 100);
            color("gold") translate([2.6,2+depth/2,-4.2]) rotate([270,0,0]) cylinder(d=pin_isize, h=2.5);
            
            difference() {
                color("gold") translate([7.6,depth/2,0]) cylinder(d=pin_osize, h=height-.5);
                color("gold") translate([7.6,depth/2,0-adj]) cylinder(d=pin_isize, h=height+.5);
            }
            color("gold") translate([7.6,depth/2,-2.25]) cylinder(d=pin_osize, h=2.25);
            rotate([180,90,0]) translate([2.2,-4.5,-7.6]) color("gold") 
                rotate_extrude(angle=90, convexity = 10) translate([2, 0, 0]) circle(d = 1.6, $fn = 100);
            color("gold") translate([7.6,2+depth/2,-4.2]) rotate([270,0,0]) cylinder(d=pin_isize, h=2.5);
            
            
            color("silver") translate([-0.5,1.5,.8]) rotate([270,0,0]) cylinder(d=.8, h=5.5);
            color("silver") translate([10.25,1.5,.8]) rotate([270,0,0]) cylinder(d=.8, h=5.5);
            
        }
    }
    if(style == "XT30PW-M") {
        
        width = 10.2;
        depth = 5.2;
        height = 9;
        pin_osize = 2.1;
        pin_isize = 1.6;
        
        translate([width,0,0]) rotate([270,180,0]) {
            difference() {
                union() {
                    color(concolor) cube([width, depth, height]);        
                    color(concolor) translate([-0.25,0,.8]) rotate([270,0,0]) cylinder(d=1.6, h=3.4);
                    color(concolor) translate([10.5,0,.8]) rotate([270,0,0]) cylinder(d=1.6, h=3.4);
                }
                difference() {
                    color(concolor) translate([.5,.5,1]) cube([width-1, depth-1, height]);
                    // inner bevel
                    color(concolor) translate([-2.5,0,1]) rotate([0,0,45]) cube([width-2, depth-2, height]);
                    color(concolor) translate([-4,2,1]) rotate([0,0,-45]) cube([width-2, depth-2, height]);
                }
                // lower bevel
                color(concolor) translate([-2.5,2,-adj]) rotate([0,0,45]) cube([width-4, depth-2, height+2*adj]);
                // pin holes
                color(concolor) translate([2.6,depth/2,-adj]) cylinder(d=pin_osize, h=16);
                color(concolor) translate([7.6,depth/2,-adj]) cylinder(d=pin_osize, h=16);
            }
            // pins
            difference() {
                color("gold") translate([2.6,depth/2,0]) cylinder(d=pin_osize, h=height-.5);
                color("gold") translate([2.6,depth/2,0-adj]) cylinder(d=pin_isize, h=height+.5);
                color("gold") translate([2.6,depth/2,8-adj]) rotate([0,0,45]) cube([.5,5,height], center=true);
                color("gold") translate([2.6,depth/2,8-adj]) rotate([0,0,-45]) cube([.5,5,height], center=true);
            }
            color("gold") translate([2.6,depth/2,-2.25]) cylinder(d=pin_osize, h=2.25);
            color("gold") translate([2.6,-2,-4.2]) rotate([270,0,0]) cylinder(d=pin_isize, h=2.7);
            rotate([0,90,0]) translate([2.22,.6,2.6]) color("gold") 
                rotate_extrude(angle=90, convexity = 10) translate([2, 0, 0]) circle(d = 1.6, $fn = 100);
            difference() {
                color("gold") translate([7.6,depth/2,0]) cylinder(d=pin_osize, h=height-.5);
                color("gold") translate([7.6,depth/2,0-adj]) cylinder(d=pin_isize, h=height+.5);
                color("gold") translate([7.6,depth/2,8-adj]) rotate([0,0,45]) cube([.5,5,height], center=true);
                color("gold") translate([7.6,depth/2,8-adj]) rotate([0,0,-45]) cube([.5,5,height], center=true);
            }
            color("gold") translate([7.6,depth/2,-2.25]) cylinder(d=pin_osize, h=2.25);
            color("gold") translate([7.6,-2,-4.2]) rotate([270,0,0]) cylinder(d=pin_isize, h=2.7);
            rotate([0,90,0]) translate([2.22,.6,7.6]) color("gold") 
                rotate_extrude(angle=90, convexity = 10) translate([2, 0, 0]) circle(d = 1.6, $fn = 100);
            
            color("silver") translate([-0.35,-2,.8]) rotate([270,0,0]) cylinder(d=.8, h=5.5);
            color("silver") translate([10.65,-2,.8]) rotate([270,0,0]) cylinder(d=.8, h=5.5);
        }
    }
}