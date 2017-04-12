FROM centos:centos7

MAINTAINER Ramesh  <ramesh.yvrr@gmail.com>
 
RUN yum install -y unzip 

# Configure instance
ADD linuxamd64_12102_database_1of2.zip /tmp/linuxamd64_12102_database_1of2.zip
ADD linuxamd64_12102_database_2of2.zip /tmp/linuxamd64_12102_database_2of2.zip
ADD oracle.sh /tmp/oracle.sh
RUN chmod 755 /tmp/oracle.sh

RUN ./tmp/oracle.sh

EXPOSE 1521
EXPOSE 8080
