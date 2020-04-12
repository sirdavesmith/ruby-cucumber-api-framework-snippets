#! /bin/bash
clear >$(tty)

for ((i=1;i<=$#;i++));
do
  if [ "${!i}" = "-t" ]; then ((i++))
    tag="--tags ${!i}";
    if [ "${!i}" != "@ep_tests" ] && [ $1 != "qe" ]; then
      tag="$tag --tags ~@ep_tests";
    fi

  elif [ "${!i}" = "--report" ]; then
    upload_results=true;

  elif [ "${!i}" = "--dry-run" ]; then
    dry_run=true;

  elif [ "${!i}" = "--access_token" ]; then ((i++))
    access_token=${!i};

  elif [ "${!i}" = "--feature" ]; then ((i++))
    feature=${!i};

  elif [ "${!i}" = "-h" ]; then
    help=true;
  fi
done;

if [[ -n $help ]]; then
  echo "This is the help menu :"
  echo "The first parameter is always the environment that matches the file 'env-<env name>.sh'"
  echo "--access_token => to pass in an access token for the script to use from the command line"
  echo "--feature => Specify a specific feature you would like to run"
  echo "-t => only run tests with a specific flag set"
  echo "-h => this help menu"
  echo " "
  echo "Some special features:"
  echo "-- 'companies_provisioned' => List of all companies in the given environment"
  echo "-- 'cleanup' => Removes all the test properties from the in the given environment"
fi

if [[ $1 == "jenkins" ]] || [[ $1 == "jenkins-junit" ]]; then
    echo "All necessary variables are supposed to be passed from parent script such as Jenkinsfile or Dockerfile"
elif [[ -a "./env-$1.sh" ]]; then
  echo "Setting up the '$1' environment variables"
  export TEST_ENV=$1
  . env-$1.sh
else
  echo "Environment unknown - $1 - please specify the environment as the first parameter on the command line, (local, qe, int, prod)"
  echo "And verify the file env-<env name>.sh exists (use env-example.sh as a base)"
  exit
fi

feature_order=(companies properties hosts)

if [[ $1 != "qe" ]]; then
  tag="$tag --tags ~@qe_only"
fi

if [[ -n "$feature" ]]; then
  echo "Running feature - $feature"
  case $feature in
  'companies_provisioned'|'properties_all')
    feature_order=($feature)
    result_label=$feature
    ;;
  'cleanup')
    feature_order=($feature)
    upload_results=false
    ;;
   *)
    feature_order=($feature)
  esac
fi

for i in ${feature_order[@]}; do
  ordered_list="$ordered_list features/$i.feature "
done

if [[ -n "$access_token" ]]; then
  export API_TOKEN=$access_token
else
  function jsonval {
      temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
      echo ${temp##*|}
  }

  json=`curl -X "POST" "$LOGIN_SERVICE_HOST/login_service/token/v1?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$USERPASS&scope=$CLIENT_SCOPES&grant_type=password&state=%7B%7D"`
  prop='access_token'
  access_token=`jsonval`

  export API_TOKEN=$access_token
fi

# Little status output to help debug
echo API_HOST: $ROOT_URL
echo API_TOKEN: $API_TOKEN
echo upload_results: $upload_results

if [[ $1 == "jenkins" ]]; then
  if [[ $upload_results == false ]]; then
      mkdir -p temp
      bundle exec cucumber -v -b -f json -o temp/automation-result.json -x $ordered_list $tag --tags ~@skip
  else
      mkdir -p results
      bundle exec cucumber -v -b -f json -o results/automation-result.json -x $ordered_list $tag --tags ~@skip
  fi
elif [[ $1 == "jenkins-junit" ]]; then
  mkdir -p results
  bundle exec cucumber -v -b -f junit -o results -f pretty -x $ordered_list $tag --tags ~@skip
else
  echo "bundle exec cucumber -v -b -f junit -o results -f pretty -x $ordered_list $tag --tags ~@skip"
  bundle exec cucumber -v -b -f junit -o results -f pretty -x $ordered_list $tag --tags ~@skip
fi
