{ pkgs ? import <nixpkgs> {} }:pkgs.mkShell {
  packages = with pkgs; [
    awscli2
    azure-cli
    crossplane-cli
    gh
    gum
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    jq
    kind
    kubectl
    kubernetes-helm
    teller
    upbound
    yq-go
  ];
}
