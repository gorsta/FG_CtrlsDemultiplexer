##
# Numbering convention for buttons
#---------------------------------
# Use the button number of the xml binding  e.g. in the throttle file:
# <button n="15"> 
# <script>bdn(15);</script>
# To avoid number collisions add 100 to the numbers of the next xml file:
# <button n="15"> 
# <script>bdn(115);</script>
# . . and for a 3rd hid 
# <button n="15"> 
# <script>bdn(215);</script>

##
# Naming convention for button id:s
#----------------------------------
# A double letter e.g. 'cc' indicates double use of this button id. It is involved 
# both in events for shifting of focus as well as events for acting on properties. 
# For example, cc_down and cc_up are already reserved for the focus shifting 
# mechanism but cc_short and cc_long are free to use for actions on properties.
#
# A single letter id e.g. 'e' have all four events ('e_down', e_up', 'e_short'
# and 'e_long') available for acting on properties.
#
print("Loading dc-3 S-TECS_STEM dmux");

##
# Groups of buttons to use with the demultipleser
#
var hidCtrls = ["EN1", "EN2", "SW12"];
#var hidCtrls = ["EN2"];

##
# Button connections
#
var EN1buttons = {
    26: "aa", # encoder ccw
    27: "bb", # encoder cw
    30: "cc", # encoder PB
    };

var EN2buttons = {
    28: "aa", # encoder ccw
    29: "bb", # encoder cw
    31: "cc", # encoder PB
    };

var SW12buttons = {
    15: "aa", # sw1 toggle up
    17: "bb", # sw1 toggle down
    16: "c",  # sw1 PB
    18: "d",  # sw2 toggle up
    20: "e",  # sw2 toggle down
    19: "f",  # sw2 PB
    };

##
# Groups of sim/cockpit controls for the demultiplexer
#
var EN1items = ["FltInstr", "Autopilot"];
# var EN1items = ["FltInstr"];

var EN2items = ["NavLights", "Radio"];
#var EN2items = ["NavLights"];

var SW12items = ["EngCtrls"];

##
# Sim/cockpit controls
#


var xFltInstr = [ 
    {name	: "ALTimeter: %.2f inHg", 
    prop	   : "instrumentation/altimeter/setting-inhg", 
    aa_short: ["adjust", [-0.02, 27.5, 31]],
    bb_short: ["adjust", [0.02, 27.5, 31]],
    cc_long : ["popup"],
    }, 
    ];

var FltInstr = [ 
    {name	: "ALTimeter: %.2f inHg", 
    prop	   : "/instrumentation/altimeter/setting-inhg", 
    aa_short: ["adjust", [-0.02, 27.5, 31]],
    bb_short: ["adjust", [0.02, 27.5, 31]],
    cc_long : ["popup"],
    }, 
    {name	: "ALTimeter: %.1f hPa", 
    prop	   : "/instrumentation/altimeter/setting-hpa", 
    aa_short: ["adjust", [-0.5, 931, 1050]],
    bb_short: ["adjust", [0.5, 931, 1050]],
    cc_long : ["popup"],
    }, 
    {name	: "Instr light", 
    prop	   : "/controls/lighting/instruments-norm", 
    aa_short: ["adjust", ["Dec instr light", -0.02, 0, 0.16]],
    bb_short: ["adjust", ["Inc instr light", 0.02, 0, 0.16]],
    cc_long : ["popup"],
    }, 
    {name	: "Compass light:off;on", 
    prop	   : "/controls/lighting/compass-lights", 
    aa_short: ["adjust", [-1]],
    aaa_short: ["adjust", [-1]],
    bb_short: ["adjust", [1]],
    cc_long : ["popup"],
    }, 
    ];

