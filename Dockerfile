FROM jenkins/jenkins:lts

USER root
RUN apt-get update \
      && apt-get install -y sudo curl  libltdl-dev \
      && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://get.docker.com/ | sh

RUN usermod -a -G docker jenkins

RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

VOLUME /var/jenkins_home
RUN mkdir -p /var/casc_config

RUN chown jenkins:jenkins -R /var/jenkins_home /var/casc_config

USER jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt

RUN jenkins-plugin-cli -f  /usr/share/jenkins/plugins.txt

COPY jenkins.yaml  /var/casc_config/jenkins.yaml
ENV CASC_JENKINS_CONFIG /var/casc_config/jenkins.yaml

#Update the username and password
ENV JENKINS_USER admin
ENV JENKINS_PASS ThisIs@StrongP@ssword
ENV OPENSHIFT_ENABLE_OAUTH true
# allows to skip Jenkins setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Jenkins runs all grovy files from init.groovy.d dir
# use this for creating default admin user
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/