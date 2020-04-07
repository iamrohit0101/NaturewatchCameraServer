# Build
#FROM raspbian/stretch as build
#RUN curl -o node-v9.7.1-linux-armv6l.tar.gz https://nodejs.org/dist/v9.7.1/node-v9.7.1-linux-armv6l.tar.gz
#RUN tar -xzf node-v9.7.1-linux-armv6l.tar.gz
#COPY node-v9.7.1-linux-armv6l/* /usr/local/
#RUN apt-get update && apt-get install git
#RUN npm config set unsafe-perm true
FROM nodered/node-red:1.0.1-10-minimal-arm32v6 as build
WORKDIR /admin-client
COPY admin-client/package.json /admin-client/package.json
RUN npm install --silent
RUN npm install react-scripts -g --silent
COPY admin-client /admin-client
RUN npm run build

# Production
FROM sgtwilko/rpi-raspbian-opencv:stretch-latest

# Install python dependencies
COPY requirements-pi.txt .
COPY requirements.txt .
RUN pip3 install -r requirements-pi.txt
RUN apt-get update
RUN apt-get install -y gpac

# Bundle source
COPY naturewatch_camera_server naturewatch_camera_server
COPY --from=build /admin-client/build naturewatch_camera_server/static/client/build

# Expose port
EXPOSE 5000

# Run
CMD ["python3", "-m", "naturewatch_camera_server"]
