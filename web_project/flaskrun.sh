#!/bin/bash
#downloading the updates
sudo yum update -y
sudo yum install git -y
sudo yum install python3-pip -y
git clone https://github.com/tomerkul/myflaskproject.git
cd  /home/ec2-user/myflaskproject/sample-flask
pip install -r requirements.txt
FLASK_APP=app
flask run --host=0.0.0.0
