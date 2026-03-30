# Deploy ARC

```console
helm upgrade --install arc \
    --namespace "arc-system" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
```