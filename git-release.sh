#!/usr/bin/env bash

set -eo pipefail

main() {
  local pkgroot
  pkgroot=$(upkg root "${BASH_SOURCE[0]}")
  # shellcheck source=.upkg/orbit-online/records.sh/records.sh
  source "$pkgroot/.upkg/orbit-online/records.sh/records.sh"
  DOC="git-release - Tag REF by either bumping the last version or specifying one
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
  Use \`git-release previous' to show the previous version based on REF.
  REF defaults to HEAD.
"
# docopt parser below, refresh this parser with `docopt.sh git-release`
# shellcheck disable=2016,1090,1091,2034
docopt() { source "$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh" '1.0.0' || {
ret=$?; printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e
trimmed_doc=${DOC:0:662}; usage=${DOC:75:130}; digest=468c4
shorts=(-d -n -h ''); longs=(--debug --dry-run --help --ignore-dirty)
argcounts=(0 0 0 0); node_0(){ switch __debug 0; }; node_1(){ switch __dry_run 1
}; node_2(){ switch __help 2; }; node_3(){ switch __ignore_dirty 3; }; node_4(){
value REF a; }; node_5(){ value VERSION a; }; node_6(){ _command previous; }
node_7(){ _command major; }; node_8(){ _command minor; }; node_9(){
_command patch; }; node_10(){ optional 0 1 2; }; node_11(){ optional 4; }
node_12(){ required 10 6 11; }; node_13(){ optional 3; }; node_14(){ optional 13
}; node_15(){ either 7 8 9; }; node_16(){ required 15; }; node_17(){
required 14 16 11; }; node_18(){ required 14 5 11; }; node_19(){ either 12 17 18
}; node_20(){ required 19; }; cat <<<' docopt_exit() {
[[ -n $1 ]] && printf "%s\n" "$1" >&2; printf "%s\n" "${DOC:75:130}" >&2; exit 1
}'; unset var___debug var___dry_run var___help var___ignore_dirty var_REF \
var_VERSION var_previous var_major var_minor var_patch; parse 20 "$@"
local prefix=${DOCOPT_PREFIX:-''}; unset "${prefix}__debug" \
"${prefix}__dry_run" "${prefix}__help" "${prefix}__ignore_dirty" \
"${prefix}REF" "${prefix}VERSION" "${prefix}previous" "${prefix}major" \
"${prefix}minor" "${prefix}patch"
eval "${prefix}"'__debug=${var___debug:-false}'
eval "${prefix}"'__dry_run=${var___dry_run:-false}'
eval "${prefix}"'__help=${var___help:-false}'
eval "${prefix}"'__ignore_dirty=${var___ignore_dirty:-false}'
eval "${prefix}"'REF=${var_REF:-}'; eval "${prefix}"'VERSION=${var_VERSION:-}'
eval "${prefix}"'previous=${var_previous:-false}'
eval "${prefix}"'major=${var_major:-false}'
eval "${prefix}"'minor=${var_minor:-false}'
eval "${prefix}"'patch=${var_patch:-false}'; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p "${prefix}__debug" "${prefix}__dry_run" "${prefix}__help" \
"${prefix}__ignore_dirty" "${prefix}REF" "${prefix}VERSION" \
"${prefix}previous" "${prefix}major" "${prefix}minor" "${prefix}patch"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library='"$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh"' git-release`
  eval "$(docopt "$@")"

  # shellcheck disable=2154
  if $__debug; then
    set -x
  fi

  # shellcheck disable=2154
  if [[ -z $REF ]]; then
    REF=HEAD
  fi

  local _v v_major v_minor v_patch _rest previous_version
  if ! previous_version=$(git describe --tag --abbrev=0 --match='v*' "$REF" 2>/dev/null); then
    v_major=0
    v_minor=0
    v_patch=0
  else
    # shellcheck disable=2034
    IFS=v.-+ read -r -d $'\n' _v v_major v_minor v_patch _rest <<<"$previous_version"
  fi

  # shellcheck disable=2154
  if $previous; then
    [[ -n $previous_version ]] || fatal "No version tag found based on %s" "$REF"
    printf -- "%s\n" "$previous_version"
    return 0
  fi

  local new_version
  # shellcheck disable=2154
  if $major || $minor || $patch; then
    if $major || $minor; then
      if $major; then
        v_major=$((v_major+1))
        v_minor=0
      else
        v_minor=$((v_minor+1))
      fi
      v_patch=0
    else
      v_patch=$((v_patch+1))
    fi
    new_version=$(printf -- "v%s.%s.%s\n" "$v_major" "$v_minor" "$v_patch")
  else
    new_version=v${VERSION#v}
    if [[ ! $new_version =~ ^v[0-9]+\.[0-9]+\.[0-9]+([+-].+)?$ ]]; then
      docopt_exit "\`$VERSION' is not in semver format."
    fi
  fi

  # shellcheck disable=2154
  if [[ $REF = HEAD ]] && ! $__ignore_dirty && (! git diff --no-ext-diff --quiet --exit-code || ! git diff-index --quiet --cached HEAD 2>/dev/null); then
    fatal "Working copy is dirty, refusing to release"
  fi

  local release_notes
  if [[ -n $previous_version ]]; then
    release_notes="# Release notes were prepared for you, categorize/remove the changes as you see fit.
$new_version
------

Changes since $previous_version:
$(git rev-list --format=%s "$REF...$previous_version" | grep -Pv '^commit ' | sed 's/^/* /g')
"
  else
    release_notes="# Release notes were prepared for you, describe the first release.
$new_version
------

Initial release.
"
  fi
  local tag_msg_file
  tag_msg_file=$(git rev-parse --git-dir)/TAG_EDITMSG

  local ret=0
  #shellcheck disable=2154
  if $__dry_run; then
    #shellcheck disable=2028
    echo printf -- \"%s\\n\" "\"$release_notes\"" \> "\"$tag_msg_file\""
    echo git tag -e -F "$tag_msg_file" "$new_version" "$REF"
  else
    printf -- "%s\n" "$release_notes" > "$tag_msg_file"
    if ! git tag -e -F "$tag_msg_file" "$new_version" "$REF"; then
      # shellcheck disable=2183
      error "Unable to tag %s with %s, the version might already exist on a different branch.
You can list all versions with \`git tag -l --sort taggerdate 'v*'' and then tag manually with \`git tag -e -F %s %s %s'" "$REF" "$new_version" "$tag_msg_file" "$new_version" "$REF"
      ret=1
    else
      info "%s tagged with %s" "$REF" "$new_version"
    fi
  fi

  local branch push_cmd="git push $new_version" upstream
  if branch=$(git symbolic-ref --short "$REF" 2>/dev/null) && upstream=$(git config "branch.$branch.remote" 2>/dev/null); then
    push_cmd="git push --atomic $upstream $branch $new_version"
  fi
  info "Release the new version by running \`%s'\n" "$push_cmd"
  return $ret
}

main "$@"