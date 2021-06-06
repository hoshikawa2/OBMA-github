<<<<<<< HEAD
# Deploying OBMA in OCI OKE with ORACLE VISUAL BUILDER STUDIO

Observations:

* Layers for Containerization
   * Fusion
   * OBMA
   * WebLogic Configuration
   * Database Configuration
   * Flexcube Servers

### For manual deployment (Simple way)

    If you already have a Pod/Deployment:

    kubectl delete deployment obma144-deployment
   
    ------
  
    Or if you want to create a new Deployment:
 
    kubectl apply -f obma144.yaml
    
    Remember: Change the JDBC parameters inside obma144.yaml

### Building OBMA Docker Image


    sudo docker run --name integrated144 -h "fcubs.oracle.com" -p 7001-7020:7001-7020 -it "iad.ocir.io/id3kyspkytmr/oraclefmw-infra_with_patch:12.2.1.4.0" /bin/bash

### flexcube.sh

This bash script loads the Flexcube artifacts inside docker image

    flexcube.sh file:
    
    su - gsh
    cd /
    wget "https://objectstorage.us-ashburn-1.oraclecloud.com/p/Y86rX7N3n5m39BuMsxkRY-uP5O1ha2ZVEOv-oazTmA6MDf0XNtki8gGymsvYvPEf/n/id3kyspkytmr/b/bucket_banco_conceito/o/kernel144_11Mar21.zip"
    unzip -o kernel144_11Mar21.zip -d /
    cd /scratch/gsh/kernel144/user_projects/domains/integrated/bin

### Merge Fusion Docker Image with Flexcube

    Execute docker image with:
    sudo docker start integrated144
    
Go to Weblogic Admin Server and change machine-1 Listen Address:

