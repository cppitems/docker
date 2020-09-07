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
cd workingdir
sudo groupadd --gid 5555 theia # create new group 'theia'
sudo usermod -a -G theia $(id -un) # append current user to group 'theia'
sudo chown -R :theia ./  # change ownership to the new theia group
sudo chmod -R 775 ./ # make accessible 
sudo chmod g+s ./ # make all future content inherit ownership
```

3. start theia backend server
```bash
# cd into folder (working dirctory) where your project lives (do not start in Home-folder as a lot of file-precaching happens then)
docker run --init -it -p 3000 -v "$(pwd):/home/project:cached" quay.io/manstetten/theia-cpp:latest  
# when running memory sanitizer & co
#docker run --init -it -p 3000:3000 --cap-add SYS_PTRACE -v "$(pwd):/home/project:cached" quay.io/manstetten/theia-cpp:latest 
```

4. access theia IDE using your browser and the uri http://localhost:3000


