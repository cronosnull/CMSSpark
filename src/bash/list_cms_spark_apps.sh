#!/bin/bash
# This script will print a list of spark apps owned by cms users.

SPARK_APP_LIST="$(curl http://ithdp1101.cern.ch:18080/api/v1/applications?limit=2147483647)"
CMS_USERS_LIST="$(curl https://cms-cric-dev.cern.ch/api/accounts/user/query/?json | jq -r 'keys[] as $k | "\(.[$k].profiles[].login)"' |grep -v null)"

echo -n "$SPARK_APP_LIST"| jq -r '.[]|"\(.attempts[].sparkUser), \(.name)"' | grep -E "^($(echo -n "$CMS_USERS_LIST"|paste -d'|' -s)|cms.*), .*$"|sort|uniq -c