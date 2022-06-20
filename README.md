# git-release

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
  release [options] (major|minor|patch) [REF]
  release [options] VERSION [REF]

Options:
  --ignore-dirty  Ignore a dirty working copy when REF is HEAD
  -d, --debug     Turn on bash -x
  -n, --dry-run   Show the commands instead of running them and show changelog
  -h, --help      Show this screen

Notes:
  git-release automatically determines the last version based on the tags
  reachable from REF and then bumps the specified part of that version.
  REF defaults to HEAD.
```
