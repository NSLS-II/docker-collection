#!/bin/bash

# Check if the required DOCKER_ID_USER is set up in the env vars
# env | grep 'DOCKER_ID_USER=' || (echo 'ERROR: "DOCKER_ID_USER" must be set up in your env' && exit 1)
DOCKER_ID_USER=nsls2
image_name='nsls2-collection'

timestamp="$(date +%Y%m%d%H%M%S)"
tag="collection-2019C2.0"
logfile="build_${timestamp}_${tag}.log"

# Main building process
docker image build --no-cache \
                   -t $DOCKER_ID_USER/${image_name}:latest \
                   -t $DOCKER_ID_USER/${image_name}:${tag} \
                   . > $logfile 2>&1

# Check if the image was built successfully. Example of last 3 lines:
#  ---> 895eb9854400
# Successfully built 895eb9854400
# Successfully tagged mrakitin/<image_name>:latest
# Successfully tagged mrakitin/<image_name>:20180628090130

out=$(tail -3 $logfile | grep -i 'Successfully built') || exit 1

# Get Image ID and check if it exists in the `docker image` output
image_id=$(echo $out | awk '{print $3}')
echo "Generated image ID: ${image_id}" >> $logfile 2>&1
echo -e  "\nDocker images:"            >> $logfile 2>&1
docker images | grep ${image_id}       >> $logfile 2>&1

# Push the built images (requires running "docker login" before)
docker push $DOCKER_ID_USER/${image_name}:latest >> $logfile 2>&1 || exit 1
docker push $DOCKER_ID_USER/${image_name}:${tag} >> $logfile 2>&1 || exit 1

exit 9999

# Remove timestamped tag, so that next time it's built, the existing tags are
# not pushed to https://hub.docker.com
docker rmi $DOCKER_ID_USER/${image_name}:${tag} >> $logfile 2>&1
# Remove previous latest tag, which appears as <none>
docker rmi $(docker images $DOCKER_ID_USER/${image_name} --filter "dangling=true" -q --no-trunc) >> $logfile 2>&1

