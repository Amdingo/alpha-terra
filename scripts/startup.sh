#!/bin/bash


sudo sh -c "sed 's/api_key:.*/api_key: 013b89b02aea432d319a66bbef66692d/; s/hostname:.*/hostname: alphastack-$branch_name-$build_count/' /home/alphastack/files/datadog.conf > /etc/dd-agent/datadog.conf"
sudo /etc/init.d/datadog-agent start
cd ~/alpha-stack
mkdir ~/test/
cp -p .babelrc ~/test/.babelrc
pm2 start ./build_tools/files/pm2.config.js
crontab -u alphastack -l | grep -v '@reboot installagent.sh' | crontab -u alphastack -
