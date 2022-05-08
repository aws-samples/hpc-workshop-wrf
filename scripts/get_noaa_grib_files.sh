#!/bin/sh

source /shared/setup_env.sh

cd ${SHARED_DIR}/FORECAST/download

# Script for fast downloading of GFS data in grib2 format
# Select levels, variables and subregion of interest
#
## D A T E  #################################################################
##
if [ "$1" = help ] ; then
 echo "usage: $0 [HHHHMMGG] date of GFS run to be downloaded (last month only)"
 return
fi
if [ "$1" != "" ] ; then
 day=$1
else
 day=$(date +%Y%m%d)
fi

 echo "INPUT DATA: " $day $1

#############################################################################
# Definition of working directory
dirwork=$(pwd)

# Definition of local directory where files are stored
dirgfs=$dirwork/$day
mkdir $dirgfs

# Definition of forecast cycle and forecast hours
FCY='00'
fhrs='000 003 006 009 012 015 018 021 024 027 030 033 036 039 042 045 048 051 054 057 060 063 066 069 072 075 078 081 084 087 090 093 096 099 102 105 108 111 114 117 120'

rm -f $dirgfs/gfs_ok
cd $dirgfs
rm -f GRIBFILE* grib2file* full_grib_file

declare -A seq_to_sort=( ["000"]="AAA" ["003"]="AAB" ["006"]="AAC" ["009"]="AAD" ["012"]="AAE" ["015"]="AAF" ["018"]="AAG" ["021"]="AAH" ["024"]="AAI" ["027"]="AAJ" ["030"]="AAK" ["033"]="AAL" ["036"]="AAM" ["039"]="AAN" ["042"]="AAO" ["045"]="AAP" ["048"]="AAQ" ["051"]="AAR" ["054"]="AAS" ["057"]="AAT" ["060"]="AAU" ["063"]="AAV" ["066"]="AAW" ["069"]="AAX" ["072"]="AAY" ["075"]="AAZ" ["078"]="ABA" ["081"]="ABB" ["084"]="ABC" ["087"]="ABD" ["090"]="ABE" ["093"]="ABF" ["096"]="ABG" ["099"]="ABH" ["102"]="ABI" ["105"]="ABJ" ["108"]="ABK" ["111"]="ABL" ["114"]="ABM" ["117"]="ABN" ["120"]="ABO" )

for fhr in $fhrs
do

#20210630 Change in NOAA Attributes LANDN vs LAND and file path
#wget --quiet --no-check-certificate "https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t"$FCY"z.pgrb2.0p25.f"$fhr"&lev_0-0.1_m_below_ground=on&lev_0.1-0.4_m_below_ground=on&lev_0.4-1_m_below_ground=on&lev_1000_mb=on&lev_100_m_above_ground=on&lev_100_mb=on&lev_10_m_above_ground=on&lev_10_mb=on&lev_1-2_m_below_ground=on&lev_150_mb=on&lev_200_mb=on&lev_20_mb=on&lev_250_mb=on&lev_2_m_above_ground=on&lev_300_mb=on&lev_30-0_mb_above_ground=on&lev_30_mb=on&lev_350_mb=on&lev_400_mb=on&lev_450_mb=on&lev_500_mb=on&lev_50_mb=on&lev_550_mb=on&lev_600_mb=on&lev_650_mb=on&lev_700_mb=on&lev_70_mb=on&lev_750_mb=on&lev_800_mb=on&lev_80_m_above_ground=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&lev_mean_sea_level=on&lev_surface=on&var_ACPCP=on&var_APCP=on&var_DLWRF=on&var_DSWRF=on&var_HGT=on&var_LANDN=on&var_PRES=on&var_PRMSL=on&var_RH=on&var_SOILW=on&var_TMP=on&var_TSOIL=on&var_UGRD=on&var_ULWRF=on&var_USWRF=on&var_VGRD=on&var_WEASD=on&subregion=&leftlon=-25&rightlon=50&toplat=65&bottomlat=20&dir=%2Fgfs."$day"%2F"$FCY"" -O $dirgfs/GRIBFILE.${seq_to_sort[${fhr}]}  &
wget --quiet --no-check-certificate "https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t"$FCY"z.pgrb2.0p25.f"$fhr"&lev_0-0.1_m_below_ground=on&lev_0.1-0.4_m_below_ground=on&lev_0.4-1_m_below_ground=on&lev_1000_mb=on&lev_100_m_above_ground=on&lev_100_mb=on&lev_10_m_above_ground=on&lev_10_mb=on&lev_1-2_m_below_ground=on&lev_150_mb=on&lev_200_mb=on&lev_20_mb=on&lev_250_mb=on&lev_2_m_above_ground=on&lev_300_mb=on&lev_30-0_mb_above_ground=on&lev_30_mb=on&lev_350_mb=on&lev_400_mb=on&lev_450_mb=on&lev_500_mb=on&lev_50_mb=on&lev_550_mb=on&lev_600_mb=on&lev_650_mb=on&lev_700_mb=on&lev_70_mb=on&lev_750_mb=on&lev_800_mb=on&lev_80_m_above_ground=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&lev_mean_sea_level=on&lev_surface=on&var_ACPCP=on&var_APCP=on&var_DLWRF=on&var_DSWRF=on&var_HGT=on&var_LAND=on&var_PRES=on&var_PRMSL=on&var_RH=on&var_SOILW=on&var_TMP=on&var_TSOIL=on&var_UGRD=on&var_ULWRF=on&var_USWRF=on&var_VGRD=on&var_WEASD=on&subregion=&leftlon=-25&rightlon=50&toplat=65&bottomlat=20&dir=%2Fgfs."$day"%2F"$FCY"%2Fatmos" -O $dirgfs/GRIBFILE.${seq_to_sort[${fhr}]}  &
sleep 1

done

wait

#########################################

cat GRIBFILE*  > full_grib_file
length=$(wgrib2 full_grib_file|tail -1|awk -F":" '{ print $1}')
echo $length

if [ "$length" != "6839" ] ; then
        echo "Download failed"
        cd $dirwork
        exit 1
else
        cd $dirgfs
        echo 2 > gfs_ok
        rm -f full_grib_file
fi

echo "End of Download"
exit 0
