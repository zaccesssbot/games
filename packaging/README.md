# Packaging

How Zacess Games reaches crates.io, Homebrew and winget after a release. Each step is run by a
maintainer on their own machine with their own credentials. No token is ever stored in this
repository or in its workflows.

Before any of these, the release must exist: the tag `vX.Y.Z` pushed, the GitHub release made from
it and [`release.yml`](../.github/workflows/release.yml) finished, so the five archives and their
`.sha256` files are attached.

## crates.io

```sh
# check what would be packaged, then publish with the token from the environment
cargo publish --dry-run
CARGO_REGISTRY_TOKEN="$(cat /path/to/token)" cargo publish
```

The token comes from a file or a credential helper, never from the shell history. The crate
excludes `.github`, `packaging`, the stills in `docs/images` and the frames in `docs/frames`, so
what is published is the code, the levels, the recordings, the guides and the licence. The crate
depends on `zacess-scenes` from crates.io, so a new Scenes version is published first.

## Homebrew

The formula template is [`homebrew/zacess-games.rb`](homebrew/zacess-games.rb). It installs the
release archive for the person's platform rather than building from source, so it needs the SHA-256
of each archive.

1. The tap repository is `zacesshq/homebrew-tap`, with a `Formula` folder shared with Zacess
   Scenes.
2. Copy the template to `Formula/zacess-games.rb` in the tap and replace every `VERSION` with the
   version (without the `v`) and each `SHA256_` placeholder with the sum from the matching
   `.sha256` file on the release.
3. Check it locally, then commit it to the tap:

   ```sh
   brew install --build-from-source ./Formula/zacess-games.rb
   brew test zacess-games
   brew audit --strict --online zacess-games
   ```

Once the formula is in the tap, the install line is `brew install zacesshq/tap/zacess-games`.

## winget

The manifest templates are in [`winget`](winget): the version, installer and default locale files
winget needs. The installer is the Windows zip from the release, installed as a portable program
with the alias `zacess-games`.

1. Copy the three files into a fork of
   [microsoft/winget-pkgs](https://github.com/microsoft/winget-pkgs) under
   `manifests/z/Zacess/Games/X.Y.Z/`, replacing every `VERSION` with the version and
   `SHA256_WINDOWS` with the sum from the zip's `.sha256` file.
2. Validate and test them on a Windows machine:

   ```powershell
   winget validate --manifest manifests\z\Zacess\Games\X.Y.Z
   winget install --manifest manifests\z\Zacess\Games\X.Y.Z
   zacess-games --version
   ```

3. Open a pull request to microsoft/winget-pkgs. Their checks take a day or two.

Once accepted, the install line is `winget install Zacess.Games`.

> [!NOTE]
> The README says the Homebrew tap and the winget package follow the release until both are live.
> Remove that note in the pull request that follows the first accepted package.
