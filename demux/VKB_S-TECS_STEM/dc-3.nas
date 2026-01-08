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

var EN2items = ["NavLights", "Radio"];

var SW12items = ["EngCtrls"];

##
# Sim/cockpit controls
#
var FltInstr = [ 
    {name	: "ALTimeter", 
    aa_short: ["adjust", ["ALTimeter: %.2f inHg", "instrumentation/altimeter/setting-inhg", -0.02, 27.5, 31]],
    bb_short: ["adjust", ["ALTimeter: %.2f inHg", "instrumentation/altimeter/setting-inhg", 0.02, 27.5, 31]],
    }, 
    {name	: "Instr light", 
    aa_short: ["adjust", ["Dec instr light", "controls/lighting/instruments-norm", -0.02, 0, 0.16]],
    bb_short: ["adjust", ["Inc instr light", "controls/lighting/instruments-norm", 0.02, 0, 0.16]],
    }, 
    {name	: "Compass light", 
    aa_short: ["adjust", ["Compass light off", "controls/lighting/compass-lights", -1]],
    bb_short: ["adjust", ["Compass light on", "controls/lighting/compass-lights", 1]],
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
    {name	: "AP altitude", 
    aa_short: ["adjust", ["Target alt ", "autopilot/settings/target-altitude-ft", -50, 1000, 20000]],
    bb_short: ["adjust", ["Target alt ", "autopilot/settings/target-altitude-ft", 50, 1000, 20000]],
    cc_short: ["script", ["", func {var node = props.globals.getNode("/autopilot/locks/altitude", 1); 
        if (node.getValue() != nil) {
        if (node.getValue() == "altitude-hold") {
            node.setValue( "" );
            gui.popupTip("AP Alt disengaged", 0.5);} 
        else {node.setValue( "altitude-hold");
            gui.popupTip("AP Alt engaged", 0.5);}
		      }
		      }]],
    }, 
    {name	: "AP heading", 
    aa_short: ["adjust", ["Hedaing bug ", "autopilot/settings/heading-bug-deg", -1, 0, 359, 1]],
    bb_short: ["adjust", ["Hedaing bug ", "autopilot/settings/heading-bug-deg", 1, 0, 359, 1]],
    cc_short: ["script", ["", func {var node = props.globals.getNode("/autopilot/locks/heading", 1); 
        if (node.getValue() != nil) {
        if ( node.getValue() == "dg-heading-hold") {
            node.setValue( "" );
            gui.popupTip("AP Head disengaged", 0.5);} 
        else {node.setValue( "dg-heading-hold");
            gui.popupTip("AP Head engaged", 0.5);}   
		      }
		      }]],
    }, 
    {name	: "AP speed", 
    aa_short: ["adjust", ["Target speed ", "autopilot/settings/target-speed-kt", -5, 110, 140]],
    bb_short: ["adjust", ["Target speed ", "autopilot/settings/target-speed-kt", 5, 110, 140]],
    cc_short: ["script", ["", func {var node = props.globals.getNode("/autopilot/locks/speed", 1); 
        if (node.getValue() != nil) {
        if ( node.getValue() == "speed-with-throttle") {
            node.setValue( "" );
            gui.popupTip("AP Throttle disengaged", 0.5);} 
        else {node.setValue( "speed-with-throttle");
            gui.popupTip("AP Throttle engaged", 0.5);}   
		      }
		      }]],
    }, 
    ];

##
# Navlights controls
#
var NavLights = [
    {name	: "L landing light", 
    cc_short: ["toggle", ["/controls/lighting/landing-lights"]],
    }, 
    {name	: "R landing light", 
    cc_short: ["toggle", ["/controls/lighting/taxi-light"]],
    }, 
    {name	: "Passing light ", 
    cc_short: ["toggle", ["/controls/lighting/strobe"]],
    }, 
    {name	: "Running light ", 
    cc_short: ["toggle", ["/controls/lighting/nav-lights"]],
    },
    {name	: "Tail light ", 
    cc_short: ["toggle", ["/controls/lighting/beacon"]],
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
var freqDispCOM1 = func {
    gui.popupTip(sprintf("COM1\n%.3f MHz selected\n%.3f MHz standby", 
    getprop("/instrumentation/comm[0]/frequencies/selected-mhz"), 
    getprop("/instrumentation/comm[0]/frequencies/standby-mhz")), 5);
    }

var freqDispCOM2 = func {
    gui.popupTip(sprintf("COM2\n%.3f MHz selected\n%.3f MHz standby", 
    getprop("/instrumentation/comm[1]/frequencies/selected-mhz"), 
    getprop("/instrumentation/comm[1]/frequencies/standby-mhz")), 5);
    }

var freqDispNAV1 = func {
    gui.popupTip(sprintf("NAV1\n%.3f MHz selected\n%.3f MHz standby\nradial %u deg", 
    getprop("/instrumentation/nav[0]/frequencies/selected-mhz"), 
    getprop("/instrumentation/nav[0]/frequencies/standby-mhz"),
    getprop("/instrumentation/nav[0]/radials/selected-deg")), 5);
    }

var freqDispNAV2 = func {
    gui.popupTip(sprintf("NAV2\n%.3f MHz selected\n%.3f MHz standby\nradial %u deg", 
    getprop("/instrumentation/nav[1]/frequencies/selected-mhz"), 
    getprop("/instrumentation/nav[1]/frequencies/standby-mhz"),
    getprop("/instrumentation/nav[1]/radials/selected-deg")), 5);
    }

var freqDispADF = func {
    gui.popupTip(sprintf("ADF\n%u kHz selected\n%u kHz standby\nradial %u deg", 
    getprop("/instrumentation/adf/frequencies/selected-khz"), 
    getprop("/instrumentation/adf/frequencies/standby-khz"),
    getprop("/instrumentation/adf/rotation-deg")), 5);
    }

var freqDispDME = func {
    gui.popupTip(sprintf("DME\n%.3f MHz selected", 
    getprop("/instrumentation/dme/frequencies/selected-mhz")), 5);
    }

var Radio = [
    {name	: "COM1 (1 MHz)", 
    aa_short: ["adjust", ["COM1 (1 MHz) stdby %.3f MHz", "/instrumentation/comm[0]/frequencies/standby-mhz", -1, 118, 136.975]],
    bb_short: ["adjust", ["COM1 (1 MHz) stdby %.3f MHz", "/instrumentation/comm[0]/frequencies/standby-mhz", 1, 118, 136.975]],
    cc_short: ["script", ["", func {
        var fSel = getprop("/instrumentation/comm[0]/frequencies/selected-mhz"); 
        var fstb = getprop("/instrumentation/comm[0]/frequencies/standby-mhz"); 
        setprop("/instrumentation/comm[0]/frequencies/selected-mhz", fstb);
        setprop("/instrumentation/comm[0]/frequencies/standby-mhz", fSel);
        freqDispCOM1();}]],
    cc_long: ["script", ["", func {
        freqDispCOM1();}]],
    }, 
    {name	: "COM1 (25 kHz)", 
    aa_short: ["adjust", ["COM1 (25 kHz) stdby %.3f MHz", "/instrumentation/comm[0]/frequencies/standby-mhz", -0.025, 118, 136.975]],
    bb_short: ["adjust", ["COM1 (25 kHz) stdby %.3f MHz", "/instrumentation/comm[0]/frequencies/standby-mhz", 0.025, 118, 136.975]],
    cc_short: ["script", ["", func {
        var fSel = getprop("/instrumentation/comm[0]/frequencies/selected-mhz"); 
        var fstb = getprop("/instrumentation/comm[0]/frequencies/standby-mhz"); 
        setprop("/instrumentation/comm[0]/frequencies/selected-mhz", fstb);
        setprop("/instrumentation/comm[0]/frequencies/standby-mhz", fSel);
        freqDispCOM1();}]],
    cc_long: ["script", ["", func {
        freqDispCOM1();}]],
    }, 
    {name	: "COM2 (1 MHz)", 
    aa_short: ["adjust", ["COM2 (1 MHz) stdby %.3f MHz", "/instrumentation/comm[1]/frequencies/standby-mhz", -1, 118, 136.975]],
    bb_short: ["adjust", ["COM2 (1 MHz) stdby %.3f MHz", "/instrumentation/comm[1]/frequencies/standby-mhz", 1, 118, 136.975]],
    cc_short: ["script", ["", func {
        var fSel = getprop("/instrumentation/comm[1]/frequencies/selected-mhz"); 
        var fstb = getprop("/instrumentation/comm[1]/frequencies/standby-mhz"); 
        setprop("/instrumentation/comm[1]/frequencies/selected-mhz", fstb);
        setprop("/instrumentation/comm[1]/frequencies/standby-mhz", fSel);
        freqDispCOM2();}]],
    cc_long: ["script", ["", func {
        freqDispCOM2();}]],
    }, 
    {name	: "COM2 (25 kHz)", 
    aa_short: ["adjust", ["COM2 (25 kHz) stdby %.3f MHz", "/instrumentation/comm[1]/frequencies/standby-mhz", -0.025, 118, 136.975]],
    bb_short: ["adjust", ["COM2 (25 kHz) stdby %.3f MHz", "/instrumentation/comm[1]/frequencies/standby-mhz", 0.025, 118, 136.975]],
    cc_short: ["script", ["", func {
        var fSel = getprop("/instrumentation/comm[1]/frequencies/selected-mhz"); 
        var fstb = getprop("/instrumentation/comm[1]/frequencies/standby-mhz"); 
        setprop("/instrumentation/comm[1]/frequencies/selected-mhz", fstb);
        setprop("/instrumentation/comm[1]/frequencies/standby-mhz", fSel);
        freqDispCOM2();}]],
    cc_long: ["script", ["", func {
        freqDispCOM2();}]],
    }, 
    {name	: "NAV1 (1 MHz)", 
    aa_short: ["adjust", ["NAV1 (1 MHz) stdby %.3f MHz", "/instrumentation/nav[0]/frequencies/standby-mhz", -1, 108, 117.95]],
    bb_short: ["adjust", ["NAV1 (1 MHz) stdby %.3f MHz", "/instrumentation/nav[0]/frequencies/standby-mhz", 1, 108, 117.95]],
    cc_short: ["script", ["", func {
        var fSel = getprop("/instrumentation/nav[0]/frequencies/selected-mhz"); 
        var fstb = getprop("/instrumentation/nav[0]/frequencies/standby-mhz"); 
        setprop("/instrumentation/nav[0]/frequencies/selected-mhz", fstb);
        setprop("/instrumentation/nav[0]/frequencies/standby-mhz", fSel);
        freqDispNAV1();}]],
    cc_long: ["script", ["", func {
        freqDispNAV1();}]],
    }, 
    {name	: "NAV1 (50 kHz)", 
    aa_short: ["adjust", ["NAV1 (50 kHz) stdby %.3f MHz", "/instrumentation/nav[0]/frequencies/standby-mhz", -0.05, 108, 117.95]],
    bb_short: ["adjust", ["NAV1 (50 kHz) stdby %.3f MHz", "/instrumentation/nav[0]/frequencies/standby-mhz", 0.05, 108, 117.95]],
    cc_short: ["script", ["", func {
        var fSel = getprop("/instrumentation/nav[0]/frequencies/selected-mhz"); 
        var fstb = getprop("/instrumentation/nav[0]/frequencies/standby-mhz"); 
        setprop("/instrumentation/nav[0]/frequencies/selected-mhz", fstb);
        setprop("/instrumentation/nav[0]/frequencies/standby-mhz", fSel);
        freqDispNAV1();}]],
    cc_long: ["script", ["", func {
        freqDispNAV1();}]],
    }, 
    {name	: "NAV1 radial", 
    aa_short: ["adjust", ["NAV1 radial %u deg", "/instrumentation/nav[0]/radials/selected-deg", -1, 0, 359, 1]],
    bb_short: ["adjust", ["NAV1 radial %u deg", "/instrumentation/nav[0]/radials/selected-deg", 1, 0, 359, 1]],
    cc_long: ["script", ["", func {
        freqDispNAV1();}]],
    }, 
    {name	: "NAV2 (1 MHz)", 
    aa_short: ["adjust", ["NAV2 (1 MHz) stdby %.3f MHz", "/instrumentation/nav[1]/frequencies/standby-mhz", -1, 108, 117.95]],
    bb_short: ["adjust", ["NAV2 (1 MHz) stdby %.3f MHz", "/instrumentation/nav[1]/frequencies/standby-mhz", 1, 108, 117.95]],
    cc_short: ["script", ["", func {
        var fSel = getprop("/instrumentation/nav[1]/frequencies/selected-mhz"); 
        var fstb = getprop("/instrumentation/nav[1]/frequencies/standby-mhz"); 
        setprop("/instrumentation/nav[1]/frequencies/selected-mhz", fstb);
        setprop("/instrumentation/nav[1]/frequencies/standby-mhz", fSel);
        freqDispNAV2();}]],
    cc_long: ["script", ["", func {
        freqDispNAV2();}]],
    }, 
    {name	: "NAV2 (50 kHz)", 
    aa_short: ["adjust", ["NAV2 (50 kHz) stdby %.3f MHz", "/instrumentation/nav[1]/frequencies/standby-mhz", -0.05, 108, 117.95]],
    bb_short: ["adjust", ["NAV2 (50 kHz) stdby %.3f MHz", "/instrumentation/nav[1]/frequencies/standby-mhz", 0.05, 108, 117.95]],
    cc_short: ["script", ["", func {
        var fSel = getprop("/instrumentation/nav[1]/frequencies/selected-mhz"); 
        var fstb = getprop("/instrumentation/nav[1]/frequencies/standby-mhz"); 
        setprop("/instrumentation/nav[1]/frequencies/selected-mhz", fstb);
        setprop("/instrumentation/nav[1]/frequencies/standby-mhz", fSel);
        freqDispNAV2();}]],
    cc_long: ["script", ["", func {
        freqDispNAV2();}]],
    }, 
    {name	: "NAV2 radial", 
    aa_short: ["adjust", ["NAV2 radial %u deg", "/instrumentation/nav[1]/radials/selected-deg", -1, 0, 359, 1]],
    bb_short: ["adjust", ["NAV2 radial %u deg", "/instrumentation/nav[1]/radials/selected-deg", 1, 0, 359, 1]],
    cc_long: ["script", ["", func {
        freqDispNAV2();}]],
    }, 
    {name	: "ADF (10 kHz)", 
    aa_short: ["adjust", ["ADF (10 kHz) stdby %u kHz", "/instrumentation/adf/frequencies/standby-khz", -10, 190, 1750]],
    bb_short: ["adjust", ["ADF (10 kHz) stdby %u kHz", "/instrumentation/adf/frequencies/standby-khz", 10, 190, 1750]],
    cc_short: ["script", ["", func {
        var fSel = getprop("/instrumentation/adf/frequencies/selected-khz"); 
        var fstb = getprop("/instrumentation/adf/frequencies/standby-khz"); 
        setprop("/instrumentation/adf/frequencies/selected-khz", fstb);
        setprop("/instrumentation/adf/frequencies/standby-khz", fSel);
        freqDispADF();}]],
    cc_long: ["script", ["", func {
        freqDispADF();}]],
    }, 
    {name	: "ADF (1 kHz)", 
    aa_short: ["adjust", ["ADF (10 kHz) stdby %u kHz", "/instrumentation/adf/frequencies/standby-khz", -1, 190, 1750]],
    bb_short: ["adjust", ["ADF (10 kHz) stdby %u kHz", "/instrumentation/adf/frequencies/standby-khz", 1, 190, 1750]],
    cc_short: ["script", ["", func {
        var fSel = getprop("/instrumentation/adf/frequencies/selected-khz"); 
        var fstb = getprop("/instrumentation/adf/frequencies/standby-khz"); 
        setprop("/instrumentation/adf/frequencies/selected-khz", fstb);
        setprop("/instrumentation/adf/frequencies/standby-khz", fSel);
        freqDispADF();}]],
    cc_long: ["script", ["", func {
        freqDispADF();}]],
    }, 
    {name	: "ADF radial", 
    aa_short: ["adjust", ["ADF radial %u deg", "/instrumentation/adf/rotation-deg", -1, 0, 359, 1]],
    bb_short: ["adjust", ["ADF radial %u deg", "/instrumentation/adf/rotation-deg", 1, 0, 359, 1]],
    cc_long: ["script", ["", func {
        freqDispADF();}]],
    }, 
    {name	: "DME", 
    cc_long: ["script", ["", func {
        freqDispDME();}]],
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

