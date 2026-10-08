use <fork-leg-parts.scad>
q1=0; q2=44.0486; q3=78.9786;
intersection() {
    only_forks(q1,q2,q3);
    union() { fork_leg_fixed(); rotate([q1,0,0]) fork_leg_j1(); }
}
