#!/bin/bash

# 리눅스 확인
OS="$(uname -s)"
if [ "$OS" == "Linux" ]; then
    echo "우분투에서 Docker 및 Containerd 설치를 시작합니다..."

    # 필수 패키지 설치
    sudo apt update
    sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

    # Docker 레포지토리 추가
    echo "Docker 레포지토리를 추가합니다..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # 패키지 업데이트 및 필수 패키지 설치
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Containerd 설치
    echo "Containerd 설치를 진행합니다..."
    sudo apt update
    sudo apt install -y containerd.io

    # Containerd를 Systemd Cgroup으로 설정
    echo "Containerd를 SystemdCgroup으로 설정합니다..."
    sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

    # Containerd 재시작 및 활성화
    echo "Containerd를 재시작하고 활성화합니다..."
    sudo systemctl restart containerd
    sudo systemctl enable containerd

    # Containerd 상태 확인
    echo "Containerd 상태를 확인합니다..."
    sudo systemctl status containerd --no-pager

    echo "설치 및 설정이 완료되었습니다."

else
    echo "이 스크립트는 리눅스 우분투에서만 작동합니다."
    exit 1
fi

#!/bin/bash

# 리눅스 확인
OS="$(uname -s)"
if [ "$OS" == "Linux" ]; then
    echo "우분투에서 Docker 및 Containerd 설치를 시작합니다..."

    # 필수 패키지 설치
    sudo apt update
    sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

    # Docker 레포지토리 추가
    echo "Docker 레포지토리를 추가합니다..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # 패키지 업데이트 및 필수 패키지 설치
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Containerd 설치
    echo "Containerd 설치를 진행합니다..."
    sudo apt update
    sudo apt install -y containerd.io

    # Containerd를 Systemd Cgroup으로 설정
    echo "Containerd를 SystemdCgroup으로 설정합니다..."
    sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

    # Containerd 재시작 및 활성화
    echo "Containerd를 재시작하고 활성화합니다..."
    sudo systemctl restart containerd
    sudo systemctl enable containerd

    # Containerd 상태 확인
    echo "Containerd 상태를 확인합니다..."
    sudo systemctl status containerd --no-pager

    echo "설치 및 설정이 완료되었습니다."

else
    echo "이 스크립트는 리눅스 우분투에서만 작동합니다."
    exit 1
fi
