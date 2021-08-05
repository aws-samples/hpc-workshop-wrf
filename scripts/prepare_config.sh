#!/bin/bash
source /shared/setup_env.sh

WPSWORK=${TARGET_DIR}/preproc
WRFWORK=${TARGET_DIR}/run
GEOG_DIR=${TARGET_DIR}/../geog

cd ${SHARED_DIR}/FORECAST/download

ulimit -s unlimited

NP=$(ls /sys/class/cpuid/ | wc -l)

NP=$(( $NP / 2 ))
echo "Parallel Process $NP"

#Set-up current date as processing date variables
DATA=$(date +%Y%m%d)'00'
DATINA=$(date +%Y%m%d)


run='00'
dt='1'
ndom='1'

#Models Parameters
#Simulation Elapsed time
days1=2
hrs1=0
#Hours
f1=48
#Simulation Start hours
sh1=00
#Simulation End hours
eh1=00
#BC Intervall
bc1=10800
#Timestep 
t1=10
#Timestep to grids ratio
rt=3
#Feedback (1-way =0 ; 2-ways =1 )
fdbck=0
#Smoothing
smooth=0


#Grid Definition 460 x 270 x 35
nx1=460
ny1=270
nz1=35
dx1=10000

#Metgrid Levels and VTable
metlev=27
Vtab=$WPS_DIR'/ungrib/Variable_Tables/Vtable.GFS'


#Compute derived variables
sdate=$(date -d "$DATINA" +%Y%m%d)
sy=$(echo $sdate | awk '{print substr($1,1,4)}')
sm=$(echo $sdate | awk '{print substr($1,5,2)}')
sd=$(echo $sdate | awk '{print substr($1,7,2)}')

fdate=$(date -d "$DATINA  $days1 days" +%Y%m%d)

ey=$(echo $fdate | awk '{print substr($1,1,4)}')
em=$(echo $fdate | awk '{print substr($1,5,2)}')
ed=$(echo $fdate | awk '{print substr($1,7,2)}')

datenest=$(date -d "$DATINA" +%Y)'-'$(date -d "$DATINA" +%m)'-'$(date -d "$DATINA" +%d)'_'$sh1':00:00'
dateend=$(date -d "$fdate" +%Y)'-'$(date -d "$fdate" +%m)'-'$(date -d "$fdate" +%d)'_'$eh1':00:00'

ctlname1='WRF_FAT_'$DATA'.ctl'
grbname1='WRF_FAT_'$DATA'.grb'



#Preparing WRF and WPS config files

cd $WRFWORK

rm -f wrfout*
rm -f rsl.*

cat<<EOF >namelist.input
 &time_control
 run_days                            = $days1,
 run_hours                           = $hrs1,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = $sy, 
 start_month                         = $sm,
 start_day                           = $sd,
 start_hour                          = $sh1,
 start_minute                        = 00,
 start_second                        = 00,
 end_year                            = $ey,
 end_month                           = $em,
 end_day                             = $ed,
 end_hour                            = $eh1,
 end_minute                          = 00,
 end_second                          = 00,
 interval_seconds                    = $bc1,
 input_from_file                     = .true.,
 fine_input_stream                   = 2,
 history_interval                    = 60,
 frames_per_outfile                  = 1,
 restart                             = .false.,
 restart_interval                    = 15000,
 io_form_history                     = 2,
 io_form_restart                     = 2,
 io_form_input                       = 2,
 io_form_boundary                    = 2,
 io_form_auxinput2                   = 2,
 debug_level                         = 0
 /

 &domains
 time_step                = $t1,
 time_step_fract_num      = 0,
 time_step_fract_den      = 1,
 max_dom                  = $ndom,
 e_we                     = $nx1,
 e_sn                     = $ny1,
 e_vert                   = $nz1,
 p_top_requested          = 5000,
 num_metgrid_levels       = $metlev,
 num_metgrid_soil_levels  = 4,
 dx                       = $dx1,
 dy                       = $dx1,
 grid_id                  = 1,
 parent_id                = 1,
 i_parent_start           = 1,
 j_parent_start           = 1,
 parent_grid_ratio        = 1,
 parent_time_step_ratio   = 1,
 use_adaptive_time_step   = .false.,
 step_to_output_time      = .true.,
 target_cfl               = 1.2,
 max_step_increase_pct    = 10, 
 starting_time_step       = -1, 
 max_time_step            = 120,
 min_time_step            = -1, 
 adaptation_domain        = 3,
 feedback                 = $fdbck,
 numtiles                 = 8,
 smooth_option            = $smooth,
 /

 &physics
 mp_physics                          = 4,
 ra_lw_physics                       = 1,
 ra_sw_physics                       = 2,
 radt                                = 10,
 sf_sfclay_physics                   = 2,
 sf_surface_physics                  = 2,
 bl_pbl_physics                      = 2,
 bldt                                = 0,
 cu_physics                          = 5,
 cudt                                = 0,
 isfflx                              = 1,
 ifsnow                              = 0, 
 icloud                              = 1,
 surface_input_source                = 1,
 num_soil_layers                     = 4,
 maxiens                             = 1,
 maxens                              = 3,
 maxens2                             = 3,
 maxens3                             = 16,
 ensdim                              = 144,
 /

 &fdda
 /

