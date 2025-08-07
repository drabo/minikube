# Install Kubernetes local cluster with Minkube

In the following document you will find several terms like:

- Kubernetes cluster
- Minikube cluster
- Kubernetes local cluster
- Cluster
- K8s or k8s

All these terms refer to the same thing that is the Kubernetes cluster containing one node hosted on a local VirtualBox VM, created and managed with the CLI tool called Minikube.

## 1. Install Minikube on Windows

The Minikube Kubernetes cluster will be created as a virtual machine in VirtualBox, so, make sure you have it installed.

### 1.1. Use Cygwin in Windows

You will need 4 tools to create and manage the Minikube Kubernetes cluster:

- minikube
- kubectl
- helm
- tiller

#### 1.1.1. Install Minikube

Minikube is the CLI tool to create and manage the virtual machine used by Kubernetes.

Go to the <a href="https://github.com/kubernetes/minikube/releases/latest" target="_blank">minikube download page</a>

At the bottom of the page you may identify the package for Windows: `minikube-windows-amd64.exe`. Copy the link of the file and use it below to set the variable MINIKUBELINK:

```shell
MINIKUBELINK=https://github.com/kubernetes/minikube/releases/download/v1.3.1/minikube-windows-amd64.exe

curl -Lo minikube.exe $MINIKUBELINK && chmod +x minikube.exe && mv minikube.exe /usr/local/bin/
```

#### 1.1.2. Install Kubectl

Kubectl is the CLI tool to manage Kubernetes.

Download the Windows executable:

```shell
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/windows/amd64/kubectl.exe && chmod +x kubectl.exe && mv kubectl.exe /usr/local/bin/
```

#### 1.1.3. Install Helm and Tiller

Helm is the CLI tool to install software packages that exists in Helm library. Tiller keeps track of the packages installed.

Got to page https://github.com/helm/helm/releases/latest and identify the download link of package `Windows amd64` within section **Installation and Upgrading** of the page. Copy the link of the file and use it below to set the variable HELMLINK:

```shell
HELMLINK=https://get.helm.sh/helm-v2.14.3-windows-amd64.zip

curl -LO $HELMLINK && unzip $(basename $HELMLINK) && chmod +x windows-amd64/*.exe && mv windows-amd64/*.exe /usr/local/bin/
```

#### 1.1.4. Common configuration

For the above tools you need to set few symlinks, exports and completion:

```shell
mkdir $HOME/bin
ln -s /usr/local/bin/minikube.exe $HOME/bin/minikube
ln -s /usr/local/bin/kubectl.exe $HOME/bin/kubectl
ln -s /usr/local/bin/helm.exe $HOME/bin/helm
echo "source <(/usr/local/bin/minikube completion bash)" >>$HOME/.bashrc
echo "source <(/usr/local/bin/kubectl completion bash)" >>$HOME/.bashrc
echo "source <(/usr/local/bin/helm completion bash)" >>$HOME/.bashrc
echo "export KUBE_EDITOR=vim" >>$HOME/.bashrc
echo 'export PATH='$HOME'/bin:$PATH' >>$HOME/.bashrc
```

Close the terminal and reopen it in order to execute the above commands. Check few commands to verify the version installed of each CLI tool:

```shell
$ minikube version

minikube version: v1.3.1
```

Kubectl shows only the client information because the server relates to the Kubernetes cluster that is still not created:

```shell
$ kubectl version

Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.2", GitCommit:"641856db18352033a0d96dbc99153fa3b27298e5", GitTreeState:"clean", BuildDate:"2019-03-25T15:53:57Z", GoVersion:"go1.12.1", Compiler:"gc", Platform:"windows/amd64"}
Unable to connect to the server: dial tcp 127.0.0.1:8080: connectex: No connection could be made because the target machine actively refused it.
```

As well, helm shows only the client information:

```shell
$ helm version

Client: &version.Version{SemVer:"v2.14.3", GitCommit:"5270352a09c7e8b6e8c9593002a73535276507c0", GitTreeState:"clean"}
Error: Get http://localhost:8080/api/v1/namespaces/kube-system/pods?labelSelector=app%3Dhelm%2Cname%3Dtiller: dial tcp 127.0.0.1:8080: connectex: No connection could be made because the target machine actively refused it.
```

Tiller starts the server on localhost. You may cancel it.

```shell
$ tiller version

[main] 2019/06/19 00:37:34 Starting Tiller v2.14.3 (tls=false)
[main] 2019/06/19 00:37:34 GRPC listening on :44134
[main] 2019/06/19 00:37:34 Probes listening on :44135
[main] 2019/06/19 00:37:34 Storage driver is ConfigMap
[main] 2019/06/19 00:37:34 Max history per release is 0
Ctrl+C
```

