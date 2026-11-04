# Packaging

How Zacess Games reaches crates.io, Homebrew and winget after a release. Each step is run by a
maintainer on their own machine with their own credentials. No token is ever stored in this
repository or in its workflows.

Before any of these, the release must exist: the tag `vX.Y.Z` pushed, the GitHub release made from
it and [`release.yml`](../.github/workflows/release.yml) finished, so the five archives and their
`.sha256` files are attached. `gh release view vX.Y.Z --repo zacesshq/games` lists them.

## In this folder

| File | Does |
| --- | --- |
| [`homebrew/zacess-games.rb`](homebrew/zacess-games.rb) | The formula for the tap, at the current version with a `SHA256_` placeholder per platform |
| [`winget/`](winget) | The three winget manifests (version, installer and default locale) at the current version, with one placeholder for the Windows zip |
| [`fill-checksums.sh`](fill-checksums.sh) | Downloads the `.sha256` files of a release and writes the formula and the manifests with the sums filled in to a folder of your choice |

The files here keep their placeholders. A release bumps the version in them (the four URLs and
the `version` line in the formula, `PackageVersion`, the zip path and `ReleaseNotesUrl` in the
manifests) in the same pull request as `Cargo.toml`.

## crates.io

The crate is `zacess-games`. `Cargo.toml` excludes `.github`, `packaging`, the stills in
`docs/images` and the frames in `docs/frames`, so what is published is the code, the levels, the
recordings, the guides and the licence. The crate depends on `zacess-scenes` from crates.io, so a
new Scenes version is published first.

```sh
# check what would be packaged and that the metadata is complete
cargo publish --dry-run
cargo package --list

# publish with a token read from a file, never typed into the shell history
CARGO_REGISTRY_TOKEN="$(cat /path/to/token)" cargo publish
```

crates.io shows the new version within a minute. The crates.io badge in the README reads it from
there.

## Homebrew

The tap is `zacesshq/homebrew-tap`, which Homebrew reads as `zacesshq/tap`. Its `Formula` folder
is shared with Zacess Scenes. The formula installs the release archive for the person's platform
rather than building from source, so it needs the SHA-256 of each of the four Unix archives.

1. Fill the formula from the release files and copy it into a checkout of the tap:

   ```sh
   packaging/fill-checksums.sh vX.Y.Z /tmp/packaging-X.Y.Z
   cp /tmp/packaging-X.Y.Z/homebrew/zacess-games.rb homebrew-tap/Formula/
   ```

2. Check it from the tap checkout, then commit and push it:

   ```sh
   brew install --formula ./Formula/zacess-games.rb
   brew test zacess-games
   brew style ./Formula/zacess-games.rb
   zacess-games --version
   ```

Once the tap holds the formula, the install line is `brew install zacesshq/tap/zacess-games` and
`brew upgrade zacess-games` follows each later release once its formula is in the tap.

## winget

The package is `Zacess.Games`. The installer is the Windows zip from the release, installed as a
portable program with the command alias `zacess-games`.

1. Fill the manifests from the release files:

   ```sh
   packaging/fill-checksums.sh vX.Y.Z /tmp/packaging-X.Y.Z
   ```

2. Copy the three files from `/tmp/packaging-X.Y.Z/winget/` into a fork of
   [microsoft/winget-pkgs](https://github.com/microsoft/winget-pkgs) under
   `manifests/z/Zacess/Games/X.Y.Z/`.
3. Validate and test them on a Windows machine:

   ```powershell
   winget validate --manifest manifests\z\Zacess\Games\X.Y.Z
   winget install --manifest manifests\z\Zacess\Games\X.Y.Z
   zacess-games --version
   ```

4. Open a pull request to microsoft/winget-pkgs. Their checks take a day or two and the package
   is live once it merges.

Once accepted, the install line is `winget install Zacess.Games`. Every later release is submitted
the same way with its own version folder.

> [!NOTE]
> The README says the Homebrew tap and the winget package follow the release until both are live.
> Remove that note in the pull request that follows the first accepted package.