##
# Autopilot controls
#
# This config connects to FG's generic AP and requires that some AP properties 
# has been initialized first by opening the AP dialog (F11) once.
# Refs:
# $FG_ROOT/keyboard.xml
# $FG_ROOT/gui/dialogs/autopilot.xml
#
var Autopilot = [ 
    {name	: "AP altitude\n%u feet set\n%s", 
    prop	   : ["/autopilot/settings/target-altitude-ft", 
               "/autopilot/locks/altitude"],
    aa_short: ["adjust", [-50, 1000, 20000]],
    bb_short: ["adjust", [50, 1000, 20000]],
    cc_short: ["script", ["", func {var node = props.globals.getNode("/autopilot/locks/altitude", 1); 
        if (node.getValue() != nil) {
        if (node.getValue() == "altitude-hold") {
            node.setValue( "" );
            gui.popupTip("AP Alt disengaged", 0.5);} 
        else {node.setValue( "altitude-hold");
            gui.popupTip("AP Alt engaged", 0.5);}
		      }
		      }]],
    cc_long : ["popup"],
    }, 
    {name	: "AP heading\n%u deg set\n%s", 
    prop	   : ["/autopilot/settings/heading-bug-deg", 
               "/autopilot/locks/heading"],
    aa_short: ["adjust", [-1, 0, 359, 1]],
    bb_short: ["adjust", [1, 0, 359, 1]],
    cc_short: ["script", ["", func {var node = props.globals.getNode("/autopilot/locks/heading", 1); 
        if (node.getValue() != nil) {
        if ( node.getValue() == "dg-heading-hold") {
            node.setValue( "" );
            gui.popupTip("AP Head disengaged", 0.5);} 
        else {node.setValue( "dg-heading-hold");
            gui.popupTip("AP Head engaged", 0.5);}   
		      }
		      }]],
    cc_long : ["popup"],
    }, 
    {name	: "AP speed\n%u kt set\n%s", 
    prop	   : ["/autopilot/settings/target-speed-kt", 
               "/autopilot/locks/speed"],
    aa_short: ["adjust", ["Target speed ", "/autopilot/settings/target-speed-kt", -5, 110, 140]],
    bb_short: ["adjust", ["Target speed ", "/autopilot/settings/target-speed-kt", 5, 110, 140]],
    cc_short: ["script", ["", func {var node = props.globals.getNode("/autopilot/locks/speed", 1); 
        if (node.getValue() != nil) {
        if ( node.getValue() == "speed-with-throttle") {
            node.setValue( "" );
            gui.popupTip("AP Throttle disengaged", 0.5);} 
        else {node.setValue( "speed-with-throttle");
            gui.popupTip("AP Throttle engaged", 0.5);}   
		      }
		      }]],
    cc_long : ["popup"],
    }, 
    ];

##
# Navlights controls
#
var NavLights = [
    {name	: "L landing light", 
    prop	   : "/controls/lighting/landing-lights", 
    cc_short: ["toggle", []], # Leave this as an example
    cc_long : ["popup"],
    }, 
    {name	: "R landing light", 
    prop	   : "/controls/lighting/taxi-light", 
    cc_short: ["toggle"],
    cc_long : ["popup"],
    }, 
    {name	: "Passing light:off;on", 
    prop	   : "/controls/lighting/strobe", 
    cc_short: ["toggle"],
    cc_long : ["popup"],
    }, 
    {name	: "Running light:off;on", 
    prop	   : "/controls/lighting/nav-lights", 
    cc_short: ["toggle"],
    cc_long : ["popup"],
    },
    {name	: "Tail light:off;on", 
    prop	   : "/controls/lighting/beacon", 
    cc_short: ["toggle"],
    cc_long : ["popup"],
    }, 
    ];