![weblogic-machine-1.png](https://github.com/hoshikawa2/repo-image/blob/master/weblogic-machine-1.png?raw=true)


Then execute:

    sudo docker cp flexcube.sh integrated144:/

    sudo docker exec integrated144 /bin/bash -c "sh /flexcube.sh"

Test if docker image is OK:

    sudo docker exec integrated144 /bin/bash -c "sh /scratch/gsh/kernel144/user_projects/domains/integrated/bin/startNodeManager.sh &"

    sudo docker exec integrated144 /bin/bash -c "sh /scratch/gsh/kernel144/user_projects/domains/integrated/bin/startWebLogic.sh &"
    
And for push the docker image to OCIR:

    sudo docker stop integrated144

    sudo docker commit integrated144 flexcube/integrated144:v1
    sudo docker tag flexcube/integrated144:v1 iad.ocir.io/id3kyspkytmr/flexcube/integrated144:v1
    sudo docker push iad.ocir.io/id3kyspkytmr/flexcube/integrated144:v1

The Flexcube team needs to build the image with:

    Fusion Middleware
    Flexcube (/scratch/gsh/...)

### Automating the deployment for OKE

#### Change Database Password to AES format with weblogic.security.Encrypt

    cd /scratch/gsh/oracle/wlserver/server/bin
    .  ./setWLSEnv.sh
    java -Dweblogic.RootDirectory=/scratch/gsh/kernel144/user_projects/domains/integrated  weblogic.security.Encrypt <Database Password>

#### Environment Variables

    $JDBCPassword: {AES256}7kfaltdnEBjKNq.......RIU0IcLOynq1ee8Ib8=     (In AES format*)
    $JDBCString: <JDBC Connection String>

#
    OCI CLI Install
    Unix Shell

    #  Prepare for kubectl from OCI CLI
    mkdir -p $HOME/.kube
    oci ce cluster create-kubeconfig --cluster-id ocid1.cluster.oc1.iad.aaaaaaaaae3tmyldgbtgmyjrmyzdeytbhazdmmbrgfstmntdgc2wmzrxgbrt --file $HOME/.kube/config --region us-ashburn-1 --token-version 2.0.0
    export KUBECONFIG=$HOME/.kube/config
    # Deploy integrated144
    kubectl config view
    kubectl get nodes
    kubectl replace -f integrated144-devops.yaml --force
    kubectl rollout status deployment integrated144-deployment
    # Set Variables
    export JDBCString=$JDBCString
    export JDBCPassword=$JDBCPassword
    #Load initialize script 
    kubectl exec $(kubectl get pod -l app=integrated144 -o jsonpath="{.items[0].metadata.name}") -- /bin/bash -c "wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/0YTvKvrmiae_ZUoq4ft48Wt3eQfZRCYlrIgjrzADHdJfkkyfkr_4lA4PNF8MrOCj/n/id3kyspkytmr/b/bucket_banco_conceito/o/initializeConfig.sh"
    #Run Automated process to up Weblogic and Applications
    kubectl exec $(kubectl get pod -l app=integrated144 -o jsonpath="{.items[0].metadata.name}") -- /bin/bash -c "sh initializeConfig.sh $JDBCString $JDBCPassword"

# 

    YAML (~/Dropbox/Oracle/MyWork/DevOps/flexcube/integrated144.yaml)

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: integrated144-deployment
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: integrated144
      template:
        metadata:
          labels:
            app: integrated144
        spec:
          hostname: integrated144
          hostAliases:
          - ip: "127.0.0.1"
            hostnames:
            - "fcubs.oracle.com"
          containers:
          - name: integrated144
            image: iad.ocir.io/id3kyspkytmr/flexcube/integrated144:v1
            command: [ "/bin/sh", "-c"]
            args:
              [ "while true; do sleep 30; done;" ]
    #         [ "sleep 180; cd /; wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/0YTvKvrmiae_ZUoq4ft48Wt3eQfZRCYlrIgjrzADHdJfkkyfkr_4lA4PNF8MrOCj/n/id3kyspkytmr/b/bucket_banco_conceito/o/initializeConfig.sh; sh initializeConfig.sh jdbc:oracle:thin:@0.0.0.0:1521/DB0401_iad15g.subnet00000015.vcn040000015.oraclevcn.com {AES256}7kfaltdnEBjKNqdHFhUn7o10xxxxxxxxxxxxxxxxxxxxxxxxxDRIU0IcLOynq1ee8Ib8=; while true; do sleep 30; done;" ]
            ports:
            - name: port7001
              containerPort: 7001
            - name: port7002
              containerPort: 7002
            - name: port7003
              containerPort: 7003
            - name: port7004
              containerPort: 7004
            - name: port7005
              containerPort: 7005
            - name: port7006
              containerPort: 7006
            - name: port7007
              containerPort: 7007
            - name: port7008
              containerPort: 7008
            - name: port7009
              containerPort: 7009
            - name: port7010
              containerPort: 7010
            - name: port7011
              containerPort: 7011
            - name: port7012
              containerPort: 7012
            - name: port7013
              containerPort: 7013
            - name: port7014
              containerPort: 7014
            - name: port7015
              containerPort: 7015
            - name: port7016
              containerPort: 7016
            - name: port7017
              containerPort: 7017
            - name: port7018
              containerPort: 7018
            - name: port7019
              containerPort: 7019
            - name: port7020
              containerPort: 7020
            - name: port5556
              containerPort: 5556
    #        livenessProbe:
    #          httpGet:
    #            path: /console
    #            port: 7001
    #          initialDelaySeconds: 3000
    #          timeoutSeconds: 30
    #          periodSeconds: 300
    #          failureThreshold: 3
            volumeMounts:
              - name: data
                mountPath: /tmp
                readOnly: false
            resources:
              requests:
                cpu: "4"
                memory: "32Gi"
              limits:
                cpu: "4"
                memory: "32Gi"
          restartPolicy: Always
          volumes:
            - name: data
              persistentVolumeClaim:
                claimName: flexcubeclaim
          imagePullSecrets:
          - name: ocirsecret
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: integrated144-service
      labels:
        app: integrated144
    spec:
      selector:
        app: integrated144
      ports:
        - port: 7004
          targetPort: 7004
      type: LoadBalancer
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: integrated144-service-weblogic
      labels:
        app: integrated144
    spec:
      selector:
        app: integrated144
      ports:
        - port: 7001
          targetPort: 7001
      type: LoadBalancer
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: integrated144-webservices
      labels:
        app: integrated144
    spec:
      selector:
        app: integrated144
      ports:
        - port: 7005
          targetPort: 7005
      type: LoadBalancer
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: flexcubeclaim
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: oci
      resources:
        requests:
          storage: 200Gi



### Manual Controls

If you want to start or stop WebLogic, you can execute these commands.

#### Execute WebLogic

    kubectl exec $(kubectl get pod -l app=integrated144 -o jsonpath="{.items[0].metadata.name}") -- /bin/bash -c "sh /scratch/gsh/kernel144/user_projects/domains/integrated/bin/startNodeManager.sh &"

    kubectl exec $(kubectl get pod -l app=integrated144 -o jsonpath="{.items[0].metadata.name}") -- /bin/bash -c "sh /scratch/gsh/kernel144/user_projects/domains/integrated/bin/startWebLogic.sh &"

#### Stop WebLogic

    kubectl exec $(kubectl get pod -l app=integrated144 -o jsonpath="{.items[0].metadata.name}") -- /bin/bash -c "sh /scratch/gsh/kernel144/user_projects/domains/integrated/bin/stopNodeManager.sh &"

    kubectl exec $(kubectl get pod -l app=integrated144 -o jsonpath="{.items[0].metadata.name}") -- /bin/bash -c "sh /scratch/gsh/kernel144/user_projects/domains/integrated/bin/stopWebLogic.sh &"

#### Changing Database Passwords in JDBC Configuration

    domainsDetails.properties

    ds.jdbc.new.1=jdbc:oracle:thin:@xxx.xxx.xxx.xxx:1521/DBSTRING.subnet04...815.vcn04...815.oraclevcn.com
    ds.password.new.1={AES256}7kfaltdnEBjKNqdH..............ynq1ee8Ib8=

#

    ChangeJDBC.py

    from java.io import FileInputStream

    propInputStream = FileInputStream("/domainsDetails.properties")
    configProps = Properties()
    configProps.load(propInputStream)
    
    for i in 1,1:
        newJDBCString = configProps.get("ds.jdbc.new."+ str(i))
        newDSPassword = configProps.get("ds.password.new."+ str(i))
        i = i + 1
    
        print("*** Trying to Connect.... *****")
        connect('weblogic','weblogic123','t3://localhost:7001')
        print("*** Connected *****")
        cd('/Servers/AdminServer')
        edit()
        startEdit()
        cd('JDBCSystemResources')
        pwd()
        ls()
        allDS=cmo.getJDBCSystemResources()
        for tmpDS in allDS:
                   dsName=tmpDS.getName();
                   print 'DataSource Name: ', dsName
                   print ' '
                   print ' '
                   print 'Changing Password & URL for DataSource ', dsName
                   cd('/JDBCSystemResources/'+dsName+'/JDBCResource/'+dsName+'/JDBCDriverParams/'+dsName)
                   print('/JDBCSystemResources/'+dsName+'/JDBCResource/'+dsName+'/JDBCDriverParams/'+dsName)
                   set('PasswordEncrypted', newDSPassword)
                   cd('/JDBCSystemResources/'+dsName+'/JDBCResource/'+dsName+'/JDBCDriverParams/'+dsName)
                   set('Url',newJDBCString)
                   print("*** CONGRATES !!! Username & Password has been Changed for DataSource: ", dsName)
                   print ('')
                   print ('')

    save()
    activate()

#

    ChangeJDBC.sh

    cd /scratch/gsh/oracle/wlserver/server/bin
    .  ./setWLSEnv.sh
    java weblogic.WLST /ChangeJDBC.py

#

#### Starting NodeManager and WebLogic

    ExecuteWebLogic.sh

    cd /
    su - gsh
    cd /scratch/gsh/kernel144/user_projects/domains/integrated/bin
    sh /scratch/gsh/kernel144/user_projects/domains/integrated/bin/startNodeManager.sh &
    sh /scratch/gsh/kernel144/user_projects/domains/integrated/bin/startWebLogic.sh &

#

    StartApps.py

    from java.io import FileInputStream
    
    print("*** Trying to Connect.... *****")
    connect('weblogic','weblogic123','t3://localhost:7001')
    print("*** Connected *****")
    
    start('gateway_server')
    start('rest_server')
    start('integrated_server')
    
    disconnect()
    exit()

#

    StartApps.sh

    cd /scratch/gsh/oracle/wlserver/server/bin
    .  ./setWLSEnv.sh
    java weblogic.WLST /StartApps.py
    
#

    RestartFlexcube.sh

    cd /
    sh ExecuteWebLogic.sh
    sleep 180
    cd /
    sh StartApps.sh

#

    JDBCReplace.sh

    #!/bin/bash
    su - gsh
    filename=$1
    while read line; do
    # reading each line
    echo $line
    sed -i 's/<url>jdbc:oracle:thin:@whf00fxh.in.oracle.com:1521\/prodpdb<\/url>/<url>$JDBCString<\/url>/' /scratch/gsh/kernel144/user_projects/domains/integrated/config/jdbc/$line
    sed -i 's/<password-encrypted><\/password-encrypted>/<password-encrypted>$JDBCPassword<\/password-encrypted>/' /scratch/gsh/kernel144/user_projects/domains/integrated/config/jdbc/$line
    done < $filename

#

    JDBCList

    FLEXTEST2eMDB-9656-jdbc.xml
    jdbc2ffcelcmDS-6351-jdbc.xml
    jdbc2ffcjdevDSBranch-1885-jdbc.xml
    jdbc2ffcjdevDS_EL-0091-jdbc.xml
    jdbc2ffcjpmDS_GTXN-9747-jdbc.xml
    FLEXTEST2eWORLD-1247-jdbc.xml
    jdbc2ffcjDevXADS-7492-jdbc.xml
    jdbc2ffcjdevDSSMS-8814-jdbc.xml
    jdbc2ffcjdevDS_GTXN-7273-jdbc.xml
    jdbc2ffcjsmsDS-7727-jdbc.xml
    jdbc2fINT144_integrated144-0549-jdbc.xml
    jdbc2ffcjSchedulerDS-6833-jdbc.xml
    jdbc2ffcjdevDSSMS_XA-5306-jdbc.xml
    jdbc2ffcjdevDS_XA-0669-jdbc.xml
    jdbc2fODT14_4-1795-jdbc.xml
    jdbc2ffcjdevDS-9467-jdbc.xml
    jdbc2ffcjdevDS_ASYNC-6792-jdbc.xml
    jdbc2ffcjpmDS-1925-jdbc.xml


=======
# Deploying OBMA in OCI OKE with ORACLE VISUAL BUILDER STUDIO

This document will show how to:

* Deploy quickly a OBMA Image
* Create a Container OBMA Image
* Create a DevOps build and deploy OBMA inside a Kubernetes Cluster

Layers for Containerization:
   * Fusion
   * OBMA
   * WebLogic Configuration
   * Database Configuration
   * OBMA Servers

## For manual deployment (Simple way)

This is the rapid way to deploy the OBMA in your cluster.
Attention for the CPU and Memory pre-requisites:

    5CPUs
    40Gb RAM
#
Execute the YAML obma144.yaml to start a OBMA Weblogic instance on the cluster.
If you want to clusterize your instances, you have to do it manually.
#
    If you already have a Pod/Deployment:

    kubectl delete deployment obma144-deployment
   
    ------
  
    Or if you want to create a new Deployment:
 
    kubectl apply -f obma144.yaml
    
    Remember: Change the JDBC parameters inside obma144.yaml

## Building OBMA Docker Image

    You can build a customized image of OBMA, but you can use this image on my repository:
        
    iad.ocir.io/id3kyspkytmr/OBMA/obma144:v1


Here I explain how to make your OBMA base image in docker. 
First, we need to use a Fusion Image.
There is a Fusion image on my repository. Execute the docker run to start the process:

    sudo docker run --name obma144 -h "obma.oracle.com" -p 8001-8050:8001-8050 -it "iad.ocir.io/id3kyspkytmr/oraclefmw-infra_with_patch:12.2.1.4.0" /bin/bash

### flexcube.sh

This step loads the OBMA kernel inside the Fusion image. This bash script do the job. All the scripts necessary to execute the process is inside this project:

    flexcube.sh file:
    
    su - gsh
    cd /
    wget "https://objectstorage.us-ashburn-1.oraclecloud.com/p/lmQLGI9bmWMWT2ZrxtumPPUn7xiKxY_5-vtaQi8WwNmhO77K7wZ7x5g4ZezxZvAy/n/id3kyspkytmr/b/bucket_banco_conceito/o/obma144_19Jan21obma144.zip"
    unzip -o obma144_19Jan21obma144.zip -d /
    cd /scratch/gsh/obma144/user_projects/domains/obma/bin

### Merge Fusion Docker Image with OBMA
Now, we need to start the image to configure and finalize the OBMA image:

    Execute docker image with:
    sudo docker start obma144    

Then execute:

    sudo docker cp flexcube.sh obma144:/

    sudo docker exec obma144 /bin/bash -c "sh /flexcube.sh"

Let's run the Weblogic Admin instance with:

    sudo docker exec obma144 /bin/bash -c "sh /scratch/gsh/obma144/user_projects/domains/obma/bin/startNodeManager.sh &"

    sudo docker exec obma144 /bin/bash -c "sh /scratch/gsh/obma144/user_projects/domains/obma/bin/startWebLogic.sh &"
    
Go to Weblogic Admin Server and change machine-1 Listen Address:

    http://<your docker IP>:8001/console
    
    if you mount your image locally, you can access the Admin Manager with:
    http://0.0.0.0:8001/console
    
Now, you need to configure the Listen Address:

    1. Go to Environment (left side of the menu)
    2. Go to Machines
    3. Select Machine-1
    4. Select Configuration and Node Manager
    5. Put "obma.oracle.com" in the Listen Address 
    6. Save the configuration and Apply the update

![obma-machine-listen-address.png](https://github.com/hoshikawa2/repo-image/blob/master/obma-machine-listen-address.png?raw=true)

And for push the docker image to OCIR:

    sudo docker stop obma144

    sudo docker commit obma144 flexcube/obma144:v1
    sudo docker tag flexcube/obma144:v1 iad.ocir.io/id3kyspkytmr/flexcube/obma144:v1
    sudo docker push iad.ocir.io/id3kyspkytmr/flexcube/obma144:v1

The OBMA team needs to build the image with:

    Fusion Middleware
    OBMA (/scratch/gsh/...)
    
    Remember the URL of your new OBMA image and update the YAML file named obma144.yaml and obma144-devops.yaml files. IT'S IMPORTANT!!!!

## Automating the deployment for OKE (DevOps)

#### Change Database Password to AES format with weblogic.security.Encrypt

First we need to get the database (a template backup of an Oracle Database for the OBMA) password. The password original will not work inside the scripts for this automation. The password needs to be converted in AES format, so you need to use the **setWLSEnv.sh** script to get your passsword into this format:

    cd /scratch/gsh/oracle/wlserver/server/bin
    .  ./setWLSEnv.sh
    java -Dweblogic.RootDirectory=/scratch/gsh/obma144/user_projects/domains/obma  weblogic.security.Encrypt <Database Password>

#### Environment Variables

The DevOps process needs only these 2 parameters to run OBMA inside a Kubernetes Cluster:

    $JDBCPassword: {AES256}7kfaltdnEBjKNq.......RIU0IcLOynq1ee8Ib8=     (In AES format*)
    $JDBCString: <JDBC Connection String>

#### DevOps Configuration

This is the DevOps shell script to prepare a OBMA Image and make it work for use. This can be used in Jenkins or **Oracle Visual Builder Studio**

#
    OCI CLI Install
    Unix Shell

    #  Prepare for kubectl from OCI CLI
    mkdir -p $HOME/.kube
    oci ce cluster create-kubeconfig --cluster-id ocid1.cluster.oc1.iad.aaaaaaaaae3tmyldgbtgmyjrmyzdeytbhazdmmbrgfstmntdgc2wmzrxgbrt --file $HOME/.kube/config --region us-ashburn-1 --token-version 2.0.0
    export KUBECONFIG=$HOME/.kube/config
    # Set Variables
    export JDBCString=$JDBCString
    export JDBCPassword=$JDBCPassword
    # setup the JDBC variables in obma144-devops.yaml
    sed -i "s~--JDBCString--~$JDBCString~g" obma144-devops.yaml
    sed -i "s~--JDBCPassword--~$JDBCPassword~g" obma144-devops.yaml
    # Deploy obma144
    kubectl config view
    kubectl replace -f obma144-devops.yaml --force

# 

You can configure your Build Pipeline in **Oracle Visual Builder Studio** like this:

**Git Configuration:**
![vbst-git-config.png](https://github.com/hoshikawa2/repo-image/blob/master/vbst-git-config.png?raw=true)

**Parameters Configuration:**
![vbst-config-parameters.png](https://github.com/hoshikawa2/repo-image/blob/master/vbst-config-parameters.png?raw=true)

**Steps Configuration**
![vbst-config-steps2.png](https://github.com/hoshikawa2/repo-image/blob/master/vbst-config-steps2.png?raw=true)

#### YAML file for deploy the OBMA Image into the Kubernetes Cluster


This is the file responsible for deploy your OBMA image into Kubernetes Cluster.
The configuration file replaces the $JDBCString and $JDBCPassword environment variables before execution. The scripts inside this projects will configure your Weblogic instance with all parameters.


    Deployment YAML (obma144-devops.yaml)

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: obma144-deployment
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: obma144
      template:
        metadata:
          labels:
            app: obma144
        spec:
          hostname: obma144
          hostAliases:
          - ip: "127.0.0.1"
            hostnames:
            - "obma.oracle.com"
          containers:
          - name: obma144
            image: iad.ocir.io/id3kyspkytmr/flexcube/obma144:v1
            env:
            - name: JDBCSTRING
              value: "--JDBCString--"
            - name: JDBCPASSWORD
              value: "--JDBCPassword--"
            command: [ "/bin/sh", "-c"]
            args:
              [ "sleep 180; cd /; wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/2O1XmamyP1yAVc2KDsBfTIqJmO55JEiT6Pf4U15EIKytfD7AFqjGoibRAd2BtmMu/n/id3kyspkytmr/b/bucket_banco_conceito/o/initializeConfig-obma.sh; sh initializeConfig-obma.sh $(JDBCSTRING) $(JDBCPASSWORD); while true; do sleep 30; done;" ]
            ports:
            - name: port8001
              containerPort: 8001
            - name: port8002
              containerPort: 8002
            - name: port8003
              containerPort: 8003
            - name: port8004
              containerPort: 8004
            - name: port8005
              containerPort: 8005
            - name: port8006
              containerPort: 8006
            - name: port8007
              containerPort: 8007
            - name: port8008
              containerPort: 8008
            - name: port8009
              containerPort: 8009
            - name: port8010
              containerPort: 8010
            - name: port8011
              containerPort: 8011
            - name: port8012
              containerPort: 8012
            - name: port8013
              containerPort: 8013
            - name: port8014
              containerPort: 8014
            - name: port8015
              containerPort: 8015
            - name: port8016
              containerPort: 8016
            - name: port8017
              containerPort: 8017
            - name: port8018
              containerPort: 8018
            - name: port8019
              containerPort: 8019
            - name: port8020
              containerPort: 8020
            - name: port8021
              containerPort: 8021
            - name: port8022
              containerPort: 8022
            - name: port8023
              containerPort: 8023
            - name: port8024
              containerPort: 8024
            - name: port8025
              containerPort: 8025
            - name: port8026
              containerPort: 8026
            - name: port8027
              containerPort: 8027
            - name: port8028
              containerPort: 8028
            - name: port8029
              containerPort: 8029
            - name: port8030
              containerPort: 8030
            - name: port8031
              containerPort: 8031
            - name: port8032
              containerPort: 8032
            - name: port8033
              containerPort: 8033
            - name: port8034
              containerPort: 8034
            - name: port8035
              containerPort: 8035
            - name: port8036
              containerPort: 8036
            - name: port8037
              containerPort: 8037
            - name: port8038
              containerPort: 8038
            - name: port8039
              containerPort: 8039
            - name: port8040
              containerPort: 8040
            - name: port8041
              containerPort: 8041
            - name: port8042
              containerPort: 8042
            - name: port8043
              containerPort: 8043
            - name: port8044
              containerPort: 8044
            - name: port8045
              containerPort: 8045
            - name: port8046
              containerPort: 8046
            - name: port8047
              containerPort: 8047
            - name: port8048
              containerPort: 8048
            - name: port8049
              containerPort: 8049
            - name: port8050
              containerPort: 8050
            - name: port5556
              containerPort: 5556
            livenessProbe:
              httpGet:
                path: /console
                port: 8001
              initialDelaySeconds: 3000
              timeoutSeconds: 30
              periodSeconds: 300
              failureThreshold: 3
            resources:
              requests:
                cpu: "5"
                memory: "40Gi"
              limits:
                cpu: "5"
                memory: "40Gi"
          restartPolicy: Always
          imagePullSecrets:
          # enter the name of the secret you created
          - name: ocirsecret
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: obma144-service
      labels:
        app: obma144
    spec:
      selector:
        app: obma144
      ports:
        - port: 8004
          targetPort: 8004
      type: LoadBalancer
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: obma144-service-weblogic
      labels:
        app: obma144
    spec:
      selector:
        app: obma144
      ports:
        - port: 8001
          targetPort: 8001
      type: LoadBalancer
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: obma144-webservices
      labels:
        app: obma144
    spec:
      selector:
        app: obma144
      ports:
        - port: 8005
          targetPort: 8005
      type: LoadBalancer




#### Resilience

The OBMA deployment is resilient, so if the Weblogic or OBMA falls down, the Kubernetes Cluster will load and execute again. The responsible for this is the **livenessprobe** inside the **obma144-devops.yaml** file.

### Manage the Weblogic manually
If you want to start or stop WebLogic, you can execute these commands. 

#### Execute WebLogic

    kubectl exec $(kubectl get pod -l app=obma144 -o jsonpath="{.items[0].metadata.name}") -- /bin/bash -c "sh /scratch/gsh/obma144/user_projects/domains/obma/bin/startNodeManager.sh &"

    kubectl exec $(kubectl get pod -l app=obma144 -o jsonpath="{.items[0].metadata.name}") -- /bin/bash -c "sh /scratch/gsh/obma144/user_projects/domains/obma/bin/startWebLogic.sh &"

#### Stop WebLogic

    kubectl exec $(kubectl get pod -l app=obma144 -o jsonpath="{.items[0].metadata.name}") -- /bin/bash -c "sh /scratch/gsh/obma144/user_projects/domains/obma/bin/stopNodeManager.sh &"

    kubectl exec $(kubectl get pod -l app=obma144 -o jsonpath="{.items[0].metadata.name}") -- /bin/bash -c "sh /scratch/gsh/obma144/user_projects/domains/obma/bin/stopWebLogic.sh &"


### The scripts inside this project
These are the scripts responsible for automate the deployment, configuration and execution of the OBMA instance
#### Changing Database Passwords in JDBC Configuration

These scripts change the configuration of all JDBC XML files inside the Weblogic. The environmental variables $JDBCString and $JDBCPassword will be used here

    domainsDetails.properties

    ds.jdbc.new.1=jdbc:oracle:thin:@xxx.xxx.xxx.xxx:1521/DBSTRING.subnet04...815.vcn04...815.oraclevcn.com
    ds.password.new.1={AES256}7kfaltdnEBjKNqdH..............ynq1ee8Ib8=

#

    ChangeJDBC.py

    from java.io import FileInputStream

    propInputStream = FileInputStream("/domainsDetails.properties")
    configProps = Properties()
    configProps.load(propInputStream)
    
    for i in 1,1:
        newJDBCString = configProps.get("ds.jdbc.new."+ str(i))
        newDSPassword = configProps.get("ds.password.new."+ str(i))
        i = i + 1
    
        print("*** Trying to Connect.... *****")
        connect('weblogic','weblogic123','t3://localhost:8001')
        print("*** Connected *****")
        cd('/Servers/AdminServer')
        edit()
        startEdit()
        cd('JDBCSystemResources')
        pwd()
        ls()
        allDS=cmo.getJDBCSystemResources()
        for tmpDS in allDS:
                   dsName=tmpDS.getName();
                   print 'DataSource Name: ', dsName
                   print ' '
                   print ' '
                   print 'Changing Password & URL for DataSource ', dsName
                   cd('/JDBCSystemResources/'+dsName+'/JDBCResource/'+dsName+'/JDBCDriverParams/'+dsName)
                   print('/JDBCSystemResources/'+dsName+'/JDBCResource/'+dsName+'/JDBCDriverParams/'+dsName)
                   set('PasswordEncrypted', newDSPassword)
                   cd('/JDBCSystemResources/'+dsName+'/JDBCResource/'+dsName+'/JDBCDriverParams/'+dsName)
                   set('Url',newJDBCString)
                   print("*** CONGRATES !!! Username & Password has been Changed for DataSource: ", dsName)
                   print ('')
                   print ('')

    save()
    activate()
#
    Important: The JDBC configuration files for the OBMA is on /scratch/gsh/obma144/user_projects/domains/obma/config/jdbc

#

    ChangeJDBC.sh

    cd /scratch/gsh/oracle/wlserver/server/bin
    .  ./setWLSEnv.sh
    java weblogic.WLST /ChangeJDBC.py

#
#

    JDBCReplace.sh

    #!/bin/bash
    su - gsh
    filename=$1
    while read line; do
    # reading each line
    echo $line
    sed -i 's/<url>jdbc:oracle:thin:@whf00fxh.in.oracle.com:1521\/prodpdb<\/url>/<url>$JDBCString<\/url>/' /scratch/gsh/obma144/user_projects/domains/obma/config/jdbc/$line
    sed -i 's/<password-encrypted><\/password-encrypted>/<password-encrypted>$JDBCPassword<\/password-encrypted>/' /scratch/gsh/obma144/user_projects/domains/obma/config/jdbc/$line
    done < $filename

#

    JDBCList

    jdbc2fOBAC-2439-jdbc.xml
    jdbc2fOBIC-2191-jdbc.xml
    jdbc2fPLATO-1684-jdbc.xml
    jdbc2fPLATOBATCH-4386-jdbc.xml
    jdbc2fUBSCUSTOMER-3856-jdbc.xml

#### Starting NodeManager and WebLogic

These scripts start the Weblogic Admin, Node Manager and the application (OBMA) and are used in the automation in the deployment YAML file

    ExecuteWebLogic.sh

    cd /
    su - gsh
    cd /scratch/gsh/obma144/user_projects/domains/obma/bin
    sh /scratch/gsh/obma144/user_projects/domains/obma/bin/startNodeManager.sh &
    sh /scratch/gsh/obma144/user_projects/domains/obma/bin/startWebLogic.sh &

#

    StartApps.py

    from java.io import FileInputStream
    
    print("*** Trying to Connect.... *****")
    connect('weblogic','weblogic123','t3://localhost:8001')
    print("*** Connected *****")
    
    start('config_server')
    start('ac_server')
    start('cs_server')
    start('ic_server')
    
    disconnect()
    exit()

#

    StartApps.sh

    cd /scratch/gsh/oracle/wlserver/server/bin
    .  ./setWLSEnv.sh
    java weblogic.WLST /StartApps.py
    
#

    RestartFlexcube.sh

    cd /
    sh ExecuteWebLogic.sh
    sleep 180
    cd /
    sh StartApps.sh




>>>>>>> cd383ad6b996b4a552744bd44b8e06685363de78
