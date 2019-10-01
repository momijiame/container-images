# Data Science Container Image

The following packages are available

- Miniconda
- JupyterLab
- OpenSSH Server (X11 forwarding)

## How to build

```
$ sudo docker-compose build
```

## How to launch

on Linux:

```
$ USER_NAME=$(whoami) \
  USER_ID=$(id -u) \
  GROUP_ID=$(id -g) \
  PASSWORD_HASH=$(python3 -c "import crypt; from getpass import getpass; print(crypt.crypt(getpass(), crypt.METHOD_SHA512))") \
  sudo -E docker-compose up
```

on macOS:

```
$ pip install passlib
$ USER_NAME=$(whoami) \
  USER_ID=$(id -u) \
  GROUP_ID=$(id -g) \
  PASSWORD_HASH=$(python3 -c "from passlib.hash import sha512_crypt; from getpass import getpass; print(sha512_crypt.hash(getpass()))") \
  docker-compose up
```

## How to use jupyter-lab

```
$ open http://localhost:8888
```

## How to login

```
$ ssh \
  -XC \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -p 22222 \
  localhost
```

## TIPS

### Use on remote server

1. ssh login to docker host with port forwarding

```
$ ssh -XC \
    -L 22222:localhost:22222 \
    -L 8888:localhost:8888 \
    <docker-host>
```

2. use remote port via forwarded one

### Want to add some packages

1. apt package

add package names to `apt-requirements.txt` with separate lines

2. conda package

add package names to `conda-requirements.txt` with separate lines

3. pip package

add package names to `pip-requirements.txt` with separate lines

### Want to change shared directory location with container

Edit `docker-compose.yml` on `volumns` section: change host mount directory (default: `./`) to some other directory
