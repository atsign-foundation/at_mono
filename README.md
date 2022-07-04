# at_mono

<img width=250px src="https://atsign.dev/assets/img/atPlatform_logo_gray.svg?sanitize=true" alt="AtPlatform Logo, gray, svg">

[![GitHub License](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

This is a poly-as-mono repo which we created for integration testing of our dart and
flutter packages.

## Why create something like this?

There are benefits to both poly and mono repo approaches. In this organization,
we've opted to go with a poly repo which suits most of our development needs.
One of the main reasons to opt for a mono repo is for integration testing, and
therefore we've created a poly-as-mono repo to make integration testing easier.
It is also a useful place in which to keep diagrams of end-to-end user journeys,
code paths etc. which almost always span multiple individual repos.

## Poly repos included

- [at_server](https://github.com/atsign-foundation/at_server.git)
- [at_client_sdk](https://github.com/atsign-foundation/at_client_sdk.git)
- [at_libraries](https://github.com/atsign-foundation/at_libraries.git)
- [at_widgets](https://github.com/atsign-foundation/at_widgets.git)
- [at_tools](https://github.com/atsign-foundation/at_tools.git)
- [at_app](https://github.com/atsign-foundation/at_app.git)

