# customized docker container for C++ lecture 
## 1. install docker on your machine

ubuntu:
https://docs.docker.com/engine/install/ubuntu/

windows
https://docs.docker.com/docker-for-windows/install/


## 2a. pull image (if your uid/gid is 1000/1000)
You can make use of the prebuild image if the user you will use to start the container has uid=1000 and gid=1000.
Otherwise goto **2b.**
```bash
# check the uid/gid of current user
echo $(id -u) $(id -g)
# use prebuild image (which is configured for uid=1000 gid=1000)
docker pull quay.io/manstetten/theia-cpp:latest
```

## 2b. build this docker image (if your uid/gid is **not** 1000/1000)
```bash
# cd to root folder of this reppo; using uid gid of current user
docker build -f Dockerfile --build-arg host_uid=$(id -u) --build-arg host_gid=$(id -g) -t theia-cpp:latest .
```

## 3a. start theia backend server (using prebuild/pulled image from quay.io)

```bash
# cd into folder (working dirctory) where your project lives (do not start in Home-folder as a lot of file-precaching happens then)
docker run --init -it -p 3003:3000 -v "$(pwd):/home/project:cached" quay.io/manstetten/theia-cpp:latest  
# when running with memory sanitizer & co
docker run --init -it -p 3003:3000 --cap-add SYS_PTRACE -v "$(pwd):/home/project:cached" quay.io/manstetten/theia-cpp:latest 
```
## 3b. start theia backend server (using locally build image)
```bash
# cd into folder (working dirctory) where your project lives (do not start in Home-folder as a lot of file-precaching happens then)
docker run --init -it -p 3003:3000 -v "$(pwd):/home/project:cached" theia-cpp:latest  
# when running with memory sanitizer & co
docker run --init -it -p 3003:3000 --cap-add SYS_PTRACE -v "$(pwd):/home/project:cached" theia-cpp:latest 
``` 

## 4. access theia IDE using your browser 
Navigate to http://localhost:3003 using a browser on your host
