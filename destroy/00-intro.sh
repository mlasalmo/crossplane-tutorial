#!/usr/bin/env bash
set -e

gum style \
  --foreground 212 --border-foreground 212 --border double \
  --margin "1 2" --padding "2 4" \
  'Destruction of the Introduction chapter'

gum confirm '
Are you ready to start?
Select "Yes" only if you did NOT follow the story from the start (if you jumped straight into this chapter).
Feel free to say "No" and inspect the script if you prefer setting up resources manually.
' || exit 0

echo "
## You will need following tools installed:
|Name                                       |Required                |More info                                                                      |
|-------------------------------------------|------------------------|-------------------------------------------------------------------------------|
|AWS CLI                                    |If using AWS            |'https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html'|
|AWS account with admin permissions         |If using AWS            |'https://aws.amazon.com'                                                       |
|Azure account with admin permissions       |If using Azure          |'https://azure.microsoft.com'                                                  |
|Docker                                     |Yes                     |'https://docs.docker.com/engine/install'                                       |
|Google Cloud CLI                           |If using Google Cloud   |'https://cloud.google.com/sdk/docs/install'                                    |
|Google Cloud account with admin permissions|If using Google Cloud   |'https://cloud.google.com'                                                     |
|Linux Shell                                |Yes                     |Use WSL if you are running Windows                                             |
|az CLI                                     |If using Azure          |'https://learn.microsoft.com/cli/azure/install-azure-cli'                      |
|crossplane CLI                             |Yes                     |'https://docs.crossplane.io/latest/cli'                                        |
|k3d CLI                                    |If using rancher-desktop|'https://k3d.io/v5.6.0/#installation                                           |
|kind CLI                                   |If using docker-desktop |'https://kind.sigs.k8s.io/docs/user/quick-start/#installation'                 |
|kubectl CLI                                |Yes                     |'https://kubernetes.io/docs/tasks/tools/#kubectl'                              |
|yq CLI                                     |Yes                     |'https://github.com/mikefarah/yq#install'                                      |

If you are running this script from **Nix shell**, most of the requirements are already set with the exception of **Docker** and the **hyperscaler account**.
" | gum format

gum confirm "
Do you have those tools installed?
" || exit 0

##############
# Crossplane #
##############

rm -f a-team/intro.yaml

git add .

git commit -m "Remove intro"

git push

COUNTER=$(kubectl get managed --no-headers | grep -v database | grep -v object | grep -cv release)

while [ "$COUNTER" -ne 0 ]; do
  echo "$COUNTER resources still exist. Waiting for them to be deleted..."
  sleep 10
  COUNTER=$(kubectl get managed --no-headers | grep -v database | grep -v object | grep -cv release)
done

if [[ "$HYPERSCALER" == "google" ]]; then

	gcloud projects delete "$PROJECT_ID" --quiet

fi

#########################
# Control Plane Cluster #
#########################

kind delete cluster

##################
# Commit Changes #
##################

git add .

git commit -m "Chapter end"

git push
