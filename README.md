## customized docker container for C++ lecture 
1. install docker on your machine

ubuntu:
https://docs.docker.com/engine/install/ubuntu/

windows
https://docs.docker.com/docker-for-windows/install/

2. pull image 
```bash
docker pull quay.io/manstetten/theia-cpp:latest
docker tag quay.io/manstetten/theia-cpp:latest theia-cpp:latest
```

3. start theia backend server
```bash
# cd into folder where your project lives
docker run --init -it -p 3000:3000 --cap-add SYS_PTRACE -v "$(pwd):/home/project:cached" theia-cpp:latest    
```

4. access theia IDE using your browser and the uri http://localhost:3000


