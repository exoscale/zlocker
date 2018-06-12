@Library('jenkins-pipeline') _

node {
  // Wipe the workspace so we are building completely clean
  cleanWs()

  try {
    dir('src') {
      stage('checkout source code') {
        checkout scm
      }
      updateGithubCommitStatus('PENDING', "${env.WORKSPACE}/src")
      stage('dep') {
        godep()
      }
      stage('Build') {
        parallel (
          "go lint": {
            golint()
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
      currentBuild.result = 'SUCCESS'
    }
    updateGithubCommitStatus(currentBuild.result, "${env.WORKSPACE}/src")
  }
}

def godep() {
  docker.withRegistry('https://registry.internal.exoscale.ch') {
    def image = docker.image('registry.internal.exoscale.ch/exoscale/golang:1.10')
    image.pull()
    image.inside("-u root --net=host -v ${env.WORKSPACE}/src:/go/src/github.com/exoscale/zlocker") {
      sh 'test `gofmt -s -d -e . | tee -a /dev/fd/2 | wc -l` -eq 0'
      sh 'cd /go/src/github.com/exoscale/zlocker && dep ensure -v -vendor-only'
    }
  }
}

def golint() {
  docker.withRegistry('https://registry.internal.exoscale.ch') {
    def image = docker.image('registry.internal.exoscale.ch/exoscale/golang:1.10')
    image.pull()
    image.inside("-u root --net=host -v ${env.WORKSPACE}/src:/go/src/github.com/exoscale/zlocker") {
      sh 'golint -set_exit_status -min_confidence 0.6 $(go list github.com/exoscale/zlocker/... | grep -v /vendor/)'
      sh 'go vet $(go list github.com/exoscale/zlocker/... | grep -v /vendor/)'
    }
  }
}

def build() {
  docker.withRegistry('https://registry.internal.exoscale.ch') {
    def image = docker.image('registry.internal.exoscale.ch/exoscale/golang:1.10')
    image.inside("-u root --net=host -v ${env.WORKSPACE}/src:/go/src/github.com/exoscale/zlocker") {
      sh 'cd /go/src/github.com/exoscale/zlocker && dep ensure'
      sh 'cd /go/src/github.com/exoscale/zlocker && CGO_ENABLED=0 go build -ldflags "-s"'
    }
  }
}
