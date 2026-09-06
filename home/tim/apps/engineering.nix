{ pkgs, ... }:

let
  kubeDoctor = pkgs.writeShellScriptBin "kube-doctor" ''
    set -e

    echo "kubectl:"
    ${pkgs.kubectl}/bin/kubectl version --client=true

    echo
    echo "context:"
    context="$(${pkgs.kubectl}/bin/kubectl config current-context 2>/dev/null || true)"
    if [ -n "$context" ]; then
      echo "$context"

      echo
      echo "cluster:"
      ${pkgs.kubectl}/bin/kubectl cluster-info || true
    else
      echo "no current context"
    fi

    echo
    echo "helm:"
    ${pkgs.kubernetes-helm}/bin/helm version --short

    echo
    echo "kustomize:"
    ${pkgs.kustomize}/bin/kustomize version

    echo
    echo "kind clusters:"
    clusters="$(${pkgs.kind}/bin/kind get clusters 2>/dev/null || true)"
    if [ -n "$clusters" ]; then
      echo "$clusters"
    else
      echo "none"
    fi

    echo
    echo "minikube:"
    ${pkgs.minikube}/bin/minikube status || true
  '';

  kubeValidate = pkgs.writeShellScriptBin "kube-validate" ''
    set -e

    if [ -f Chart.yaml ]; then
      ${pkgs.kubernetes-helm}/bin/helm lint .
    fi

    if [ -f kustomization.yaml ] || [ -f kustomization.yml ] || [ -f Kustomization ]; then
      ${pkgs.kustomize}/bin/kustomize build . | ${pkgs.kubeconform}/bin/kubeconform -strict -summary -
      exit 0
    fi

    if [ "$#" -eq 0 ]; then
      ${pkgs.kubeconform}/bin/kubeconform -strict -summary .
    else
      ${pkgs.kubeconform}/bin/kubeconform -strict -summary "$@"
    fi
  '';

  kindUp = pkgs.writeShellScriptBin "kind-up" ''
    set -e

    name="''${1:-dev}"

    if ${pkgs.kind}/bin/kind get clusters | ${pkgs.gnugrep}/bin/grep -qx "$name"; then
      echo "kind cluster '$name' already exists"
      exit 0
    fi

    ${pkgs.kind}/bin/kind create cluster --name "$name" --wait 120s
  '';

  kindDown = pkgs.writeShellScriptBin "kind-down" ''
    set -e

    name="''${1:-dev}"
    ${pkgs.kind}/bin/kind delete cluster --name "$name"
  '';

  goCheck = pkgs.writeShellScriptBin "go-check" ''
    set -e

    if [ ! -f go.mod ]; then
      echo "go-check: no go.mod in current directory" >&2
      exit 1
    fi

    files="$(${pkgs.git}/bin/git ls-files '*.go' 2>/dev/null || ${pkgs.findutils}/bin/find . -name '*.go' -not -path './vendor/*')"
    if [ -n "$files" ]; then
      unformatted="$(printf '%s\n' "$files" | ${pkgs.findutils}/bin/xargs -r ${pkgs.go}/bin/gofmt -l)"
      if [ -n "$unformatted" ]; then
        echo "$unformatted"
        echo "go-check: gofmt required" >&2
        exit 1
      fi
    fi

    ${pkgs.go}/bin/go test ./...
    ${pkgs.golangci-lint}/bin/golangci-lint run ./...
  '';

  javaCheck = pkgs.writeShellScriptBin "java-check" ''
    set -e

    export JAVA_HOME=${pkgs.jdk25.home}
    export PATH="$JAVA_HOME/bin:$PATH"

    if [ -x ./gradlew ]; then
      ./gradlew test
    elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
      ${pkgs.gradle}/bin/gradle test
    elif [ -x ./mvnw ]; then
      ./mvnw test
    elif [ -f pom.xml ]; then
      ${pkgs.maven}/bin/mvn test
    else
      echo "java-check: no Gradle or Maven project in current directory" >&2
      exit 1
    fi
  '';
in
{
  home.packages = with pkgs; [
    delve
    dive
    go
    goCheck
    golangci-lint
    gopls
    goreleaser
    gotools
    gradle
    javaCheck
    jdk25
    jdt-language-server
    jq
    k9s
    kind
    kubeDoctor
    kubeValidate
    kubeconform
    kubectl
    kubectx
    kubelogin
    kubernetes-helm
    kubeseal
    kubent
    kustomize
    kindDown
    kindUp
    maven
    minikube
    opentofu
    skaffold
    spring-boot-cli
    stern
    tilt
    yq-go
  ];

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk25.home}";
  };
}
