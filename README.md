Replicated Helm Starter
==================

Whether you are experienced in writing Helm charts or just starting out, the Replicated Helm Starter project will significanlty reduce the time it takes to write one. The Helm Replicated Starter solution substantially reduces boilerplate code and complexity in your charts thereby decreasing time-to-value.

Follow the "Get Started" steps below to setup your environment so begin writing a Helm chart.

## Prerequisites:
- A local K8s cluster
  - Any local Kubernetes solution (([k3d](https://k3d.io/), [Kind](https://kind.sigs.k8s.io/), [minikube](https://minikube.sigs.k8s.io/docs/)) will suffice.
  - Example, install a local Kind cluster on a local desktop:
    - Install Docker - [Instructions](https://docs.docker.com/get-docker/)
    - Install a Kubernetes Kind Cluster - [Instructions](https://kind.sigs.k8s.io/docs/user/quick-start/)
- Install Helm - [Instructions](https://helm.sh/docs/intro/install/)
- Click [here](https://github.com/replicatedhq/platform-examples) to clone the Replicated ***platform-examples repository*** which contains Helm Chart examples and resusable code snippets.
- Review [Writing Helm Charts - tips & tricks](#already-have-a-helm-chart)

## Get started

1. To create a copy of the **Replicated Helm Starter repository**, go to [Replicated Helm Starter Repo](https://github.com/replicatedhq/replicated-starter-helm) --> "Use This Template" dropdown --> "Create New Repository"
2. Clone your new repository
3. Edit Chart.yaml:
    - name:        <application_name>
    - description: <application_description>
    - appVersion:  <application_version>
    - home:        <application_repository_URL>
    
4. Update helm dependencies:  helm dependency update .

5. Install Replicated CLI - [Instructions](https://docs.replicated.com/reference/replicated-cli-installing#install-the-replicated-cli)

6. Configure environment variables -- [Instructions](https://docs.replicated.com/reference/replicated-cli-installing#set-environment-variables)

7. Start writing your Helm Chart


TODO -- CI Integration -- TODO
## Integrating with CI

This repo contains a [GitHub Actions](https://help.github.com/en/github/automating-your-workflow-with-github-actions/about-github-actions) workflow for ci at [./.github/workflows/main.yml](./.github/workflows/main.yml). You'll need to [configure secrets](https://help.github.com/en/github/automating-your-workflow-with-github-actions/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) for `REPLICATED_APP` and `REPLICATED_API_TOKEN`. On every push this will:


TODO -- Tips & Tricks -- TODO
## Writing Helm Charts - tips & tricks
blah, blah
