# 采用java官方镜像做为构建镜像，编译
FROM maven:3.6.0-jdk-8-slim AS build
# 设置应用工作目录
WORKDIR /app
# 将所有文件拷贝到容器中
COPY . .
# 编译项目
RUN mvn -B -e -U -s settings.xml clean package


#jdk基础镜像源
FROM openjdk:8-buster
# 设定时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN echo "deb http://mirrors.aliyun.com/debian/ buster main non-free contrib" > /etc/apt/sources.list \
&& echo "deb-src http://mirrors.aliyun.com/debian/ buster main non-free contrib" >> /etc/apt/sources.list 
#设置apt证书
RUN apt update && apt install -y gnupg apt-utils && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138 0E98404D386FA1D9	
RUN echo "deb http://mirrors.aliyun.com/debian-security buster/updates main" >> /etc/apt/sources.list \
&& echo "deb-src http://mirrors.aliyun.com/debian-security buster/updates main" >> /etc/apt/sources.list \
&& echo "deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib" >> /etc/apt/sources.list \
&& echo "deb-src http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib" >> /etc/apt/sources.list \
&& echo "deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib" >> /etc/apt/sources.list \
&& echo "deb-src http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib" >> /etc/apt/sources.list
RUN apt update && apt install -y curl

#设置当前目录，没有的话会自动新建

WORKDIR /data

#将构建产物拷贝到运行时工作的目录
COPY --from=build /app/**/*.jar /data/

#添加全链路监控agent
#RUN mkdir -p /home/admin/cloudrun/ && curl https://ant-trace.opentrscdn.com/skywalking-agent.tar.gz --output /home/admin/cloudrun/skywalking-agent.tar.gz &&  tar -zxvf /home/admin/cloudrun/skywalking-agent.tar.gz -C /home/admin/cloudrun/

#暴露服务端口
EXPOSE 80
#设置初始的java启动参数，后续可以在服务启动的环境变量里面覆盖
ENV JAVA_OPT="-Xmx1g -Xms1g -Xmn256m"
#java启动命令，可以加参数
CMD ["sh","-c","java $JAVA_OPT -jar antcloud-0.0.1-SNAPSHOT.jar"]