#### 1.1.5. Create the Kubernetes cluster with Minikube

The local cluster may be created with the same command that will later start it:

```shell
minikube start
```

This command will create a VirtualBox machine with 2 CPU, 4GB RAM and 20GB disk.

You may use this config or you may enhance it according to your needs. You may edit the script [0.minikube-create.sh](0.minikube-create.sh) to modify the resources or to set a local Docker repository IP address, that may be Nexus.

If you intend to use such local Docker repo then you **must** specify it at the minikube cluster creation time because a later update of this element will not be possible.

Edit the script [0.minikube-create.sh](0.minikube-create.sh) according to your needs and run it:

```shell
./0.minikube-create.sh
```

To check if the cluster is created run `minikube status`:

```shell
$ minikube status

host: Running
kubelet: Running
apiserver: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.100
```

If the cluster was created then you will see the components `Running` and the IP address of the cluster.

After the cluster is created, kubectl will show also the server version:

```shell
$ kubectl version

Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.2", GitCommit:"641856db18352033a0d96dbc99153fa3b27298e5", GitTreeState:"clean", BuildDate:"2019-03-25T15:53:57Z", GoVersion:"go1.12.1", Compiler:"gc", Platform:"windows/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.2", GitCommit:"5e53fd6bc17c0dec8434817e69b04a25d8ae0ff0", GitTreeState:"clean", BuildDate:"2019-06-06T01:36:19Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```

#### 1.1.6. Modify optins to the minikube cluster

There are 2 optins that should be enabled:

- dashboard - a GUI to browse and manage components of the Kubernetes cluster
- ingress - a functionality of Kubernetes that allow to expose the services running in the cluster with DNS names

Both these options are provided as 'addons' in Minikube.

You may list all addons with:

```shell
$ minikube addons list

- addon-manager: enabled
- dashboard: disabled
- default-storageclass: enabled
- efk: disabled
- freshpod: disabled
- gvisor: disabled
- heapster: disabled
- ingress: disabled
- logviewer: disabled
- metrics-server: enabled
- nvidia-driver-installer: disabled
- nvidia-gpu-device-plugin: disabled
- registry: disabled
- registry-creds: enabled
- storage-provisioner: enabled
- storage-provisioner-gluster: disabled
```

The script [1.minikube-update.sh](1.minikube-update.sh) may be modified and used according to your needs:

```shell
./1.minikube-update.sh
```

#### 1.1.7. Explore the cluster

##### 1.1.7.1. Use CLI to explore cluster

The CLI tool kubectl is used to explore and manage the cluster

The following will show the only node composing the cluster:

```shell
$ kubectl get nodes

NAME       STATUS   ROLES    AGE   VERSION
minikube   Ready    master   1d    v1.14.3
```

The following will show all components in the default namespace:

```shell
$ kubectl get all

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   58d
```

##### 1.1.7.2. Use GUI to explore cluster

The GUI will run in the default web browser and you start it with:

```shell
minikube dashboard &
```

#### 1.1.8. Prepare Helm to deploy software into the cluster created

In order for Helm to be able to install software packages into your Kubernetes cluster you need to initialize it. Run the script [2.helm-init.sh](2.helm-init.sh):

```shell
./2.helm-init.sh
```

Tiller is deployed into the cluster and the above script will return an output like:

```shell
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)     AGE
tiller-deploy   ClusterIP   10.108.34.40   <none>        44134/TCP   1d
```

If `tiller-deploy` _service_ is still not deployed then check it again in the dashboard GUI in namespace `kube-system` or using the kubectl:

```shell
kubectl -n kube-system get svc tiller-deploy
```

In this moment your Kubernetes local cluster should be up and running an ready to start deploying applications into it.

#### 1.1.9. Start/Stop cluster

>:exclamation: The cluster will be started and stopped **ONLY** using minikube CLI tool.
>
>:exclamation: **Do not** start or stop the VM using VirtualBox.

- The cluster will be started with:

```shell
minikube start
```

- The cluster will be stopped with:

```shell
minikube stop
```

#### 1.1.10. Other minikube commands

You will get all options of minikube if you run:

```shell
minikube
```

Few useful comands follows:

- Display the IP address of the Kubernetes minikube VM.

```shell
$ minikube ip

192.168.99.100
```

Your computer has the IP address 192.168.99.1 within the network 192.168.99.0/24 created by minikube in VirtualBox.

- Display the logs of cluster components.

```shell
minikube logs
```

- Login to the VM with user docker. The user has sudo rights.

```shell
minikube ssh
```

>:exclamation: **Do not** modify anything into the VirtualBox VM otherwise the cluster may not be usable anymore.

## 2. Install Minikube on Linux

