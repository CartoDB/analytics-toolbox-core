#!/bin/bash
set -e

# Serialize Pip Module as Redshift Library.
# It is based on the repository https://github.com/aws-samples/amazon-redshift-udfs

function checkDep {
	which $1 >> /dev/null
	if [ $? -ne 0 ]; then
		echo "Unable to find required dependency $1"
		exit -1
	fi
}

# make sure we have pip and the aws cli installed
checkDep "pip"

# make sure we have wheel installed into pip
pip show wheel &> /dev/null
if [ $? != 0 ]; then
  echo "pip wheel not found. Please install with 'sudo pip install wheel'"
  exit -1
fi

# look up runtime arguments of the module name and the destination S3 Prefix
while getopts "m:f:hs" opt; do
    case $opt in
        f) modules_file="$OPTARG";;
	esac
done

# extract modules from requirement file
modules_to_serialize=($module)
while IFS= read -r m v || [ -n "$m" ]; do
  modules_to_serialize+=($m)
done < $modules_file

# found the modules - install to a local hidden directory
for m in "${modules_to_serialize[@]}"; do
    redshift_default_libraries='numpy pandas python-dateutil pytz scipy six wsgiref';

	if [[ $redshift_default_libraries == *${m%%==*}* ]]; then
		echo "Skipping ${m%%==*}"
		echo "- Library already available in RedShift"
		continue
	fi

    echo "Serializing $m"

	TMPDIR=.tmp
	if [ ! -d "$TMPDIR" ]; then
	  mkdir $TMPDIR
	fi

	rm -Rf "$TMPDIR/.$m" &> /dev/null

	mkdir "$TMPDIR/.$m"

	pip wheel $m --wheel-dir "$TMPDIR/.$m" &> /dev/null
	if [ $? != 0 ]; then
		echo "Unable to find module $m in pip."
		rm -Rf "$TMPDIR/.$m"
		exit $?
	fi

	files=`ls ${TMPDIR}/.${m}/*.whl`
	for depname in `basename -s .whl $files`; do
		depname=$(echo "$depname" | tr '[:upper:]' '[:lower:]')
		if [[ $redshift_default_libraries == *${depname%%-*}* ]]; then
			echo "Skipping ${depname%%-*}"
			echo "- Library already available in RedShift"
			continue
		fi

		echo "- Library to be serialized: $depname"
		cp "$TMPDIR/.$m/$depname.whl" "build/libs/$depname.zip"

		if [ $? != 0 ]; then
			rm -Rf "$TMPDIR/.$m"
			exit $?
		fi
	done

	rm -Rf "$TMPDIR/"
done

exit 0