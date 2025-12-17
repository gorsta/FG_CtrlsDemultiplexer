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
print("Loading default S-TECS_STEM dmux");

var hidCtrls = ["EN1"];

var EN1buttons = {
    26: "aa",
    27: "bb",
    30: "cc",
    };

var EN1items = ["FltInstr"];

var FltInstr = [ 
    {name	: "ALTimeter", 
    aa_short: ["adjust", ["ALTimeter: %.2f inHg", "instrumentation/altimeter/setting-inhg", -0.02, 27.5, 31]],
    bb_short: ["adjust", ["ALTimeter: %.2f inHg", "instrumentation/altimeter/setting-inhg", 0.02, 27.5, 31]],
    }, 
    ];
