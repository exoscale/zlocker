@Library('jenkins-pipeline') _

node {
  // Wipe the workspace so we are building completely clean
  cleanWs()

  try {
    dir('src') {
      stage('checkout source code') {
        checkout scm
      }
      stage('Build') {
        parallel (
          "go lint": {
            lint()
          },
          "go build": {
            build()
          }
        )
      }
      stage('build deb package') {
        gitPbuilder('bionic')
      }

    }

    stage('upload packages') {
      aptlyUpload('staging', 'bionic', 'main', 'build-area/*deb')
    }

  }
  catch (err) {
    currentBuild.result = 'FAILURE'
    throw err
  }

  finally {
    if (currentBuild.result != 'FAILURE') {
    }
  }
}

def lint() {
  docker.withRegistry('https://registry.internal.exoscale.ch') {
    def image = docker.image('registry.internal.exoscale.ch/exoscale/golang:1.10')
    image.pull()
    image.inside("-u root --net=host -v ${env.WORKSPACE}/src:/go/src/github.com/exoscale/zlocker") {
      sh 'test `gofmt -s -d -e . | tee -a /dev/fd/2 | wc -l` -eq 0'
      sh 'golint -set_exit_status'
      sh 'go tool vet .'
    }
  }
}

def build() {
  docker.withRegistry('https://registry.internal.exoscale.ch') {
    def image = docker.image('registry.internal.exoscale.ch/exoscale/golang:1.10')
    image.inside("-u root --net=host -v ${env.WORKSPACE}/src:/go/src/github.com/exoscale/zlocker") {
      sh 'cd /go/src/github.com/exoscale/zlocker && dep ensure'
      sh 'cd /go/src/github.com/exoscale/zlocker && go build'
    }
  }
}
