##
# Numbering convention for buttons
#---------------------------------
# Use the button number of the xml binding  e.g. in the throttle file:
# <button n="15"> 
# <script>bdn(15);</script>
# To avoid number collisions add 100 to the numbers of the next xml file, i.e.
# in the joystick file:
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
print("Loading C208B S-TECS_STEM dmux");

var hidCtrls = ["EN1", "EN2"];

var EN1buttons = {
    26: "aa",
    27: "bb",
    30: "cc",
    };

var EN2buttons = {
    28: "aa",
    29: "bb",
    31: "cc",
    };

var SW12buttons = {
    15: "a",
    17: "b",
    18: "d",
    20: "e",
    };

var EN1items = ["FltInstr"];

var EN2items = ["NavLights"];

#var SW12items = ["EngCtrls"];


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
    
    {name	: "L flight panel light %.2f", 
    prop	   : "/controls/lighting/flight-panel", 
    aa_short: ["adjust", [-0.05, 0, 1.0]],
    bb_short: ["adjust", [0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    {name	: "L flood light %.2f", 
    prop	   : "/controls/lighting/flood", 
    aa_short: ["adjust", [-0.05, 0, 1.0]],
    bb_short: ["adjust", [0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    {name	: "R flight panel light %.2f", 
    prop	   : "/controls/lighting/flight-panel[1]", 
    aa_short: ["adjust", [-0.05, 0, 1.0]],
    bb_short: ["adjust", [0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    {name	: "R flood light %.2f", 
    prop	   : "/controls/lighting/flood[1]", 
    aa_short: ["adjust", [-0.05, 0, 1.0]],
    bb_short: ["adjust", [0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    {name	: "Lower panel-pedestal-overhead light %.2f", 
    prop	   : "/controls/lighting/lwr-panel-ped-ovhd", 
    aa_short: ["adjust", [-0.05, 0, 1.0]],
    bb_short: ["adjust", [0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    {name	: "Switch&circuit breaker panel light %.2f", 
    prop	   : "/controls/lighting/sw-ckt-bkr-panel", 
    aa_short: ["adjust", [-0.05, 0, 1.0]],
    bb_short: ["adjust", [0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    {name	: "Engine instruments light %.2f", 
    prop	   : "/controls/lighting/engine-instruments", 
    aa_short: ["adjust", [-0.05, 0, 1.0]],
    bb_short: ["adjust", [0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    {name	: "Radio panel light %.2f", 
    prop	   : "/controls/lighting/radio-panel", 
    aa_short: ["adjust", [-0.05, 0, 1.0]],
    bb_short: ["adjust", [0.05, 0, 1.0]],
    cc_long : ["popup"],
    }, 
    
    ];


var NavLights = [

    {name	: "L landing light %s;off|on", 
    prop	   : "/controls/electric/leftldg-switch", 
    cc_short: ["toggle"],
    cc_long : ["popup"],
    }, 
    
    {name	: "Taxi light %s;off|on", 
    prop	   : "/controls/electric/taxi-switch", 
    cc_short: ["toggle"],
    cc_long : ["popup"],
    }, 
    
    {name	: "R landing light %s;off|on", 
    prop	   : "/controls/electric/rightldg-switch", 
    cc_short: ["toggle"],
    cc_long : ["popup"],
    }, 
    
    {name	: "Strobe %s;off|on", 
    prop	   : "/controls/electric/strobe-switch", 
    cc_short: ["toggle"],
    cc_long : ["popup"],
    }, 
    
    {name	: "Nav lights %s;off|on", 
    prop	   : "/controls/electric/nav-switch", 
    cc_short: ["toggle"],
    cc_long : ["popup"],
    }, 
    
    {name	: "Beacon %s;off|on", 
    prop	   : "/controls/electric/bcn-switch", 
    cc_short: ["toggle"],
    cc_long : ["popup"],
    }, 
    
    ];


