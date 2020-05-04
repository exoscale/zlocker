@Library('jenkins-pipeline') _

repo = "exoscale/zlocker"

node {
  // Wipe the workspace so we are building completely clean
  cleanWs()

  try {
    dir('src') {
      stage('checkout source code') {
        checkout scm
      }
      updateGithubCommitStatus('PENDING', "${env.WORKSPACE}/src")
      stage('Test') {
        golint()
      }
      stage('Build') {
        parallel (
          "Bionic": {
            build(repo)
            gitPbuilder('bionic')
          },
          "Focal": {
            build(repo)
            gitPbuilder('focal')
          }
        )
      }

      stage('Upload') {
        parallel (
          "Bionic": {
            aptlyUpload('staging', 'bionic', 'main', '../build-area/*deb')
          },
          "Focal": {
            aptlyUpload('staging', 'focal', 'main', '../build-area/*deb')
          }
        )
      }
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

def golint() {
  docker.withRegistry('https://registry.internal.exoscale.ch') {
    def image = docker.image('registry.internal.exoscale.ch/exoscale/golang:1.11')
    image.pull()
    image.inside("-u root --net=host") { sh 'make lint' }
  }
}

def build(repo) {
  docker.withRegistry('https://registry.internal.exoscale.ch') {
    def image = docker.image('registry.internal.exoscale.ch/exoscale/golang:1.11')
    image.inside("-u root --net=host") { sh 'make' }
  }
}
