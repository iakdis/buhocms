
## 🌟 New release: v0.6.1 🌟
### Take a look at all the changes [here](https://github.com/iakmds/buhocms/releases/tag/v0.6.1)!

<br>

<p>
  <a href="https://github.com/iakmds/buhocms/releases/latest" alt="Release">
  <img src="https://img.shields.io/github/v/release/iakmds/buhocms?style=flat-square" /></a>

  <a href="https://github.com/iakmds/buhocms/issues" alt="Issues">
  <img src="https://img.shields.io/github/issues/iakmds/buhocms?style=flat-square" /></a>

  <a href="https://github.com/iakmds/buhocms/pulls" alt="Pull requests">
  <img src="https://img.shields.io/github/issues-pr/iakmds/buhocms?style=flat-square" /></a>

  <a href="https://github.com/iakmds/buhocms/contributors" alt="Contributors">
  <img src="https://img.shields.io/github/contributors/iakmds/buhocms?style=flat-square" /></a>

  <a href="https://github.com/iakmds/buhocms/network/members" alt="Forks">
  <img src="https://img.shields.io/github/forks/iakmds/buhocms?style=flat-square" /></a>

  <a href="https://github.com/iakmds/buhocms/stargazers" alt="Stars">
  <img src="https://img.shields.io/github/stars/iakmds/buhocms?style=flat-square" /></a>

  <a href="https://github.com/iakmds/buhocms/blob/master/LICENSE" alt="License">
  <img src="https://img.shields.io/github/license/iakmds/buhocms?style=flat-square" /></a>
</p>

<br>

<p align="center">
  <a href="https://github.com/iakmds/buhocms">
    <img src="https://github.com/iakmds/buhocms/blob/main/.github/icon.svg" alt="BuhoCMS app icon" width="200">
  </a>
</p>

<h1 align="center">BuhoCMS</h1>
<p align="center">A free and open source local CMS for <a href="https://gohugo.io/">Hugo</a> and <a href="https://jekyllrb.com/">Jekyll</a> static sites written in Flutter and Dart licensed under the <a href="LICENSE">GPLv3</a></p>

<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#what-is-buhocms">What is BuhoCMS?</a>
      <ul>
        <li><a href="#screenshots">Screenshots</a></li>
        <li><a href="#features">Features</a></li>
      </ul>
    </li>
    <li>
      <a href="#downloads">Downloads</a>
      <ul>
        <li><a href="#windows">Windows</a></li>
        <li><a href="#macos">macOS</a></li>
        <li><a href="#linux">Linux</a></li>
      </ul>
    </li>
    <li>
      <a href="#contributing">Contributing</a>
      <ul>
          <li><a href="#translating">Translating</a></li>
          <li><a href="#code">Code</a></li>
          <li><a href="#bug-reports-feature-requests-and-improvements">Bug reports, feature requests and improvements</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#packages-used">Packages used</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

# What is BuhoCMS?

