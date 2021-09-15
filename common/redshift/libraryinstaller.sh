#!/bin/bash
set -e
# Install Pip Module as Redshift Library. 
# It is based on the repository https://github.com/aws-samples/amazon-redshift-udfs

function usage {
	echo "./libraryinstaller.sh -m <module> -f <requirement_file>"
	echo
	echo "where <module> is the name of the Pip module to be installed. The next environment variables should be set:"
	echo "      AWS_S3_BUCKET is the location on S3 to upload the artifact to. Must be in format s3://bucket/prefix/"
	echo "      AWS_ACCESS_KEY_ID is the AWS access key attached to the Redshift cluster and has access to read from the s3 upload location"
	echo "      AWS_SECRET_ACCESS_KEY is the AWS secret access key attached to the Redshift cluster and has access to read from the s3 upload location"
	echo "      RS_CLUSTER_ID is the Redshift cluster you will deploy the function to"
	echo "      RS_DATABASE is the database you will deploy the function to"
	echo "      RS_USER is the db user who will create the function"
	echo "      RS_REGION is the region of the Redshift project"

	exit 0;
}

function checkDep {
	which $1 >> /dev/null
	if [ $? -ne 0 ]; then
		echo "Unable to find required dependency $1"
		exit -1
	fi
}

function notNull {
	if [ "$1x" == "x" ]; then
		echo $2
		exit -1
	fi
}

execQuery()
{
	output=`aws redshift-data execute-statement --cluster-identifier $1 --database $2 --db-user $3 --sql "$4" --region $5`
	id=`echo $output | jq -r .Id`

	status="SUBMITTED"
	while [ "$status" != "FINISHED" ] && [ "$status" != "FAILED" ]
	do
		sleep 1
		output=`aws redshift-data describe-statement --id $id --region $5`
		status=`echo $output | jq -r .Status`
		has_results=`echo $output | jq -r .HasResultSet`
	done

	if [ "$status" == "FAILED" ]; then
    	aws redshift-data describe-statement --id $id --region $5
    	return -1
  	else
    	# echo $id:$status
		if [ "$has_results" == "true" ]; then
			exec_output=`aws redshift-data get-statement-result --id $id --region $5`
		fi
  	fi
}

libraryInstalled()
{
	sql="SELECT * FROM pg_library WHERE name='$1';"
	execQuery $RS_CLUSTER_ID $RS_DATABASE $RS_USER "$sql" $RS_REGION
	echo $exec_output | jq -r '.Records | length'
}

libraryVersion()
{
	timestamp=$(date +%s)
	function="$1_$timestamp"
	sql="CREATE OR REPLACE FUNCTION public.$function() RETURNS VARCHAR IMMUTABLE AS \$\$
    	from $1 import __version__
    	return __version__
	\$\$ LANGUAGE plpythonu;"
	execQuery $RS_CLUSTER_ID $RS_DATABASE $RS_USER "$sql" $RS_REGION

	sql="SELECT public.$function();"
	execQuery $RS_CLUSTER_ID $RS_DATABASE $RS_USER "$sql" $RS_REGION
	library_version=`echo $exec_output | jq -r '.Records[0][0].stringValue'`

	sql="DROP FUNCTION public.$function();"
	execQuery $RS_CLUSTER_ID $RS_DATABASE $RS_USER "$sql" $RS_REGION

	echo $library_version
}

# make sure we have pip and the aws cli installed
checkDep "aws"
checkDep "pip"

# make sure we have wheel installed into pip
pip show wheel &> /dev/null
if [ $? != 0 ]; then
  echo "pip wheel not found. Please install with 'sudo pip install wheel'"
  exit -1
fi

# look up runtime arguments of the module name and the destination S3 Prefix
while getopts "m:f:h" opt; do
    case $opt in
        m) module="$OPTARG";;
        f) modules_file="$OPTARG";;
		h) usage;;
		\?) echo "Invalid option: -"$OPTARG"" >&2
			exit 1;;
		:) usage;;
	esac
done

# validate arguments
notNull "$AWS_S3_BUCKET" "Please provide an S3 bucket to store the library in using export AWS_S3_BUCKET=bucket"
notNull "$RS_DATABASE" "Please provide a Redshift database using export RS_DATABASE=database"
notNull "$RS_REGION" "Please provide a region using export RS_REGION=region"
notNull "$RS_USER" "Please provide a Redshift user using export RS_USER=user"
notNull "$RS_CLUSTER_ID" "Please provide a Redshift cluster using export RS_CLUSTER_ID=cluster"
notNull "$AWS_ACCESS_KEY_ID" "Please provide an AWS access key ID using export AWS_ACCESS_KEY_ID=key"
notNull "$AWS_SECRET_ACCESS_KEY" "Please provide an AWS secret access key ID using export AWS_SECRET_ACCESS_KEY=secret_key"

# check that the s3 prefix is in the right format
# starts with 's3://'
if ! [[ $AWS_S3_BUCKET == s3:\/\/* ]]; then
	echo "S3 Prefix must start with 's3://'"
	echo
	usage
fi

# extract modules from requirement file
modules_to_install=($module)
while IFS= read -r m v || [ -n "$m" ]
do
  modules_to_install+=($m)
done < $modules_file

# found the modules - install to a local hidden directory
for m in "${modules_to_install[@]}"
do
   : 
	echo "Installing $m in $RS_CLUSTER_ID"
	
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
	for depname in `basename -s .whl $files`
	do
		# get lowercase name
		depname=$(echo "$depname" | tr '[:upper:]' '[:lower:]')
		echo '> Library to be installed' $depname
		# check library installed
		library_installed=`libraryInstalled ${depname%%-*}`
		if [ $library_installed == 0 ]; then
			echo "Library not found in the cluster. Installing $depname"
			aws s3 cp "$TMPDIR/.$m/$depname.whl" "$AWS_S3_BUCKET$depname.zip"
			sql="CREATE OR REPLACE LIBRARY ${depname%%-*} LANGUAGE plpythonu FROM '$AWS_S3_BUCKET$depname.zip' WITH CREDENTIALS 'aws_access_key_id=$AWS_ACCESS_KEY_ID;aws_secret_access_key=$AWS_SECRET_ACCESS_KEY';"
	    	execQuery $RS_CLUSTER_ID $RS_DATABASE $RS_USER "$sql" $RS_REGION
		else
			# check library version
			library_version=`libraryVersion ${depname%%-*}`
			if [[ $depname == ${depname%%-*}-$library_version-* ]]; then
				echo "Library already installed"
			else
				echo "Library installed: $library_version. Installing $depname"
				sql="DROP LIBRARY ${depname%%-*};"
	    		execQuery $RS_CLUSTER_ID $RS_DATABASE $RS_USER "$sql" $RS_REGION
				aws s3 cp "$TMPDIR/.$m/$depname.whl" "$AWS_S3_BUCKET$depname.zip"
				sql="CREATE OR REPLACE LIBRARY ${depname%%-*} LANGUAGE plpythonu FROM '$AWS_S3_BUCKET$depname.zip' WITH CREDENTIALS 'aws_access_key_id=$AWS_ACCESS_KEY_ID;aws_secret_access_key=$AWS_SECRET_ACCESS_KEY';"
				execQuery $RS_CLUSTER_ID $RS_DATABASE $RS_USER "$sql" $RS_REGION
			fi
		fi
		
		if [ $? != 0 ]; then
			rm -Rf "$TMPDIR/.$m"
			exit $?
		fi
	done

	rm -Rf "$TMPDIR/"
done

exit 0