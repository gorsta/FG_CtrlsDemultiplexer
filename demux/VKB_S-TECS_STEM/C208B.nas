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
print("Loading c182s S-TECS_STEM dmux");

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

var SW12items = ["EngCtrls"];


var FltInstr = [ 
    {name	: "ALTimeter", 
    aa_short: ["adjust", ["ALTimeter: %.2f inHg", "instrumentation/altimeter/setting-inhg", -0.02, 27.5, 31]],
    bb_short: ["adjust", ["ALTimeter: %.2f inHg", "instrumentation/altimeter/setting-inhg", 0.02, 27.5, 31]],
    }, 
    {name	: "L flight panel light ", 
    aa_short: ["adjust", ["controls/lighting/flight-panel", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["controls/lighting/flight-panel", 0.05, 0, 1.0]],
    }, 
    {name	: "L flood light ", 
    aa_short: ["adjust", ["controls/lighting/flood", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["controls/lighting/flood", 0.05, 0, 1.0]],
    }, 
    {name	: "R flight panel light ", 
    aa_short: ["adjust", ["controls/lighting/flight-panel[1]", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["controls/lighting/flight-panel[1]", 0.05, 0, 1.0]],
    }, 
    {name	: "R flood light ", 
    aa_short: ["adjust", ["controls/lighting/flood[1]", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["controls/lighting/flood[1]", 0.05, 0, 1.0]],
    }, 
    {name	: "Lower panel/pedestal/overhead light ", 
    aa_short: ["adjust", ["controls/lighting/lwr-panel-ped-ovhd", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["controls/lighting/lwr-panel-ped-ovhd", 0.05, 0, 1.0]],
    }, 
    {name	: "Switch/circuit breaker panel light ", 
    aa_short: ["adjust", ["controls/lighting/sw-ckt-bkr-panel", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["controls/lighting/sw-ckt-bkr-panel", 0.05, 0, 1.0]],
    }, 
    {name	: "Engine instruments light ", 
    aa_short: ["adjust", ["controls/lighting/engine-instruments", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["controls/lighting/engine-instruments", 0.05, 0, 1.0]],
    }, 
    {name	: "Radio panel light ", 
    aa_short: ["adjust", ["controls/lighting/radio-panel", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["controls/lighting/radio-panel", 0.05, 0, 1.0]],
    }, 
    ];


var NavLights = [
    {name	: "L landing light", 
    cc_short: ["toggle", ["/controls/electric/leftldg-switch"]],
    }, 
    {name	: "Taxi light", 
    cc_short: ["toggle", ["/controls/electric/taxi-switch"]],
    }, 
    {name	: "R landing light", 
    cc_short: ["toggle", ["/controls/electric/rightldg-switch"]],
    }, 
    {name	: "Strobe ", 
    cc_short: ["toggle", ["/controls/electric/strobe-switch"]],
    }, 
    {name	: "Nav lights ", 
    cc_short: ["toggle", ["/controls/electric/nav-switch"]],
    },
    {name	: "Beacon ", 
    cc_short: ["toggle", ["/controls/electric/bcn-switch"]],
    }, 
    ];


