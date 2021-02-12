#!/usr/bin/env bash

# Validate environment variables DO_DEFAULT and DO_SECTION

if [[ "${DO_DEFAULT^^}" =~ ^(TRUE|FALSE)$ ]]
then
  echo "DO_DEFAULT = ${DO_DEFAULT}"
  if [ "${DO_DEFAULT^^}" == "TRUE" ]
  then
    USE_PROFILE=""
  fi
else
  echo "DO_DEFAULT must be TRUE or FALSE"
  exit -1
fi

if [ -z ${DO_SECTION+x} ]
then
  echo "DO_SECTION is unset"
else
  if [ -z "${DO_SECTION}" ]
  then
    echo "DO_SECTION set to nothing"
    unset DO_SECTION
  else
    grep "^\[${DO_SECTION}\]" ~/.aws/credentials 2>&1 > /dev/null
    if [ $? -ne 0 ]
    then
      echo "DO_SECTION set to ${DO_SECTION} but it does not exist"
      exit -2
    else
      echo "DO_SECTION set to ${DO_SECTION}"
      if [ "${DO_DEFAULT^^}" == "FALSE" ]
      then
        USE_PROFILE=" --profile ${DO_SECTION} "
      fi
    fi
  fi
fi

if [ "${DO_DEFAULT^^}" == "FALSE" ]
then
  if [ -z ${DO_SECTION+x} ]
  then
    echo "If DO_DEFAULT is FALSE, DO_SECTION must be set"
    exit -3
  fi
fi

# Get 1 existing access key
old_access_key=$(aws ${USE_PROFILE} iam list-access-keys --max-items 1|jq .AccessKeyMetadata[0].AccessKeyId|sed 's/"//g'|sed 's/\//\\\//g')

# Create new access/secret key, capture json output
new_access_key=$(aws ${USE_PROFILE} iam create-access-key)

# Get the new secret key from the json. Replace all / with \/ (so it does not mess up sed)
new_secret_key=$(echo "$new_access_key" | jq .AccessKey.SecretAccessKey | sed 's/"//g' | sed 's/\//\\\//g')

# Get the new access key. No need to escape, it is just numbers and letters
new_access_key=$(echo "$new_access_key" | jq .AccessKey.AccessKeyId | sed 's/"//g')

# Save the old aws credentials file
cp -f ~/.aws/credentials ~/.aws/credentials.1

## Use python to replace default and specific sections (including the access/secret keys)
if [ -z ${DO_SECTION+x} ]
then
  echo "DO_SECTION not defined"
else
  python3 /opt/python/configjsonconfig/configtojson.py -i ~/.aws/credentials > /tmp/old.credentials
  python3 /opt/python/configjsonconfig/upsertjson.py -i /tmp/old.credentials -s ${DO_SECTION} -k aws_access_key_id -v ${new_access_key} > /tmp/int.credentials
  python3 /opt/python/configjsonconfig/upsertjson.py -i /tmp/int.credentials -s ${DO_SECTION} -k aws_secret_access_key -v ${new_secret_key} > /tmp/new.credentials
  python3 /opt/python/configjsonconfig/jsontoconfig.py -i /tmp/new.credentials > ~/.aws/credentials
fi

if [ "${DO_DEFAULT^^}" == "TRUE" ]
then
  python3 /opt/python/configjsonconfig/configtojson.py -i ~/.aws/credentials > /tmp/old.credentials
  python3 /opt/python/configjsonconfig/upsertjson.py -i /tmp/old.credentials -s default -k aws_access_key_id -v ${new_access_key} > /tmp/int.credentials
  python3 /opt/python/configjsonconfig/upsertjson.py -i /tmp/int.credentials -s default -k aws_secret_access_key -v ${new_secret_key} > /tmp/new.credentials
  python3 /opt/python/configjsonconfig/jsontoconfig.py -i /tmp/new.credentials > ~/.aws/credentials
fi

# Sleep a little so aws has chance to finish creating keys before deleting the captured old key
sleep 30

# Delete the old key captured at the start
aws ${USE_PROFILE} iam delete-access-key --access-key-id ${old_access_key}
