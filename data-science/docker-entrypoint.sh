#!/usr/bin/env bash

set -CEuxo pipefail

assert_env_defined () {
  if [ ! -v $1 ]; then
    echo "please define '$1' environment variable"
    exit 1
  fi
}

: "Add non administrative user" && {

  : "Add user if not exists" && {
    assert_env_defined USER_NAME
    # existence check
    if ! id ${USER_NAME} ; then
      useradd -s /bin/bash -m ${USER_NAME}
    fi
  }

  : "Set home directory" && {
    export HOME=/home/${USER_NAME}
  }

  : "Change user id" && {
    assert_env_defined USER_ID
    if [ $(id -u ${USER_NAME}) -ne ${USER_ID} ]; then
      usermod -u ${USER_ID} ${USER_NAME}
    fi
  }

  : "Change group id" && {
    assert_env_defined GROUP_ID
    if [ $(id -g ${USER_NAME}) -ne ${GROUP_ID} ]; then
      usermod -g ${GROUP_ID} ${USER_NAME}
    fi
  }

  : "Add common groups" && {
    usermod -aG sudo ${USER_NAME}
  }

  : "Change password" && {
    assert_env_defined PASSWORD_HASH
    usermod -p ${PASSWORD_HASH} ${USER_NAME}
  }

}

: "Replace template variables" && {
  sed -i.back \
    -e "s:%%USER_NAME%%:${USER_NAME}:g" \
    -e "s:%%CONDA_HOME%%:${CONDA_HOME}:g" \
    -e "s:%%CONDA_VENV_NAME%%:${CONDA_VENV_NAME}:g" \
  /etc/supervisord.conf
}

: "Jupyter configuration" && {
  if [ ! -e /home/${USER_NAME}/.jupyter ]; then
    sudo -iu ${USER_NAME} ${CONDA_HOME}/envs/${CONDA_VENV_NAME}/bin/jupyter notebook --generate-config
    sudo -iu ${USER_NAME} sed -i.back \
      -e "s:^#c.NotebookApp.token = .*$:c.NotebookApp.token = u'':" \
      -e "s:^#c.NotebookApp.ip = .*$:c.NotebookApp.ip = '*':" \
      -e "s:^#c.NotebookApp.open_browser = .*$:c.NotebookApp.open_browser = False:" \
      -e "s:^#c.NotebookApp.notebook_dir = .*$:c.NotebookApp.notebook_dir = \"${JUPYTER_HOME}\":" \
      /home/${USER_NAME}/.jupyter/jupyter_notebook_config.py
  fi
}

: "Start supervisord" && {
  supervisord -c /etc/supervisord.conf
}
