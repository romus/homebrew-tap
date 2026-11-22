#!/usr/bin/env bash
# Copies a rendered formula or cask into a checkout of the tap and prints the
# path it landed at. The bump action calls it; to try it by hand:
#
#   TYPE=cask NAME=writeless VERSION=2.1.0 FILE=/tmp/writeless.rb TAP_DIR=. \
#     .github/actions/bump/prepare.sh
set -euo pipefail

fail() {
  echo "::error::$*" >&2
  exit 1
}

TYPE="${TYPE:-}"
NAME="${NAME:-}"
VERSION="${VERSION:-}"
FILE="${FILE:-}"
TAP_DIR="${TAP_DIR:-}"

case "$TYPE" in
  formula) dir="Formula" ;;
  cask) dir="Casks" ;;
  *) fail "type must be 'formula' or 'cask', got '$TYPE'" ;;
esac

name_re='^[a-z0-9][a-z0-9@._+-]*$'
[[ "$NAME" =~ $name_re ]] || fail "name '$NAME' is not a valid Homebrew name (lowercase letters, digits, @ . _ + -)"

version_re='^[0-9A-Za-z][0-9A-Za-z._+-]*$'
[[ "$VERSION" =~ $version_re ]] || fail "version '$VERSION' is not valid, expected something like 2.1.0"
[[ "$VERSION" != v* ]] || fail "version '$VERSION' must be passed without the leading 'v'"

[ -f "$FILE" ] || fail "file '$FILE' does not exist"
[ -d "$TAP_DIR" ] || fail "tap checkout '$TAP_DIR' does not exist"

# Homebrew looks a package up by file name, so the file has to declare the same name.
if [ "$TYPE" = cask ]; then
  grep -q "^cask \"$NAME\" do" "$FILE" || fail "$FILE does not declare cask \"$NAME\""
else
  grep -q "< Formula" "$FILE" || fail "$FILE does not declare a Formula class"
fi

path="$dir/$NAME.rb"
mkdir -p "$TAP_DIR/$dir"
cp "$FILE" "$TAP_DIR/$path"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "path=$path" >> "$GITHUB_OUTPUT"
fi
echo "Copied $FILE to $path"
