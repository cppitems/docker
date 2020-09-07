## customized docker container for C++ lecture 
1. install docker on your machine

ubuntu:
https://docs.docker.com/engine/install/ubuntu/

windows
https://docs.docker.com/docker-for-windows/install/

2. pull image 
```bash
docker pull quay.io/manstetten/theia-cpp:latest
```

2.1 prepare working dirctory permissions
```bash
# create new group 'theia'
sudo groupadd --gid 5555 theia
# append current user to group 'theia'
sudo usermod -a -G theia $(id -un)
# check groups (now contains theia)
groups $(id -un)
# recursive ownership and write access to folder for group members of 'theia'
cd workingdir
sudo chown -R :theia ./
sudo chmod -R 775 ./
# make all future content inherit ownership
sudo chmod g+s ./
```

3. start theia backend server
```bash
# cd into folder (working dirctory) where your project lives (do not start in Home-folder as a lot of file-precaching happens then)
docker run --user 55555 --init -it -p 3000:3000 --cap-add SYS_PTRACE -v "$(pwd):/home/project:cached" quay.io/manstetten/theia-cpp:latest   
```

4. access theia IDE using your browser and the uri http://localhost:3000


