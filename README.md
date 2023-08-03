# git-release

## Installation

```
upkg install -g orbit-online/git-release@<VERSION>
```

## Usage

Tag git commits using semver versioning.  
Tag/release messages are templated with commit messages from all changes since
the last change.

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
