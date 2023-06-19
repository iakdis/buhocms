# Documentation for `release.yml`

## Prerequisites

A GitHub token used to authenticate and authorize the action to create the release. Create a personal access token (PAT) with necessary permissions and store it as a secret (named `GH_PAT`) in your repository.

## What does the GitHub action workflow do?

The role of the GitHub Actions workflow file (`release.yml`) can be summarized as follows:

- The workflow is triggered when a Git tag (in the format 'v*.*.*') is pushed. Note that you should have done an usual `git push` before pushing the tag.
- The Flutter version is set as an environment variable `FLUTTER_VERSION`.
- There are three jobs defined: `job1_linux_build`, `job2_windows_build`, and `job3_create_release`.
- `job1_linux_build` runs on Ubuntu 22.04 and performs the following steps:
  - Checks out the repository.
  - Sets up Flutter using the `subosito/flutter-action` action.
  - Runs a series of commands related to updating system packages, installing dependencies, running Flutter doctor, and building the Linux binaries.
  - Uploads the generated .deb and .AppImage files as artifacts.
- `job2_windows_build` runs on Windows 2022 and performs the following steps:
  - Checks out the repository.
  - Sets up Flutter using the `subosito/flutter-action` action.
  - Runs Flutter doctor and builds the Windows executable.
  - Extracts the latest git tag and sets variables for Buhocms version.
  - Runs Inno Setup to create an installer using the provided script.
  - Uploads the generated .exe file as an artifact.
- `job3_create_release` runs on Ubuntu 22.04 and creates a draft release:
  - Downloads all artifacts from the previous jobs.
  - Performs various file operations, including moving and renaming files, to prepare the release assets.
  - Creates a draft release using the `ncipollo/release-action` action and uploads the release assets.

Overall, this workflow builds cross-platform binaries for Linux and Windows, creates installer packages, and generates a draft release with the built artifacts.
