#!/bin/bash

# 리눅스 확인
OS="$(uname -s)"
if [ "$OS" == "Linux" ]; then
    echo "쿠버네티스를 위한 레포지토리 추가 및 패키지 설치를 시작합니다..."

    # 시스템 업데이트 및 필수 패키지 설치
    echo "필수 패키지를 설치합니다..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg

    # /etc/apt/keyrings 디렉터리 생성 (없을 경우)
    if [ ! -d /etc/apt/keyrings ]; then
        echo "/etc/apt/keyrings 디렉터리를 생성합니다..."
        sudo mkdir -p -m 755 /etc/apt/keyrings
    fi

    # Kubernetes 레포지토리 키 다운로드 및 설정
    echo "Kubernetes 레포지토리 키를 설정합니다..."
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # Kubernetes 레포지토리 추가
    echo "Kubernetes 레포지토리를 추가합니다..."
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    # 패키지 리스트 업데이트 및 kubelet, kubeadm, kubectl 설치
    echo "Kubernetes 패키지를 설치합니다..."
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl

    # kubelet, kubeadm, kubectl 버전 고정
    sudo apt-mark hold kubelet kubeadm kubectl

    # kubelet 활성화 및 부팅 시 자동 시작 설정
    echo "kubelet을 활성화하고 자동으로 시작되도록 설정합니다..."
    sudo systemctl enable --now kubelet

    echo "설치 및 설정이 완료되었습니다."

else
    echo "이 스크립트는 리눅스 우분투에서만 작동합니다."
    exit 1
fi
