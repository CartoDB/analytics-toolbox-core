#!/bin/bash

# Required variables
# GEONAMES_USERNAME
# GEONAMES_PASSWORD
# GEONAMES_OUTDIR
# GEONAMES_RELEASE
# GEONAMES_BUCKET
# BQ_PROJECT
# BQ_DATASET_PREFIX

PWD="$(pwd)"
WORKPATH=$PWD
export BQ_PREFIX="${BQ_PROJECT}.${BQ_DATASET_PREFIX}"

# Geonames config
GEONAMES_SERVER="https://www.geonames.org"
GEONAMES_COOKIE="geonames_cookie.txt"
GEONAMES_FILES=(airports.zip allCountries.zip alternateNamesV2.zip boundingbox.zip userTags.zip admin1CodesASCII.txt admin2Codes.txt countryInfo.txt featureCodes_en.txt iso-languagecodes.txt timeZones.txt unlocode-geonameid.zip)
GEONAMES_PREFIX=geonames_

# Authenticate and download files
function download () {
  # Get Session Cookie
  wget --save-cookies "$GEONAMES_OUTDIR/$GEONAMES_COOKIE" --quiet \
    --keep-session-cookies \
    --post-data 'username='$GEONAMES_USERNAME'&password='$GEONAMES_PASSWORD'&rememberme=1&srv=12' \
    --delete-after \
    "$GEONAMES_SERVER/servlet/geonames?"

  # Download file
  wget --load-cookies "$GEONAMES_OUTDIR/$GEONAMES_COOKIE" --quiet --show-progress \
    $1 --directory-prefix="$GEONAMES_OUTDIR/$GEONAMES_RELEASE/"

  # Check download success
  if [[ "$?" != 0 ]]; then
    echo "Error: Could not download file"
    exit 1
  fi
}

# Prepare downloaded files
function prepare () {
  cd $GEONAMES_OUTDIR/$GEONAMES_RELEASE
  if [[ $1 == *.zip ]]
  then
    unzip -u -o -q "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/$1"
    rm "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/$1"
  fi
  # Some of Geonames files need further preperation
  case "$1" in
    #iso-languagecodes.txt)
    #  mv "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/iso-languagecodes.txt" "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/iso-languagecodes.txt.original"
    #  tail -n +2 "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/iso-languagecodes.txt.original" > "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/iso-languagecodes.txt";
    #  rm "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/iso-languagecodes.txt.original"
    #  ;;
    countryInfo.txt)
      mv "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/countryInfo.txt" "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/countryInfo.txt.original";
      grep -v '^#' "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/countryInfo.txt.original" > "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/countryInfo.txt";
      rm "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/countryInfo.txt.original"
      ;;
    #timeZones.txt)
    #  mv "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/timeZones.txt" "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/timeZones.txt.original";
    #  tail -n +2 "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/timeZones.txt.original" > "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/timeZones.txt";
    #  rm "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/timeZones.txt.original"
    #  ;;
  esac
  cd $WORKPATH
  echo "| $1 has been downloaded";
}

# Download and prepare all premium und public files
function getFiles() {
  for GEONAMESFILE in "${GEONAMES_FILES[@]}"; do
    FILEPATH="$PWD/data/geonames/premium/$GEONAMES_RELEASE/$GEONAMESFILE"
    echo $GEONAMESFILE
    echo $FILEPATH
    # Check extracted file
    if test -f "$FILEPATH"; then
      echo "Found downloaded file FILEPATH"
      # Check if already prepared
    else
      GEONAMES_FILEURL="$GEONAMES_SERVER/premiumdata/$GEONAMES_RELEASE/$GEONAMESFILE"
      download $GEONAMES_FILEURL
      prepare $GEONAMESFILE
    fi
  done

  # Download public post codes file
  cd $GEONAMES_OUTDIR/$GEONAMES_RELEASE
  mkdir -p postcodes
  cd postcodes
  wget -N -q "https://download.geonames.org/export/zip/allCountries.zip" -O "postCodes.zip"
  unzip -u -q "postCodes.zip"
  mv -f "allCountries.txt" "../postCodes.txt"
  wget -N -q "https://download.geonames.org/export/zip/GB_full.csv.zip" -O "GB_full.zip"
  unzip -u -q "GB_full.zip"
  cat "GB_full.txt" >> "../postCodes.txt"
  wget -N -q "https://download.geonames.org/export/zip/CA_full.csv.zip" -O "CA_full.zip"
  unzip -u -q "CA_full.zip"
  cat "CA_full.txt" >> "../postCodes.txt"
  wget -N -q "https://download.geonames.org/export/zip/NL_full.csv.zip" -O "NL_full.zip"
  unzip -u -q "NL_full.zip"
  cat "NL_full.txt" >> "../postCodes.txt"
  cd ..
  rm -rf "postcodes"
}

# Add directories
mkdir -p $GEONAMES_OUTDIR
mkdir -p "$GEONAMES_OUTDIR/$GEONAMES_RELEASE"

echo "Downloading Geonames data"
getFiles

