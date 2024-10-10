#!/bin/bash

# 스크립트가 오류 발생 시 중지하도록 설정
set -e

# 함수: 오류 메시지를 출력하고 스크립트를 종료
error_exit() {
    echo "$1" >&2
    exit 1
}

# 최신 stable 버전의 kubectl 버전 정보를 가져오는 함수
get_latest_version() {
    curl -L -s https://dl.k8s.io/release/stable.txt
}

# 운영체제 감지
OS=$(uname | tr '[:upper:]' '[:lower:]')

# 아키텍처 감지
ARCH=$(uname -m)

# 운영체제에 따른 OS_NAME 설정
case "$OS" in
    linux)
        OS_NAME="linux"
        ;;
    darwin)
        OS_NAME="darwin"
        ;;
    *)
        error_exit "지원하지 않는 운영체제: $OS"
        ;;
esac

# 아키텍처에 따른 ARCH_NAME 설정
case "$ARCH" in
    x86_64|amd64)
        ARCH_NAME="amd64"
        ;;
    aarch64|arm64)
        ARCH_NAME="arm64"
        ;;
    *)
        error_exit "지원하지 않는 아키텍처: $ARCH"
        ;;
esac

# 다운로드할 kubectl URL 구성
VERSION=$(get_latest_version)
URL="https://dl.k8s.io/release/${VERSION}/bin/${OS_NAME}/${ARCH_NAME}/kubectl"

echo "kubectl ${VERSION}을(를) ${URL}에서 다운로드 중..."

# kubectl 다운로드
curl -LO "$URL"

# 실행 권한 부여
chmod +x kubectl

# 체크섬 파일 다운로드 URL 구성
CHECKSUM_URL="${URL}.sha256"

echo "체크섬 파일을 ${CHECKSUM_URL}에서 다운로드 중..."

# 체크섬 파일 다운로드
curl -LO "$CHECKSUM_URL"

# 체크섬 검증 함수
verify_checksum() {
    if [[ "$OS_NAME" == "darwin" ]]; then
        # macOS의 경우 shasum 사용
        echo "$(cat kubectl.sha256)  kubectl" | shasum -a 256 --check
    else
        # Linux의 경우 sha256sum 사용
        echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    fi
}

echo "kubectl 바이너리의 체크섬을 검증 중..."

# 체크섬 검증 수행
if verify_checksum; then
    echo "kubectl: OK"
else
    echo "kubectl: FAILED"
    echo "체크섬 검증에 실패했습니다. 다운로드한 바이너리를 신뢰할 수 없습니다."
    exit 1
fi

# 설치 함수: Linux
install_linux() {
    echo "kubectl을 /usr/local/bin에 설치 중..."
    if sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; then
        echo "kubectl이 /usr/local/bin/kubectl에 성공적으로 설치되었습니다."
    else
        echo "sudo 권한을 사용할 수 없거나 /usr/local/bin에 접근할 수 없습니다."
        echo "대신 ~/.local/bin에 kubectl을 설치합니다."
        mkdir -p ~/.local/bin
        chmod +x kubectl
        mv kubectl ~/.local/bin/kubectl
        echo "kubectl이 ~/.local/bin/kubectl에 성공적으로 설치되었습니다."
        echo "필요시 ~/.local/bin을 PATH에 추가하세요."
        echo "예: export PATH=\$HOME/.local/bin:\$PATH"
    fi
}

# 설치 함수: macOS
install_macos() {
    echo "kubectl을 /usr/local/bin에 설치 중..."
    sudo mv ./kubectl /usr/local/bin/kubectl
    sudo chown root: /usr/local/bin/kubectl
    echo "kubectl이 /usr/local/bin/kubectl에 성공적으로 설치되었습니다."
}

# 설치 및 검증 후 처리
if [[ "$OS_NAME" == "linux" ]]; then
    install_linux
elif [[ "$OS_NAME" == "darwin" ]]; then
    install_macos
fi

# 설치한 버전 확인
echo "설치된 kubectl 버전을 확인 중..."
kubectl version --client --output=yaml

# 체크섬 파일 삭제
rm kubectl.sha256

echo "kubectl 설치 및 검증이 완료되었습니다."
