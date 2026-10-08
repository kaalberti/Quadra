// Bench prototype layout; not a released chassis interface. mm.
j1_pitch_forward=85;
j1_pitch_floor_y=-18;
j1_pitch_vertical=0;
j1_foot_outward=j1_pitch_floor_y+50;
j1_carrier_back_y=-28;
j1_carrier_t=7;
j1_tab_z=-58;
j1_tab_hole_y=[-7,7];
j1_front_inner_x=50;
j1_rear_inner_x=-16.2;
function j1_point_to_world()=[[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]];
function pitch_point_to_world()=[[0,-1,0,j1_pitch_forward],[0,0,1,j1_pitch_floor_y],[1,0,0,j1_pitch_vertical],[0,0,0,1]];