The Minikube Kubernetes cluster will be created as a virtual machine in VirtualBox, so, make sure you have VirtualBox installed.

The installation steps are similar as for the Windows Cygwin.

You will need 4 tools to create and manage the Minikube Kubernetes cluster:

- minikube
- kubectl
- helm
- tiller

### 2.1. Install Minikube

Minikube is the CLI tool to create and manage the virtual machine used by Kubernetes.

Go to the page https://github.com/kubernetes/minikube/releases/latest

At the bottom of the page you may identify the package for Windows: `minikube-linux-amd64`. Copy the link of the file and use it below to set the variable MINIKUBELINK:

```shell
MINIKUBELINK=https://github.com/kubernetes/minikube/releases/download/v1.3.0/minikube-linux-amd64

curl -Lo minikube $MINIKUBELINK && chmod +x minikube && mv minikube /usr/local/bin/
```

### 2.2. Install Kubectl

Kubectl is the CLI tool to manage Kubernetes.

Download the Windows executable:

```shell
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/
```

### 2.3. Install Helm and Tiller

Helm is the CLI tool to install software packages that exists in Helm library. Tiller keeps track of the packages installed.

Got to page https://github.com/helm/helm/releases/latest and identify the download link of package `Linux amd64` within section **Installation and Upgrading** of the page. Copy the link of the file and use it below to set the variable HELMLINK:

```shell
HELMLINK=https://get.helm.sh/helm-v2.14.3-linux-amd64.tar.gz

curl -LO $HELMLINK && tar -xf $(basename $HELMLINK) && chmod +x linux-amd64/{helm,tiller} && mv linux-amd64/{helm,tiller} /usr/local/bin/
```

### 2.4. Common configuration

For the above tools you need to set few exports and completion:

```shell
echo "source <(/usr/local/bin/minikube completion bash)" >>$HOME/.bashrc
echo "source <(/usr/local/bin/kubectl completion bash)" >>$HOME/.bashrc
echo "source <(/usr/local/bin/helm completion bash)" >>$HOME/.bashrc
echo "export KUBE_EDITOR=vim" >>$HOME/.bashrc
echo 'export PATH='$HOME'/bin:$PATH' >>$HOME/.bashrc
```

Close the terminal and reopen it in order to execute the above commands. Check few commands to verify the version installed of each CLI tool:

```shell
$ minikube version

minikube version: v1.3.1
```

Kubectl shows only the client information because the server relates to the Kubernetes cluster that is still not created:

```shell
$ kubectl version

Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.2", GitCommit:"641856db18352033a0d96dbc99153fa3b27298e5", GitTreeState:"clean", BuildDate:"2019-03-25T15:53:57Z", GoVersion:"go1.12.1", Compiler:"gc", Platform:"windows/amd64"}
Unable to connect to the server: dial tcp 127.0.0.1:8080: connectex: No connection could be made because the target machine actively refused it.
```

As well, helm shows only the client information:

```shell
$ helm version

Client: &version.Version{SemVer:"v2.14.3", GitCommit:"5270352a09c7e8b6e8c9593002a73535276507c0", GitTreeState:"clean"}
Error: Get http://localhost:8080/api/v1/namespaces/kube-system/pods?labelSelector=app%3Dhelm%2Cname%3Dtiller: dial tcp 127.0.0.1:8080: connectex: No connection could be made because the target machine actively refused it.
```

Tiller starts the server on localhost. You may cancel it.

```shell
$ tiller version

[main] 2019/06/19 00:37:34 Starting Tiller v2.14.3 (tls=false)
[main] 2019/06/19 00:37:34 GRPC listening on :44134
[main] 2019/06/19 00:37:34 Probes listening on :44135
[main] 2019/06/19 00:37:34 Storage driver is ConfigMap
[main] 2019/06/19 00:37:34 Max history per release is 0
Ctrl+C
```

### 2.5. Create the Kubernetes cluster with Minikube

