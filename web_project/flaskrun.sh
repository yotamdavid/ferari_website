#!/bin/bash
#downloading the updates
sudo yum update -y
sudo yum install git -y
sudo yum install python3-pip -y
cd  /home/ec2-user/ferari_website/web_project
pip install -r requirements.txt
FLASK_APP=app
flask run --host=0.0.0.0
