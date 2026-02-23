# Build Locally

## Requirements

- `bluebuild`
- `podman`

## Build OCI Archive

```bash
bluebuild --log-out .state/logs build --archive oci recipes/recipe.yml
```

## Load and Tag

```bash
sudo podman load -i oci/cinnamon.tar.gz
sudo podman images
sudo podman tag <NEW_IMAGE_ID> localhost/cinnamon:latest
```

