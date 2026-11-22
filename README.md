# romus/homebrew-tap

Homebrew formulae and casks for [romus](https://github.com/romus)'s public projects.

## Install

```bash
brew tap romus/tap
brew trust romus/tap
brew install --cask writeless
```

Homebrew asks you to trust a third-party tap before it loads anything from it,
hence `brew trust`. To trust one package instead of the whole tap, run
`brew trust --cask romus/tap/writeless`.

## Packages

| Package | Type | Install | Source |
| --- | --- | --- | --- |
| `writeless` | cask | `brew install --cask writeless` | [romus/writeless-macos](https://github.com/romus/writeless-macos) |

```bash
brew upgrade --cask writeless     # upgrade
brew uninstall --cask writeless   # uninstall
brew untap romus/tap              # remove the tap
```

## How releases get here

Nobody edits the files in `Formula/` or `Casks/` by hand. Each project keeps its
formula or cask template next to its code. When a version tag is pushed, the
project's release workflow:

1. builds and publishes the release,
2. renders the `.rb` file and installs it from a temporary local tap (smoke test),
3. calls [`.github/actions/bump`](.github/actions/bump/action.yml), which opens a
   pull request here on the `release/<name>-v<version>` branch, touching only
   `Formula/<name>.rb` or `Casks/<name>.rb`.

The [tests](.github/workflows/tests.yml) workflow runs `brew test-bot --only-tap-syntax`
(style, audit, readall) on the pull request; merge it once it is green.

## Adding a package

1. **Render script in the project.** Write a script that prints the formula or cask
   for a given version and SHA-256. The file name must match the package name.
   Examples: [`render_cask.sh`](https://github.com/romus/writeless-macos/blob/main/scripts/render_cask.sh)
   for a cask, [`render_homebrew_formula.py`](https://github.com/romus/cognito/blob/main/scripts/render_homebrew_formula.py)
   for a formula.
2. **Secret.** Add `HOMEBREW_TAP_PAT` to the project's repository secrets. It is a
   fine-grained token with access to `romus/homebrew-tap` only, with **Contents**
   and **Pull requests** set to read and write. One token works for every project:
   only the tap has to be in its repository access list, not the project.
3. **Release job.** After the build and smoke-test jobs, add:

   ```yaml
   update-tap:
     needs: [build, smoke-test]
     runs-on: ubuntu-latest
     steps:
       - uses: actions/checkout@v4

       - name: Render the formula
         run: |
           ./scripts/render_formula.sh \
             --version "${{ needs.build.outputs.version }}" \
             --sha256 "${{ needs.build.outputs.sha256 }}" \
             --output "$RUNNER_TEMP/<name>.rb"

       - uses: romus/homebrew-tap/.github/actions/bump@main
         with:
           token: ${{ secrets.HOMEBREW_TAP_PAT }}
           type: formula            # or cask
           name: <name>
           version: ${{ needs.build.outputs.version }}
           file: ${{ runner.temp }}/<name>.rb
           body: |                  # optional, added to the PR description
             - SHA256: `${{ needs.build.outputs.sha256 }}`
   ```

   The full example, smoke test included, is the
   [writeless-macos release workflow](https://github.com/romus/writeless-macos/blob/main/.github/workflows/release.yml).
4. **First release.** Tag the project. The pull request it opens here creates the
   file; merge it and add a row to the table above.

### Moving a package from its own tap

Some projects still have a tap of their own (`romus/homebrew-<name>`). To move one here:

1. Switch the project's release job to the bump action (above) and release once, so
   the package exists in this tap.
2. In the old tap, in a single commit: delete `Formula/<name>.rb` (or
   `Casks/<name>.rb`) and add `tap_migrations.json`:

   ```json
   {
     "<name>": "romus/tap"
   }
   ```

   Point its README here, then archive the repository. Archived repositories can
   still be fetched, so `brew update` picks the commit up and tells existing users
   how to switch to `romus/tap`.

## Trying the bump action locally

[`prepare.sh`](.github/actions/bump/prepare.sh) is the only logic of our own in the
action, and it runs without GitHub:

```bash
TYPE=cask NAME=writeless VERSION=2.1.0 FILE=/path/to/writeless.rb TAP_DIR=. \
  .github/actions/bump/prepare.sh
git status
```
