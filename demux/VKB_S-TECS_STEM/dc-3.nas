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
print("Loading dc-3 S-TECS_STEM dmux");

var hidCtrls = ["EN1", "EN2", "SW12"];

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

var EN1items = ["FltInstr"];

var EN2items = ["NavLights"];

var SW12items = ["EngCtrls"];

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

var EngCtrls = [
    {name	: "Fuel controls", 
    aa_long	: ["adjust", ["L fuel valve: %u", "/controls/fuel/left-valve", -1, 0, 5]],
    bb_long	: ["adjust", ["L fuel valve: %u", "/controls/fuel/left-valve", 1, 0, 5]],
    d_long	: ["adjust", ["R fuel valve: %u", "/controls/fuel/right-valve", -1, 0, 5]],
    e_long	: ["adjust", ["R fuel valve: %u", "/controls/fuel/right-valve", 1, 0, 5]],
    c_short	: ["toggle", ["L booster pump ", "/controls/fuel/tank/boost-pump"]],
    f_short	: ["toggle", ["R booster pump", "/controls/fuel/tank[1]/boost-pump"]],
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

