#!/bin/bash
cd /
su - gsh
cd /scratch/gsh/obma144/user_projects/domains/obma/bin
sh /scratch/gsh/obma144/user_projects/domains/obma/bin/startNodeManager.sh &
sh /scratch/gsh/obma144/user_projects/domains/obma/bin/startWebLogic.sh &