# Upload data to Google Storage
echo "LOADING allCountries into $GEONAMES_BUCKET"
gsutil cp "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/allCountries.txt" "$GEONAMES_BUCKET"
echo "LOADING alternateNamesV2 into $GEONAMES_BUCKET"
gsutil cp "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/alternateNamesV2.txt" "$GEONAMES_BUCKET"
echo "LOADING countryInfo into $GEONAMES_BUCKET"
gsutil cp "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/countryInfo.txt" "$GEONAMES_BUCKET"
echo "LOADING postCodes into $GEONAMES_BUCKET"
gsutil cp "$GEONAMES_OUTDIR/$GEONAMES_RELEASE/postCodes.txt" "$GEONAMES_BUCKET"

# Load into BigQuery tables
echo "LOADING ${GEONAMES_PREFIX}geonames table"
bq load \
    --source_format=CSV \
    --field_delimiter=tab \
    --quote= \
    --skip_leading_rows=0 \
    --project_id "$BQ_PROJECT" \
    --replace \
    "${BQ_DATASET_PREFIX}carto.${GEONAMES_PREFIX}geonames" \
    "${GEONAMES_BUCKET}allCountries.txt" \
geonameid:INTEGER,name:STRING,asciiname:STRING,alternatenames:STRING,latitude:FLOAT64,longitude:FLOAT64,fclass:STRING,fcode:STRING,country:STRING,cc2:STRING,admin1:STRING,admin2:STRING,admin3:STRING,admin4:STRING,population:INTEGER,elevation:INTEGER,dem:INTEGER,timezone:STRING,modification:DATE

echo "LOADING ${GEONAMES_PREFIX}geonames table"
bq load \
    --source_format=CSV \
    --field_delimiter=tab \
    --quote= \
    --skip_leading_rows=0 \
    --project_id "$BQ_PROJECT" \
    --replace \
    "${BQ_DATASET_PREFIX}carto.${GEONAMES_PREFIX}alternatenames" \
    "${GEONAMES_BUCKET}alternateNamesV2.txt" \
alternateNameId:INTEGER,geonameid:INTEGER,isolanguage:STRING,name:STRING,isPreferredName:BOOLEAN,isShortName:BOOLEAN,isColloquial:BOOLEAN,isHistoric:BOOLEAN,from:STRING,to:STRING

echo "LOADING ${GEONAMES_PREFIX}countryinfo table"
bq load \
    --source_format=CSV \
    --field_delimiter=tab \
    --quote= \
    --skip_leading_rows=51 \
    --project_id "$BQ_PROJECT" \
    --replace \
    "${BQ_DATASET_PREFIX}carto.${GEONAMES_PREFIX}countryinfo" \
    "${GEONAMES_BUCKET}countryInfo.txt" \
iso_alpha2:STRING,iso_alpha3:STRING,iso_numeric:STRING,fips_code:STRING,name:STRING,capital:STRING,areaInSqKm:FLOAT64,population:INTEGER,continent:STRING,top_level_domain:STRING,currency_code:STRING,currency_name:STRING,international_calling_code:STRING,postal_code_format:STRING,postal_code_regexp:STRING,languages:STRING,geonameid:INTEGER,neighbours:STRING,equivalent_fips_code:STRING

echo "LOADING ${GEONAMES_PREFIX}postalcodes table"
bq load \
    --source_format=CSV \
    --field_delimiter=tab \
    --quote= \
    --skip_leading_rows=51 \
    --project_id "$BQ_PROJECT" \
    --replace \
    "${BQ_DATASET_PREFIX}carto.${GEONAMES_PREFIX}postalcodes" \
    "${GEONAMES_BUCKET}postCodes.txt" \
country_code:STRING,postal_code:STRING,place_name:STRING,admin1_name:STRING,admin1_code:STRING,admin2_name:STRING,admin2_code:STRING,admin3_name:STRING,admin3_code:STRING,latitude:FLOAT64,longitude:FLOAT64,accuracy:INT64

SCRIPT_DIR=$( dirname "$0" )

echo "Create geocoding indices"
for f in "${SCRIPT_DIR}"/*.sql; do \
  echo 'Executing ' $f
  sed -e "s!@@BQ_PREFIX@@!$BQ_PREFIX!g" -e "s!@@GEONAMES_PREFIX@@!$GEONAMES_PREFIX!g" -e "s!@@GEONAMES_RELEASE@@!$GEONAMES_RELEASE!g" $f | bq --bigqueryrc=./.bigqueryrc query --use_legacy_sql=false
done

echo "Cleaning Up"
bq rm -f -t "${BQ_PROJECT}:${BQ_DATASET_PREFIX}carto.${GEONAMES_PREFIX}alternatenames"
bq rm -f -t "${BQ_PROJECT}:${BQ_DATASET_PREFIX}carto.${GEONAMES_PREFIX}geonames"
bq rm -f -t "${BQ_PROJECT}:${BQ_DATASET_PREFIX}carto.${GEONAMES_PREFIX}countryinfo"
bq rm -f -t "${BQ_PROJECT}:${BQ_DATASET_PREFIX}carto.${GEONAMES_PREFIX}postalcodes"
