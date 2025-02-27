#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
# The prefix is chosen to match what GitHub generates for source archives
# This guarantees that users can easily switch from a released artifact to a source archive
# with minimal differences in their code (e.g. strip_prefix remains the same)
PREFIX="bazel-lib-${TAG:1}"
ARCHIVE="bazel-lib-$TAG.tar.gz"
ARCHIVE_TMP=$(mktemp)

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix=${PREFIX}/ ${TAG} >$ARCHIVE_TMP

gzip <$ARCHIVE_TMP >$ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

# Random extra release file
echo "foo" > bar.txt

cat <<EOF > release_notes.txt

## Release notes

Foobar

\`\`\`

EOF

jq --null-input --arg archive "${ARCHIVE}" --arg bar "$(realpath bar.txt)" '{release_archive: $archive, upload_extra_artifacts: [$bar], release_notes: "release_notes.txt"}'