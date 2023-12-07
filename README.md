# flutterfy-cli
> Combination of `Flutter` + `Simplify`

> Instead of copy pasting scripts for every new flutter project I'm working on I can just run `f` on a flutter project and run these common daily tasks.

<p align="center">
  <img src="assets/ss.png" width="100%" />
</p>


## Usage

```bash
f clean
# => Deep cleans the project and rebuilds it.
```

```bash
f fix
# => Automatically identifies and corrects common issues in Dart code, such as outdated syntax.
```

```bash
f fix
# => Automatically identifies and corrects common issues in Dart code, such as outdated syntax

```
```bash
f bump major|minor|patch|build
# => bumps the corresponding update type (and it always bumps the build number)
```

```bash
f generate swagger|icon|assets
# => swagger: Executes a function to generate a Swagger (OpenAPI) client.
# => icon: Generates the icons for the app. (using "flutter_launcher_icons")
# => assets: Initiates asset generation and management. (using "fluttergen")
```

```bash
f open ios|android
# => ios: Opens the appstoreconnect website.
# => android: Opens the play console website.
```

```bash
f release beta|production
# => beta: Releases the current build to the beta track.
# => production: the current build to the production track.
```

## Install
Clone the repo in your designated folder
```bash
git clone git@github.com:cesarferreira/flutterfy-cli.git
```
Now add to your `~/.bashrc` or `~/.zshrc`
```bash
alias f="ruby -Ilib PATH_TO_GEM_FOLDER/f/bin/f"
```


## Nice to Have
- [ ] listen to build_runner changes `flutter pub run build_runner watch -d`