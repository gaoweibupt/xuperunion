ARCH=arm64
CROSS_COMPILE=arm-linux-gnueabihf-


ifeq ($(OS),Windows_NT)
  PLATFORM="Windows"
else
  ifeq ($(shell uname),Darwin)
    PLATFORM="MacOS"
  else
    PLATFORM="Linux"
  endif
endif


all: build

export GO111MODULE=on
XCHAIN_ROOT := ${PWD}/core
export XCHAIN_ROOT
PATH := ${PWD}/core/xvm/compile/wabt/build:$(PATH)


build: build-release

build-release:
	git clone https://github.com/xuperchain/crypto.git ./../crypto
	PLATFORM=$(PLATFORM) ./core/scripts/build.sh


build-debug:
	PLATFORM=$(PLATFORM) XCHAIN_BUILD_DEBUG=1 ./core/scripts/build.sh

test:
	go test -coverprofile=coverage.txt -covermode=atomic ./...
	# test wasm sdk
	GOOS=js GOARCH=wasm go build github.com/xuperchain/xuperchain/core/contractsdk/go/driver

contractsdk:
	make -C core/contractsdk/cpp build
	make -C core/contractsdk/cpp test

clean:
	rm -rf core/plugins
	rm -rf output
	rm -f xchain-cli
	rm -f xchain
	rm -f dump_chain
	rm -f event_client
	rm -rf ./core/xvm/compile/wabt/build/
	rm -rf ./../crypto
.PHONY: all test clean