BuhoCMS is a **local Content Management System** for **static site generators** like [Hugo](https://gohugo.io/) and [Jekyll](https://jekyllrb.com/) (support for others is planned for the future). 

See BuhoCMS as a **GUI for static site generators**. Easily **create or open a website**, **choose your theme** and **add your first posts**. With BuhoCMS, adding and editing content is as easy as a few clicks. No more terminal commands, folder hunting or manual Front matter edits 🥳

### Who is BuhoCMS for?

BuhoCMS is made for... you 😃

...that is, everyone using Hugo or Jekyll as a static site generator who wants an **easy to use**, **graphical way** to **edit content**, so that you can make the best use out of the power of a static site generator: *Creating and editing content.*

BuhoCMS is for you if you land in at least one of the following categories:

- You **already have a Hugo or Jekyll site** and want to easily edit your content from now on
- You want to **create a new Hugo or Jekyll site from zero** with a graphical user interface
- You are a **beginner** looking for a **simple way to begin your journey** in using static site generators

## :warning: Alpha warning
BuhoCMS is currently in Alpha. While most things should work as expected, bugs :bug: are likely to exist. It is a good idea to backup 💾 your website folders just in case. Also, remember that [many more features](https://github.com/iakmds/buhocms#roadmap) are planned! :sparkles:

# Screenshots
<p float="left">
  <img src="https://github.com/iakmds/buhocms/blob/main/.github/screenshot1.png" alt="Screenshot 1">
  <img src="https://github.com/iakmds/buhocms/blob/main/.github/screenshot2.png" alt="Screenshot 2">
  <img src="https://github.com/iakmds/buhocms/blob/main/.github/screenshot3.png" alt="Screenshot 3">
  <img src="https://github.com/iakmds/buhocms/blob/main/.github/screenshot4.png" alt="Screenshot 4">
</p>

# Downloads

- Currently supported platforms: Windows, Linux
- Planned: macOS, Web (possibly in the future)

### Windows

Download and execute the [BuhoCMS-Windows.exe](https://github.com/iakmds/buhocms/releases) file from the GitHub [releases](https://github.com/iakmds/buhocms/releases) page.

### macOS

macOS support is planned. Unfortunately I do not currently own a macOS device; to build and test BuhoCMS, a macOS device is needed. 

### Linux

Supported | Planned
|-|-|
| Flatpak (Flathub) | Snap |
| AppImage | AUR |
| .deb | .rpm |

<br>

To install BuhoCMS as a **Flatpak**, head over to Flathub. In order to run executable commands on your host system, you need to give the following permission in your Terminal: `flatpak --user override org.buhocms.BuhoCMS --talk-name=org.freedesktop.Flatpak`

[<img src="https://flathub.org/assets/badges/flathub-badge-en.png"
    alt="Download on Flathub"
    height="80">](https://flathub.org/apps/details/org.buhocms.BuhoCMS)

<br>

To install BuhoCMS as an **AppImage**, download the [BuhoCMS-Linux.AppImage](https://github.com/iakmds/buhocms/releases) file from the GitHub [releases](https://github.com/iakmds/buhocms/releases) page, make it executable and run it. For better desktop integration consider using [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher).

[<img src=".github/appimage-badge.svg"
    alt="Download as an AppImage"
    height="80">](https://github.com/iakmds/buhocms/releases)

<br>

To install BuhoCMS as a **.deb** package, download the [BuhoCMS-Linux.deb](https://github.com/iakmds/buhocms/releases) file from the GitHub [releases](https://github.com/iakmds/buhocms/releases) page and install it.

# Features

- **SSGs supported**: [Hugo](https://gohugo.io/) and [Jekyll](https://jekyllrb.com/)
- **Create** or **open** a site
- **Install themes** for your site
- **Add new posts** and **edit** your Markdown content and Front matter with ease
- **Edit content**: Use the Markdown toolbar for quickly adding styles
- **Markdown preview**: Use the Markdown viewer to check your syntax
- **Front matter**: Graphical User Interface (GUI) for each field like a Text field, Switch, Date picker, Tag editor, and more
- **Switch** between **GUI and raw text mode**
- **Start, open and stop** your **local server** with a click
- **Build your final website** and open its folder
- **Privacy**: BuhoCMS is a local program with no internet connection required – no ads, no tracking
- **Free and open source**: Licensed under the [GPLv3](LICENSE)
- **Themes**: Material Design with multiple color themes, both light and dark
- **Fully responsive**
- **Multiple languages supported** – [Contribute translating your language!](#translating)
- *...and [many more features planned](#roadmap)*

# Contributing

These are the ways you can contribute to BuhoCMS:

### Translating

Languages currently supported: 
  - English 🇬🇧
  - German (Deutsch) 🇩🇪
  - Chinese (中文) 🇨🇳

**First steps:**
1. If not already supported (see above), request a new language by [opening an issue](https://github.com/iakmds/buhocms/issues) on GitHub and I will add the necessary code for the second step.
2. Translate an already existing language (see below).

**Translating guide:** Weblate support is planned. For now, go to the .arb file of the language you want to translate (for example, [app_de.arb](https://github.com/iakmds/buhocms/blob/master/assets/l10n/app_de.arb) file for German) and change the text inside the "" quotation marks. Use the [English](https://github.com/iakmds/buhocms/blob/master/assets/l10n/app_en.arb) translation as a reference for the text to be translated to the target language. If the keys listed in the [untranslatedMessages.txt](https://github.com/iakmds/buhocms/blob/master/untranslatedMessages.txt) don't exist, simply create them just like the others.

Send in your translated files as a [Pull request](https://github.com/iakmds/buhocms/pulls)

### Bug Reports, Feature Requests and Improvements

Open an issue on GitHub: [Open issue](https://github.com/iakmds/buhocms/issues). Remember to check for duplicates and try to give important information such as the app version, your operating system, etc.

### Code

Feel free to send in a [pull request](https://github.com/iakmds/buhocms/pulls)! To get started with Flutter, follow this link: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

1. Clone this repository
2. Switch to the project's directory and run `flutter pub get` to get all necessary packages. To receive all localized strings, run `flutter gen-l10n`. To test the app, run the project in debug mode by selecting a device in your preferred Flutter IDE and running the app in debug mode
3. Build BuhoCMS (see steps for the different platforms below)

**Windows** executable: Run the following command in your terminal on a Windows machine: `flutter build windows` – the output file will be generated at `buhocms\build\windows\runner\Release\buhocms.exe`.

**Linux** executable: Run the following command in your terminal: `flutter build linux` – the output files, including the executable, will be generated at`buhocms/build/linux/x64/release/bundle`.

# Roadmap

**General:**
  - [ ] Integration with git when "publishing" site (optional)
  - [ ] Language filter for l10n
  - [ ] Fix system light/dark color scheme
  - [ ] Custom app theme colors
  - [ ] Markdown Toolbar: "Add media" button for images for selecting an image
  - [ ] Configurable shortcuts
  - [x] Markdown Toolbar: Shortcuts (v0.5.0)
  - [x] Localization: Markdown Toolbar tooltip texts (v0.4.0)
  - [x] Show terminal output (v0.3.0)

**Hugo specific:**
  - [ ] Work with both hugo.* and config.* names ([see Hugo Documentation](https://gohugo.io/getting-started/configuration/#hugotoml-vs-configtoml))
  - [ ] hugo/config.toml, hugo/config.yaml, hugo/config.json editor (+ create a .bak backup file)
  - [ ] Be able to delete themes and open the theme folder button
  - [ ] [Git-submodules](https://gohugo.io/getting-started/quick-start/#explanation-of-commands) for themes support

**Project:**
  - [ ] Support more static site generators
    - [x] [Jekyll](https://jekyllrb.com/) support (v.0.6.0)
  - [ ] More supported languages (See [#translating](#translating) above)
  - [ ] [Your features](https://github.com/iakmds/buhocms/issues)

# Packages used

The packages used for this app, also listed in the pubspec.yaml file. See their respective licenses.

Package | Use case
-|-
[context_menus](https://pub.dev/packages/context_menus) | Right click context menus
[convert](https://pub.dev/packages/convert) | Convert json
[dropdown_search](https://pub.dev/packages/dropdown_search) | Add Front matter with a searchable Dropdown button
[file_picker](https://pub.dev/packages/file_picker) | Picking file paths
[flex_color_scheme](https://pub.dev/packages/flex_color_scheme) | App color schemes
[flutter](https://pub.dev/packages/flutter) | Flutter SDK
[flutter_localizations](https://pub.dev/packages/flutter_localizations) | Localization
[flutter_markdown](https://pub.dev/packages/flutter_markdown) | Markdown preview
[flutter_svg](https://pub.dev/packages/flutter_svg) | Displaying SVG files
[intl](https://pub.dev/packages/intl) | Localization
[markdown_toolbar](https://pub.dev/packages/markdown_toolbar) | Markdown Toolbar
[menu_bar](https://pub.dev/packages/menu_bar) | Menu Bar
[package_info_plus](https://pub.dev/packages/package_info_plus) | Display the programs version number
[process_run](https://pub.dev/packages/process_run) | Run terminal commands
[provider](https://pub.dev/packages/provider) | State management for localization, themes, navigation, etc.
[shared_preferences](https://pub.dev/packages/shared_preferences) | Saving local app data, including settings
[smooth_page_indicator](https://pub.dev/packages/smooth_page_indicator) | Page indicator in the onboarding screen
[url_launcher](https://pub.dev/packages/url_launcher) | Open links in Browser
[window_manager](https://pub.dev/packages/window_manager) | Set minimum window size and window title

# License

This project is licensed under the [GNU General Public License Version 3](https://www.gnu.org/licenses/gpl-3.0.html). For details, see [LICENSE](LICENSE)
