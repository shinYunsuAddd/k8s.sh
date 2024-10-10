#!/bin/bash

# OS 확인
OS="$(uname -s)"

# 리눅스일 때 실행
if [ "$OS" == "Linux" ]; then
    echo "리눅스 시스템에서 설정을 시작합니다..."

    # 스왑 메모리 해제
    sudo swapoff -a
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    # kube_install.sh 스크립트 생성 및 실행
    cat <<EOF > kube_install.sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
EOF

    sudo sh kube_install.sh

    # IP Forwarding 활성화
    sudo sed -i '/net.ipv4.ip_forward/s/^#//g' /etc/sysctl.conf
    sudo sysctl --system  # 시스템 전체 설정 적용
    cat /proc/sys/net/ipv4/ip_forward  # 1인지 확인

    # 브리지 네트워크 필터링 활성화
    sudo modprobe br_netfilter
    echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

    # 방화벽 설정: UFW 사용 여부 확인
    if command -v ufw &> /dev/null; then
        echo "UFW 방화벽이 감지되었습니다. 필요한 포트만 열겠습니다."

        read -p "Master(M) 또는 Worker(W) 노드를 설정하시겠습니까? (M/W): " NODE_TYPE

        if [ "$NODE_TYPE" == "M" ]; then
            echo "Master 노드 방화벽 설정을 진행합니다..."
            sudo ufw allow 6443/tcp  # Kubernetes API 서버
            sudo ufw allow 2379:2380/tcp  # etcd 서버 클러스터 통신
            sudo ufw allow 10250/tcp  # Kubelet API
            sudo ufw allow 10257/tcp  # 컨트롤러 관리자
            sudo ufw allow 10259/tcp  # 스케줄러
        elif [ "$NODE_TYPE" == "W" ]; then
            echo "Worker 노드 방화벽 설정을 진행합니다..."
            sudo ufw allow 10250/tcp  # Kubelet API
            sudo ufw allow 30000:32767/tcp  # NodePort 서비스
        else
            echo "잘못된 입력입니다. M 또는 W를 입력해주세요."
            exit 1
        fi

        sudo ufw reload  # 변경사항 적용
    else
        echo "firewalld 방화벽 설정을 진행합니다."

        # firewalld 설치 (필요 시)
        if ! command -v firewall-cmd &> /dev/null; then
            echo "firewalld가 설치되어 있지 않습니다. 설치를 진행합니다..."
            sudo apt-get install -y firewalld
            sudo systemctl start firewalld
            sudo systemctl enable firewalld
        fi

        read -p "Master(M) 또는 Worker(W) 노드를 설정하시겠습니까? (M/W): " NODE_TYPE

        if [ "$NODE_TYPE" == "M" ]; then
            echo "Master 노드 방화벽 설정을 진행합니다..."
            sudo firewall-cmd --permanent --add-port=6443/tcp
            sudo firewall-cmd --permanent --add-port=2379-2380/tcp
            sudo firewall-cmd --permanent --add-port=10250/tcp
            sudo firewall-cmd --permanent --add-port=10257/tcp
            sudo firewall-cmd --permanent --add-port=10259/tcp
            sudo firewall-cmd --reload
        elif [ "$NODE_TYPE" == "W" ]; then
            echo "Worker 노드 방화벽 설정을 진행합니다..."
            sudo firewall-cmd --permanent --add-port=10250/tcp
            sudo firewall-cmd --permanent --add-port=30000-32767/tcp
            sudo firewall-cmd --reload
        else
            echo "잘못된 입력입니다. M 또는 W를 입력해주세요."
            exit 1
        fi
    fi

elif [ "$OS" == "Darwin" ]; then
    echo "맥 OS에서 설정을 시작합니다..."

    # Homebrew로 minikube 설치
    if ! command -v brew &> /dev/null; then
        echo "Homebrew가 설치되어 있지 않습니다. 설치를 진행합니다..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "Homebrew를 사용하여 Minikube를 설치합니다..."
    brew update
    brew install minikube

    echo "kubectl도 설치합니다..."
    brew install kubectl

    # IP Forwarding 활성화
    sudo sysctl -w net.inet.ip.forwarding=1

    # 브리지 네트워크 필터링 활성화 (맥OS에서는 불필요하지만 참고용으로 둡니다)
    sudo modprobe br_netfilter || echo "br_netfilter 모듈을 로드할 수 없습니다."

else
    echo "지원하지 않는 운영체제입니다."
    exit 1
fi

echo "설정이 완료되었습니다."