##
# Radio stack controls
#
# Refs.:
# https://wiki.flightgear.org/Radio_beacons
# https://wiki.flightgear.org/Radio_navigation
# $FG_ROOT/gui/dialogs/radios.xml
#
var Radio = [
    {name	: "COM1 (1 MHz)\n%.3f MHz standby\n%.3f MHz selected", 
    prop	   : ["/instrumentation/comm[0]/frequencies/standby-mhz", 
               "/instrumentation/comm[0]/frequencies/selected-mhz"],
    aa_short: ["adjust", [-1, 118, 136.975]],
    bb_short: ["adjust", [1, 118, 136.975]],
    cc_short: ["swap",],
    cc_long : ["popup"],
    }, 
    {name	: "COM1 (25 kHz)\n%.3f MHz standby\n%.3f MHz selected", 
    prop	   : ["/instrumentation/comm[0]/frequencies/standby-mhz", 
               "/instrumentation/comm[0]/frequencies/selected-mhz"],
    aa_short: ["adjust", [-0.025, 118, 136.975]],
    bb_short: ["adjust", [0.025, 118, 136.975]],
    cc_short: ["swap",],
    cc_long : ["popup"],
    }, 
    {name	: "COM2 (1 MHz)\n%.3f MHz standby\n%.3f MHz selected", 
    prop	   : ["/instrumentation/comm[1]/frequencies/standby-mhz", 
               "/instrumentation/comm[1]/frequencies/selected-mhz"],
    aa_short: ["adjust", [-1, 118, 136.975]],
    bb_short: ["adjust", [1, 118, 136.975]],
    cc_short: ["swap",],
    cc_long : ["popup"],
    }, 
    {name	: "COM2 (25 kHz)\n%.3f MHz standby\n%.3f MHz selected", 
    prop	   : ["/instrumentation/comm[1]/frequencies/standby-mhz", 
               "/instrumentation/comm[1]/frequencies/selected-mhz"],
    aa_short: ["adjust", [-0.025, 118, 136.975]],
    bb_short: ["adjust", [0.025, 118, 136.975]],
    cc_short: ["swap",],
    cc_long : ["popup"],
    }, 
    {name	: "NAV1 (1 MHz)\n%.3f MHz standby\n%.3f MHz selected\nradial %u deg", 
    prop	   : ["/instrumentation/nav[0]/frequencies/standby-mhz", 
               "/instrumentation/nav[0]/frequencies/selected-mhz",
               "/instrumentation/nav[0]/radials/selected-deg"],
    aa_short: ["adjust", [-1, 108, 117.95]],
    bb_short: ["adjust", [1, 108, 117.95]],
    cc_short: ["swap",],
    cc_long : ["popup"],
    }, 
    {name	: "NAV1 (50 kHz)\n%.3f MHz standby\n%.3f MHz selected\nradial %u deg", 
    prop	   : ["/instrumentation/nav[0]/frequencies/standby-mhz", 
               "/instrumentation/nav[0]/frequencies/selected-mhz",
               "/instrumentation/nav[0]/radials/selected-deg"],
    aa_short: ["adjust", [-0.05, 108, 117.95]],
    bb_short: ["adjust", [0.05, 108, 117.95]],
    cc_short: ["swap",],
    cc_long : ["popup"],
    }, 
    {name	: "NAV1 radial %u deg", 
    prop	   : "/instrumentation/nav[0]/radials/selected-deg",
    aa_short: ["adjust", [-1, 0, 359, 1]],
    bb_short: ["adjust", [1, 0, 359, 1]],
    cc_long : ["popup"],
    }, 

    {name	: "NAV2 (1 MHz)\n%.3f MHz standby\n%.3f MHz selected\nradial %u deg", 
    prop	   : ["/instrumentation/nav[1]/frequencies/standby-mhz", 
               "/instrumentation/nav[1]/frequencies/selected-mhz",
               "/instrumentation/nav[1]/radials/selected-deg"],
    aa_short: ["adjust", [-1, 108, 117.95]],
    bb_short: ["adjust", [1, 108, 117.95]],
    cc_short: ["swap",],
    cc_long : ["popup"],
    }, 
    {name	: "NAV2 (50 kHz)\n%.3f MHz standby\n%.3f MHz selected\nradial %u deg", 
    prop	   : ["/instrumentation/nav[1]/frequencies/standby-mhz", 
               "/instrumentation/nav[1]/frequencies/selected-mhz",
               "/instrumentation/nav[1]/radials/selected-deg"],
    aa_short: ["adjust", [-0.05, 108, 117.95]],
    bb_short: ["adjust", [0.05, 108, 117.95]],
    cc_short: ["swap",],
    cc_long : ["popup"],
    }, 
    {name	: "NAV2 radial %u deg", 
    prop	   : "/instrumentation/nav[1]/radials/selected-deg",
    aa_short: ["adjust", [-1, 0, 359, 1]],
    bb_short: ["adjust", [1, 0, 359, 1]],
    cc_long : ["popup"],
    }, 
    {name	: "ADF (10 kHz)\n%u kHz standby\n%u kHz selected\nradial %u deg", 
    prop	   : ["/instrumentation/adf/frequencies/standby-khz", 
               "/instrumentation/adf/frequencies/selected-khz",
               "/instrumentation/adf/rotation-deg"],
    aa_short: ["adjust", [-10, 190, 1750]],
    bb_short: ["adjust", [10, 190, 1750]],
    cc_short: ["swap",],
    cc_long : ["popup"],
    }, 
    {name	: "ADF (1 kHz)\n%u kHz standby\n%u kHz selected\nradial %u deg", 
    prop	   : ["/instrumentation/adf/frequencies/standby-khz", 
               "/instrumentation/adf/frequencies/selected-khz",
               "/instrumentation/adf/rotation-deg"],
    aa_short: ["adjust", [-1, 190, 1750]],
    bb_short: ["adjust", [1, 190, 1750]],
    cc_short: ["swap",],
    cc_long : ["popup"],
    }, 
    {name	: "ADF radial %u deg", 
    prop	   : "/instrumentation/adf/rotation-deg",
    aa_short: ["adjust", [-1, 0, 359, 1]],
    bb_short: ["adjust", [1, 0, 359, 1]],
    cc_long : ["popup"],
    }, 
    {name	: "DME\n%.3f MHz selected", 
    prop	   : "/instrumentation/dme/frequencies/selected-mhz",
    cc_long : ["popup"],
    }, 
    ];

