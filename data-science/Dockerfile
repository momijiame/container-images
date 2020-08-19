FROM ubuntu:20.04

ENV CONDA_HOME=/opt/conda \
    CONDA_VENV_NAME=venv \
    PYTHON_VERSION=3.8
ENV USER_NAME \
    USER_ID \
    GROUP_ID \
    JUPYTER_HOME

# Use mirror repository
RUN sed -i.bak -e "s%http://[^ ]\+%mirror://mirrors.ubuntu.com/mirrors.txt%g" /etc/apt/sources.list

# Install prerequisite apt packages
RUN apt-get update \
 && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
      sudo \
      supervisor \
      ca-certificates \
      wget \
      openssh-server \
      xserver-xorg \
      xauth \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda3.sh \
 && /bin/bash /tmp/miniconda3.sh -b -p ${CONDA_HOME} \
 && rm /tmp/miniconda3.sh \
 && ${CONDA_HOME}/bin/conda clean -tipsy \
 && ln -s ${CONDA_HOME}/etc/profile.d/conda.sh /etc/profile.d/

# Create virtual environment
COPY pip-requirements.txt /tmp
COPY conda-requirements.txt /tmp
RUN . /etc/profile.d/conda.sh \
 && conda create -y -n ${CONDA_VENV_NAME} python=${PYTHON_VERSION} \
 && conda activate ${CONDA_VENV_NAME} \
 && conda install -y --file /tmp/conda-requirements.txt \
 && pip install -r /tmp/pip-requirements.txt

# Install extra apt packages
COPY apt-requirements.txt /tmp
RUN apt-get update \
 && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
      $(cat /tmp/apt-requirements.txt) \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Prepare OpenSSH server
RUN mkdir /var/run/sshd \
 && sed -i -e "s/^#AddressFamily.*$/AddressFamily inet/" /etc/ssh/sshd_config

# Expose container ports
EXPOSE 22
EXPOSE 8888

# Boot process
COPY supervisord.conf /etc
COPY docker-entrypoint.sh /var/tmp
CMD bash /var/tmp/docker-entrypoint.sh
