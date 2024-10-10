#!/bin/bash

# 스크립트들이 위치한 디렉터리로 이동
cd "$(dirname "$0")"

# OS 확인
OS="$(uname -s)"

# 모든 OS에서 공통적으로 실행할 스크립트 권한 부여
chmod +x kubectlInstaller.sh kubeadmInstaller.sh container.sh k8sPackage.sh nodeSetting.sh

# 스크립트 실행 순서대로 실행
echo "1. kubectlInstaller.sh 실행 중..."
./kubectlInstaller.sh
if [ $? -ne 0 ]; then
  echo "kubectlInstaller.sh 실행 중 오류 발생. 프로세스를 종료합니다."
  exit 1
fi
echo "kubectlInstaller.sh 실행 완료."

echo "2. kubeadmInstaller.sh 실행 중..."
./kubeadmInstaller.sh
if [ $? -ne 0 ]; then
  echo "kubeadmInstaller.sh 실행 중 오류 발생. 프로세스를 종료합니다."
  exit 1
fi
echo "kubeadmInstaller.sh 실행 완료."

# macOS일 경우 여기서 멈춤
if [ "$OS" == "Darwin" ]; then
    echo "macOS에서 실행 중이므로 kubeadmInstaller.sh까지 실행 후 종료합니다."
    exit 0
fi

# 리눅스일 경우 나머지 스크립트 계속 실행
echo "3. container.sh 실행 중..."
./container.sh
if [ $? -ne 0 ]; then
  echo "container.sh 실행 중 오류 발생. 프로세스를 종료합니다."
  exit 1
fi
echo "container.sh 실행 완료."

echo "4. k8sPackage.sh 실행 중..."
./k8sPackage.sh
if [ $? -ne 0 ]; then
  echo "k8sPackage.sh 실행 중 오류 발생. 프로세스를 종료합니다."
  exit 1
fi
echo "k8sPackage.sh 실행 완료."

echo "5. nodeSetting.sh 실행 중..."
./nodeSetting.sh
if [ $? -ne 0 ]; then
  echo "nodeSetting.sh 실행 중 오류 발생. 프로세스를 종료합니다."
  exit 1
fi
echo "nodeSetting.sh 실행 완료."

echo "모든 스크립트가 성공적으로 실행되었습니다."
