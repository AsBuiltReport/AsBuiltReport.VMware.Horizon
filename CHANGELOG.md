# :arrows_clockwise: VMware Horizon As Built Report Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.6] - 2025-1-17

### Added

- Added TrueSSO Certificate details and Health Check Section

### Changed

- Tested with Horizon 2406
- Added TrueSSO Cetificate details section
- Added Health Check module
- Increased AsBuiltReport.Core minimum requirements to v1.4.1
- Increased Eomm/why-don-t-you-tweet Github action to v2

### Fixed

- Resolved the Following issues:
- [#30](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/30)


## [1.1.5] - 2024-11-22

### Added

- Tested Report with Horizon 8.13

### Changed

- Changed Required Modules to AsBuiltReport.Core v1.4.0
- Improved detection of empty fields in tables
- Improved detection of true/false elements in tables
- Updated GitHub release workflow to add post to Bluesky social platform
- Updated sample report

## [1.1.3] - 2024-02-14

### Added

- Added module version validation

### Changed

- Updated VMware PowerCLI requirements to v13.2
- Updated Sample Reports
- Updated CodeQL upload-sarif action requirement to v3
- Updated PSScriptAnalyzer checkout action requirement to v4
- Updated PublishPowerShellModule checkout action requirement to v4

### Fixed

- Resolved the Following issues:
  - [#15](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/15), [#16](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/16), [#17](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/17), [#18](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/18), [#19](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/19), [#20](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/20), [#21](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/21), [#22](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/22), [#23](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/23), [#24](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/24)

## [1.1.2] - 2024-02-02

### Fixed

- Renamed Domains Connection Server Section. Resolve [#13](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/13)
- Fixed Admin Users and Groups bug details reporting incorrectly. Resolve [#12](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues/12)

## [1.1.0] - 2023-12-19

### Added

- Updated Report to work with Horizon 2309
- Added Features for Certificates and Replication status
- Improved functionaliy and layout.

## [0.2.0] - 2022-08-17

### Added

- Migrate report to new module format
  - Implement better error handling
- Improve report layout
- A set of Horizon infrastructure health checks has been introduced.

## [0.1.0] - 2020-07-27

### Added

- Initial Release @childebrandt42
  - Develop core horizon modules and sections