##
# Engines controls
#
var EngCtrls = [
    {name	: "Fuel controls", 
    aa_long	: ["adjust", ["L fuel valve: %u", "/controls/fuel/left-valve", -1, 0, 5]],
    bb_long	: ["adjust", ["L fuel valve: %u", "/controls/fuel/left-valve", 1, 0, 5]],
    d_long	: ["adjust", ["R fuel valve: %u", "/controls/fuel/right-valve", -1, 0, 5]],
    e_long	: ["adjust", ["R fuel valve: %u", "/controls/fuel/right-valve", 1, 0, 5]],
    c_short	: ["toggle", ["L booster pump ", "/controls/fuel/tank/boost-pump"]],
    f_short	: ["toggle", ["R booster pump ", "/controls/fuel/tank[1]/boost-pump"]],
    }, 
    {name	: "Magnetos & starter", 
    aa_long	: ["adjust", ["L engine magnetos: %u", "/controls/engines/engine/magnetos", -1, 0, 3]],
    bb_long	: ["adjust", ["L engine magnetos: %u", "/controls/engines/engine/magnetos", 1, 0, 3]],
    d_long	: ["adjust", ["R engine magnetos: %u", "/controls/engines/engine[1]/magnetos", -1, 0, 3]],
    e_long	: ["adjust", ["R engine magnetos: %u", "/controls/engines/engine[1]/magnetos", 1, 0, 3]],
    c_up		: ["adjust", ["L engine starter: %u", "/controls/engines/engine/starter", -1]],
    c_down	: ["adjust", ["L engine starter: %u", "/controls/engines/engine/starter", 1]],
    f_up		: ["adjust", ["R engine starter: %u", "/controls/engines/engine[1]/starter", -1]],
    f_down	: ["adjust", ["R engine starter: %u", "/controls/engines/engine[1]/starter", 1]],
    },
    ];

