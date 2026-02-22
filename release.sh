git fetch --tags --force

LATEST_REMOTE_TAG=$(git describe --tags --abbrev=0)

read -p "Enter new version tag (current: $LATEST_REMOTE_TAG): " NEW_TAG

# Deletes the current tag locally, remotely and 
# deletes the latest release if NEW_TAG matches LATEST_REMOTE_TAG
if [ "$NEW_TAG" == "$LATEST_REMOTE_TAG" ]; then
    git tag --delete "$LATEST_REMOTE_TAG"
    gh release delete "$LATEST_REMOTE_TAG" -y
    git push remote --delete "$LATEST_REMOTE_TAG"
fi

git tag "$NEW_TAG"
git push remote "$NEW_TAG"
