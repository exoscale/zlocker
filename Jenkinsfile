@Library('jenkins-pipeline') _

node {
  // Wipe the workspace so we are building completely clean
  cleanWs()

  try {
    dir('src') {
      stage('checkout source code') {
        checkout scm
      }

      Build()

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

def Build() {
  def golang = docker.image('golang:latest')
  golang.pull()
  stage('build') {
    golang.inside() {
      sh 'mkdir -p /go/src/zlocker'
      sh 'cp Gopkg.lock  Gopkg.toml  Jenkinsfile  Makefile  README.md zlocker.go /go/src/zlocker'
      sh 'cd /go/src/zlocker && make'
      sh 'cp /go/src/zlocker/zlocker .'
      sh 'make version > .version'
    }
  }
}
