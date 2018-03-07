#!/bin/sh

git --git-dir=/opt/alpha-stack/.git pull

npm i --only=prod --prefix /opt/alpha-stack

npm run vendor --prefix /opt/alpha-stack

npm run build --prefix /opt/alpha-stack