&dynamics
 w_damping                           = 0,
 diff_opt                            = 1,
 km_opt                              = 4,
 diff_6th_opt                        = 0,
 diff_6th_factor                     = 0.12,
 base_temp                           = 290.,
 damp_opt                            = 0,
 zdamp                               = 5000.,
 dampcoef                            = 0.2,
 khdif                               = 0,
 kvdif                               = 0,
 non_hydrostatic                     = .true.,
 moist_adv_opt                       = 1,
 scalar_adv_opt                      = 1,
 / 

 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true.,
 periodic_x                          = .false.,
 symmetric_xs                        = .false.,
 symmetric_xe                        = .false.,
 open_xs                             = .false.,
 open_xe                             = .false.,
 periodic_y                          = .false.,
 symmetric_ys                        = .false.,
 symmetric_ye                        = .false.,
 open_ys                             = .false.,
 open_ye                             = .false.,
 nested                              = .false.,
 /

 &grib2
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /
EOF

 
cd $WPSWORK
rm -f GRIBFILE*

cat<<EOF >namelist.wps
&share
 wrf_core = 'ARW',
 max_dom = $ndom,
 start_date = '$datenest', 
 end_date   = '$dateend', 
 interval_seconds = $bc1,
 io_form_geogrid = 2,
 opt_output_from_geogrid_path = '$WPSWORK/',
 debug_level = 0,
/

&geogrid
 parent_id         = 1,
 parent_grid_ratio = 1,
 i_parent_start    = 1,
 j_parent_start    = 1,
 e_we          = $nx1,
 e_sn          = $ny1,
 geog_data_res = '5m',
 dx = $dx1,
 dy = $dx1,
 map_proj =  'lambert',
 ref_lat   = 40,
 ref_lon   = 14,
 truelat1  = 40,
 truelat2  = 40,
 stand_lon = 14,
 geog_data_path = '$GEOG_DIR/',
 opt_geogrid_tbl_path = '$WPSWORK/'
/

&ungrib
 out_format = 'WPS'
 prefix = 'FILE'
/

&metgrid
 fg_name = './FILE',
 io_form_metgrid = 2,
 opt_output_from_metgrid_path = '$WPSWORK/',
 opt_metgrid_tbl_path         = '$WPSWORK/',
/


&mod_levs
 press_pa = 201300 , 200100 , 100000 ,
             95000 ,  90000 ,
             85000 ,  80000 ,
             75000 ,  70000 ,
             65000 ,  60000 ,
             55000 ,  50000 ,
             45000 ,  40000 ,
             35000 ,  30000 ,
             25000 ,  20000 ,
             15000 ,  10000 ,
              5000 ,   1000
 /

&domain_wizard
 grib_data_path = 'null',
 grib_vtable = 'null',
 dwiz_name    =euro12
 dwiz_desc    =
 dwiz_user_rect_x1 =915
 dwiz_user_rect_y1 =156
 dwiz_show_political =true
 dwiz_center_over_gmt =true
 dwiz_latlon_space_in_deg =10
 dwiz_latlon_linecolor =-8355712
 dwiz_map_scale_pct =25
 dwiz_map_vert_scrollbar_pos =0
 dwiz_map_horiz_scrollbar_pos =743
 dwiz_gridpt_dist_km =12.0
 dwiz_mpi_command =
 dwiz_tcvitals =null
/
EOF
