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

var hidCtrls = ["EN1", "EN2", "SW12"];

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

var EN2items = ["PanelSwitches_L_side"];

var SW12items = ["EngCtrls"];

var FltInstr = [ 
    {name	: "ALTimeter", 
    aa_short: ["adjust", ["ALTimeter: %.2f inHg", "instrumentation/altimeter/setting-inhg", -0.02, 27.5, 31]],
    bb_short: ["adjust", ["ALTimeter: %.2f inHg", "instrumentation/altimeter/setting-inhg", 0.02, 27.5, 31]],
    }, 
    {name	: "Instr light", 
    aa_short: ["adjust", ["Dec instr light", "controls/lighting/instrument-lights-norm", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["Inc instr light", "controls/lighting/instrument-lights-norm", 0.05, 0, 1.0]],
    }, 
    {name	: "Radio light", 
    aa_short: ["adjust", ["Dec radio light", "controls/lighting/radio-lights-norm", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["Inc radio light", "controls/lighting/radio-lights-norm", 0.05, 0, 1.0]],
    }, 
    {name	: "Pedestal light", 
    aa_short: ["adjust", ["Dec pedestal light", "controls/lighting/pedestal-lights-norm", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["Inc pedestal light", "controls/lighting/pedestal-lights-norm", 0.05, 0, 1.0]],
    }, 
    {name	: "Glareshield light", 
    aa_short: ["adjust", ["Dec glareshield light", "controls/lighting/glareshield-lights-norm", -0.05, 0, 1.0]],
    bb_short: ["adjust", ["Inc glareshield light", "controls/lighting/glareshield-lights-norm", 0.05, 0, 1.0]],
    }, 
    ];

var PanelSwitches_L_side = [
    {name	: "Fuel pump ", 
    cc_short: ["toggle", ["/controls/engines/engine/fuel-pump"]],
    }, 
    {name	: "Beacon ", 
    cc_short: ["toggle", ["/controls/lighting/beacon"]],
    }, 
    {name	: "Landing light", 
    cc_short: ["toggle", ["/controls/lighting/landing-lights"]],
    }, 
    {name	: "Taxi light", 
    cc_short: ["toggle", ["/controls/lighting/taxi-light"]],
    }, 
    {name	: "Nav lights ", 
    cc_short: ["toggle", ["/controls/lighting/nav-lights"]],
    },
    {name	: "Strobe ", 
    cc_short: ["toggle", ["/controls/lighting/strobe"]],
    }, 
    {name	: "Pitot ht ", 
    cc_short: ["toggle", ["/controls/anti-ice/pitot-heat"]],
    }, 
    ];

var EngCtrls = [
    {name	: "Magnetos, starter and fuel", 
    a_long	: ["adjust", ["Magnetos:OFF;R;L;BOTH", "/controls/switches/magnetos", -1, 0, 3]],
    b_long	: ["adjust", ["Magnetos:OFF;R;L;BOTH", "/controls/switches/magnetos", 1, 0, 3]],
    
    b_down : ["script", ["", func {if (getprop("/controls/switches/magnetos")==3) {
		             setprop("/controls/switches/starter", 1);
		             gui.popupTip("Starter", 0.5); 
		             # Display popup only when the starter is activated
		             }
		        }]],
      b_up : ["script", ["", func {if (getprop("/controls/switches/magnetos")==3) {
		             setprop("/controls/switches/starter", 0);
		             }
		        }]],

    d_long	: ["adjust", ["Tanks:OFF;RIGHT;BOTH;LEFT", "/controls/switches/fuel_tank_selector", -1, 0, 3, 1]],
    e_long	: ["adjust", ["Tanks OFF;Tank RIGHT;Tanks BOTH;Tank LEFT", "/controls/switches/fuel_tank_selector", 1, 0, 3, 1]],
    # Could not figure out how to involve the animation of the fuel tank selector
    },
    ];

