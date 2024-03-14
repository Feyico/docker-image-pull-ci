#!/usr/bin/env bash

function DockerImages() {
    while IFS= read -r line; do
        #忽略空行和注释
        if [[ ${line} == "" ]] || [[ -n $(echo ${line} | grep "^#") ]]; then
            continue
        fi
      
        docker_image_name=$(echo "feyico/${line//\//-}")
        #amd64镜像处理
        docker pull --platform=linux/amd64 ${line}
        docker tag ${line} ${docker_image_name}-amd64
        docker push ${docker_image_name}-amd64
        
        #arm64镜像处理
        docker pull --platform=linux/arm64 ${line}
        docker tag ${line} ${docker_image_name}-arm64
        docker push ${docker_image_name}-arm64

        #创建manifest
        docker manifest create ${docker_image_name} \
                                 ${docker_image_name}-amd64 \
                                 ${docker_image_name}-arm64 --amend

        docker manifest push ${docker_image_name}
        
    done < images-info | grep -v "^#"
}

DockerImages

exit 0
