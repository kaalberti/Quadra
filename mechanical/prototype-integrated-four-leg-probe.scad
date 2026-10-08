include <integrated-four-leg-probe-data.scad>
pair_index=0;
pair=chassis_pairs[pair_index];
intersection() {
    multmatrix(pair[0]) import(pair[1]);
    multmatrix(pair[2]) import(pair[3]);
}