Same as in the [Windows section](#115-create-the-kubernetes-cluster-with-minikube)

### 2.6. Modify optins to the minikube cluster

Same as in the [Windows section](#116-modify-optins-to-the-minikube-cluster)

### 2.7. Explore the cluster

Same as in the [Windows section](#117-explore-the-cluster)

### 2.8. Prepare Helm to deploy software into the cluster created

Same as in the [Windows section](#118-prepare-helm-to-deploy-software-into-the-cluster-created)

### 2.9. Start/Stop cluster

Same as in the [Windows section](#119-startstop-cluster)

### 2.10. Other minikube commands

Same as in the [Windows section](#1110-other-minikube-commands)

## 3. Troubleshooting

### 3.1 Fix registry-creds

You may find that Replication Controller `registry-creds` is failing to create the pod.

First, you may check the status of this minikube addon:

```shell
$ minikube addons list | grep registry-creds
- registry-creds: enabled
```

Assuming that `registry-creds` addon is enabled in minikube but failing to start in K8s, the most probable cause is that the secrets are not created.

`registry-creds` is using 3 secrets for the access to the the following 3 container image repositories:

- AWS ECR
- Google GCR
- another repository at your choice

Each of the above has a set of elements that define its secret. If the secrets are not created you may create them with the following commands:

```shell
kubectl -n kube-system create secret generic registry-creds-ecr
kubectl -n kube-system create secret generic registry-creds-gcr
kubectl -n kube-system create secret generic registry-creds-dpr
```

Now you need to configure the secrets. An easy way is to use minikube for this operation. It will ask each element and will update the secrets for you.

```shell
$ minikube addons configure registry-creds

Do you want to enable AWS Elastic Container Registry? [y/n]: n

Do you want to enable Google Container Registry? [y/n]: n

Do you want to enable Docker Registry? [y/n]: y
-- Enter docker registry server url: nexus:8083
-- Enter docker registry username: yourname
-- Enter docker registry password: yourpassword
✅  registry-creds was successfully configured
```

In the above example is assumed that it will not be configured a repository neither for AWS ECR nor for Google GCR but will be used only a local Nexus server with a Docker repository exposed with HTTPS on port 8083.

After all the above configured you should restart the pod of `registry-creds`.

First, you identify the pod:

```shell
$ kubectl -n kube-system get po|grep registry-creds
registry-creds-54llj     1/1     Error   0     93m
```

Delete the pod and the Replication Controller will recreate it and will load the new secrets that you configured:

```shell
$ kubectl -n kube-system delete po registry-creds-54llj
pod "registry-creds-54llj" deleted
```

Check if the pod was created and is in state `Running`:

```shell
$ kubectl -n kube-system get po|grep registry-creds
registry-creds-qntm4     1/1     Running   0     17s
```

You may see the encoded secret in few ways:

```shell
kubectl -n kube-system get secret registry-creds-dpr -o jsonpath='{.data}'
```

or

```shell
kubectl -n kube-system get secret registry-creds-dpr -o custom-columns=SECRET:.data
```

In both cases the information returned may look like:

```log
map[DOCKER_PRIVATE_REGISTRY_PASSWORD:XXXXXXXX== DOCKER_PRIVATE_REGISTRY_SERVER:YYYYYYYY== DOCKER_PRIVATE_REGISTRY_USER:ZZZZZZZZ==]
```

If you decide to add credentials for AWS ECR secret you have 2 options:

1. first option is to edit the secret `registry-creds-ecr`:

```shell
kubectl -n kube-system edit secret registry-creds-ecr
```

Provide the details in the section *data*:

```yaml
data:
  AWS_ACCESS_KEY_ID: Y2hhbmdlbWU=
  AWS_SECRET_ACCESS_KEY: Y2hhbmdlbWU=
  AWS_SESSION_TOKEN: ""
  aws-account: Y2hhbmdlbWU=
  aws-assume-role: Y2hhbmdlbWU=
  aws-region: Y2hhbmdlbWU=
```

Each element to be provided in the secret should be previously encoded with base64 as follows:

```shell
$ echo -n mySecretPassword | base64
bXlTZWNyZXRQYXNzd29yZA==
```

Note that you must use `echo -n` otherwise the element will have a `\n` character appended.

2. second option is to run again the command:

```shell
minikube addons configure registry-creds
```

and provide all necessary elements.

### 3.2 Fix nginx-ingress

It is possible in minikube v1.19.0 to get the following error when you deploy an ingress component:

```log
Error from server (InternalError): error when creating "xxx.yaml": Internal error occurred: failed calling webhook "validate.nginx.ingress.kubernetes.io": an error on the server ("") has prevented the request from succeeding
```

The cure for the moment is to run the following command:

```shell
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
```

### 3.3 Fix coredns

In some cases you may need to get from a pod to an Internet address. You may discover that the external address is not accessible due to K8s DNS initial settings done by Minikube.

In this case you will have to check the `coredns` configuration with:

```shell
kubectl -n kube-system edit configmaps coredns
```

The configmap may look like:

```yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        hosts {
           192.168.59.1 host.minikube.internal
           fallthrough
        }
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2022-03-13T15:36:01Z"
  name: coredns
  namespace: kube-system
  resourceVersion: "118724"
  uid: 679adb8e-37e8-43d4-9a50-5d9721e67cf5

```

All you need is to change the `forward` section as follows:

```yaml
        forward . 8.8.8.8:53 {
           max_concurrent 1000
        }
```
