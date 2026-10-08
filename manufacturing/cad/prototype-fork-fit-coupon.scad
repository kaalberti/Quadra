// MEC-163. Actual upper-fork interfaces, same side-on print orientation.
use <prototype-pitch-fork.scad>
$fn=48;
module fork_fit_coupon() {
    union() {
        intersection() {
            pitch_fork("upper");
            translate([-18,-17,-24]) cube([36,34,80]);
        }
        // Coupon-only connector, clear of horn/bearing/retainer interfaces.
        // This replaces the distant web for a smaller fit test, not a strength test.
        translate([10,-16,-23.2]) cube([6,8,78.2]);
    }
}
translate([0,0,16]) rotate([90,0,0]) fork_fit_coupon();
