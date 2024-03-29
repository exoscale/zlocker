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
            gitPbuilder('bionic', false, '../build-area-bionic')
          },
          "Focal": {
            build(repo)
            gitPbuilder('focal', false, '../build-area-focal')
          }
        )
      }

      stage('Upload') {
        aptlyUpload('staging', 'bionic', 'main', '../build-area-bionic/*deb')
        aptlyUpload('staging', 'focal', 'main', '../build-area-focal/*deb')
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
  docker.withRegistry("https://${EXOSCALE_DOCKER_REGISTRY}") {
    def image = docker.image("${EXOSCALE_DOCKER_REGISTRY}/exoscale/golang:1.11")
    image.pull()
    image.inside("-u root --net=host") { sh 'make lint' }
  }
}

def build(repo) {
  docker.withRegistry("https://${EXOSCALE_DOCKER_REGISTRY}") {
    def image = docker.image("${EXOSCALE_DOCKER_REGISTRY}/exoscale/golang:1.11")
    image.inside("-u root --net=host") { sh 'make' }
  }
}
