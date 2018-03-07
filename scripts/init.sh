#!/bin/bash

IFS='/' read -r -a array <<< "${branch}"

export branch_name="${array[2]}"
export env="production"
export APIPORT="3030"
export PORT="8000"

segment () {
  echo
  echo "############################################################"
  echo $1
  echo "############################################################"
  echo
}

echo "############################################################"
echo "############################################################"
echo "env is $env"
echo "S3 path is s3://${s3path}"
echo "############################################################"
echo "############################################################"

segment "creating alpha-stack dir"
mkdir alpha-stack
ls
segment "downloading and unzipping artifacts"
aws s3 cp s3://${s3path} .
unzip -q integration-build-artifacts.zip -d alpha-stack
echo

segment "Moving to alpha-stack dir"

cd ~/alpha-stack
ls -lrt

segment "Installing production node_modules"

cp -r ~/prod_node_modules ./node_modules
npm i --only=prod

segment "complete"

segment "installing datadog agent"

sudo apt-get install apt-transport-https
sudo sh -c "echo 'deb https://apt.datadoghq.com/ stable 6' > /etc/apt/sources.list.d/datadog.list"
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 382E94DE
sudo apt-get update
sudo apt-get install datadog-agent
touch /home/alphastack/scripts/startup.sh && chmod +x /home/alphastack/scripts/startup.sh
tee /home/alphastack/scripts/startup.sh <<EOF
#!/bin/bash

cd ~/alpha-stack
python environment_hostname_config.py

source ~/.profile

sudo sh -c "sed 's/api_key:.*/api_key: 013b89b02aea432d319a66bbef66692d/'; \
  's/# hostname: mymachine.mydomain/hostname: ${sub-domain:dev}-alphastack/'; \
  's/# process_config:/process_config/'; \
  's/#   enabled: "true"/  enabled: "true"/; \
  /etc/datadog-agent/datadog.yaml.example > /etc/datadog-agent/datadog.yaml"
sudo systemctl restart datadog-agent.service
crontab -u alphastack -l | grep -v '@reboot startup.sh' | crontab -u alphastack -

EOF
{ crontab -l -u alphastack; echo '@reboot /home/alphastack/scripts/startup.sh'; } | crontab -u alphastack -

# segment "configuring services"

 cd ~/alpha-stack
 pm2 start ./build_tools/files/pm2.config.js
 sudo env PATH=$PATH:/usr/local/nvm/v8.9.4/bin /home/alphastack/.npm-global/lib/node_modules/pm2/bin/pm2 startup systemd -u alphastack --hp /home/alphastack
 pm2 stop ./build_tools/files/pm2.config.js

# example of replacing hostname!
##
## sudo sh -c "sed 's/api_key:.*/api_key: 013b89b02aea432d319a66bbef66692d/; s/hostname:.*/hostname: ${sub_domain:-dev}-alphastack-${branch_name:-dev}/' /home/alphastack/files/datadog.conf > /etc/dd-agent/datadog.conf"
##
