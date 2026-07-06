# git-release

Tag git commits using semver versioning.  
Tag/release messages are templated with all commit messages since the last tag.

## Installation

See [the latest release](https://github.com/orbit-online/git-release/releases/latest) for instructions.

## Usage

When bumping a version git-release only considers the latest tag that is
reachable from the tagged commit, the benefit being that you can maintain e.g.
both a v1.x and v2.x branch. Conversely, tags that are not part of the branch
the commit is on will not be discovered.

```
git-release - Tag REF by either bumping the last version or specifying one
Usage:
  git-release [-dnh] previous [REF]
  git-release [options] (major|minor|patch) [REF]
  git-release [options] VERSION [REF]

Options:
  --ignore-dirty  Ignore a dirty working copy when REF is HEAD
  -d, --debug     Turn on bash -x
  -n, --dry-run   Show the commands instead of running them and show changelog
  -h, --help      Show this screen

Notes:
  git-release automatically determines the previous version using git-describe
  and then bumps the specified part of that version.
  Use `git-release previous' to show the previous version based on REF.
  REF defaults to HEAD.
```

## Github action

You can extract the tag and tag message using the `orbit-online/git-release`
action in order to automate GitHub releases:

```
name: Release

on:
  push:
    tags: ['v*']

jobs:
  release:
    permissions:
      contents: write
    runs-on: ubuntu-latest
    name: Create GitHub release
    steps:
    - uses: actions/checkout@v7
      with:
        ref: ${{ github.ref }}
    - name: Get release notes
      id: release
      uses: orbit-online/git-release@v1
    - name: Create Release
      uses: ncipollo/release-action@v1
      with:
        name: ${{ steps.release.outputs.tag }}
        body: ${{ steps.release.outputs.message }}
        draft: false
        prerelease: false
        artifactErrorsFailBuild: true
```

### Inputs

| Name                | Description                            | Default             |
| ------------------- | -------------------------------------- | ------------------- |
| `ref`               | The git ref to use                     | `${{ github.ref }}` |
| `working-directory` | The working copy of the git repository | `.`                 |

### Outputs

| Name      | Description     |
| --------- | --------------- |
| `tag`     | The git tag     |
| `message` | The tag message |
