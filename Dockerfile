FROM ubuntu:bionic as main




RUN set -eux; \
    apt-get update -y; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git \
      openssh-client \
      mysql-client \
      python \
      python-pip \
      ruby \
      wget; \
    apt-get clean all; \
    rm -rf /var/lib/apt/lists/*; \
    pip install \
      ansible \
      setuptools \
      PyMySQL \
      boto3 \
      botocore \
      boto; \
    mkdir -p /etc/ansible; \
    echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts


RUN git clone https://github.com/ansible/ansible /tmp/ansible
RUN mkdir -p /usr/share/ansible/plugins/lookup
RUN cp /tmp/ansible/lib/ansible/plugins/lookup/aws_secret.py /usr/share/ansible/plugins/lookup
RUN mkdir -p /var/ansible
RUN printf "[defaults]\nstdout_callback = yaml\nbin_ansible_callbacks = yes\n" > /etc/ansible/ansible.cfg

COPY assets/ /opt/resource/


FROM main as testing

RUN set -eux; \
    gem install \
      rspec; \
    wget -q -O - https://raw.githubusercontent.com/troykinsella/mockleton/master/install.sh | bash; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-galaxy; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-playbook; \
    cp /usr/local/bin/mockleton /usr/bin/ssh-add;

COPY . /resource/

RUN set -eux; \
    cd /resource; \
    rspec


FROM main
