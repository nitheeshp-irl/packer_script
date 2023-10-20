#!/bin/bash
exec > >(tee /var/log/user-data1.log|logger -t user-data -s 2>/dev/console) 2>&1
yum install nginx -y