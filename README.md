# at_mono

<img width=250px src="https://atsign.dev/assets/img/atPlatform_logo_gray.svg?sanitize=true" alt="AtPlatform Logo, gray, svg">

[![GitHub License](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

This is a poly-as-mono repo which we created for integration testing of our dart and
flutter packages.

## Why create something like this?

There are benefits to both polyrepo and monorepo approaches. In this organization,
we've opted to go with a hybrid poly-monorepo approach (several smaller monorepos)
which suits most of our development needs.
One of the main reasons to opt for a monorepo is for integration testing, and
therefore we've created a poly-as-mono repo to make integration testing easier.
It is also a useful place in which to keep diagrams of end-to-end user journeys,
code paths, dependency trees, etc. which typically span across multiple repos.

Read more in the [in-depth explanation](https://github.com/atsign-foundation/.github/blob/trunk/at_mono.md).

## Poly repos included

- [at_server](https://github.com/atsign-foundation/at_server.git)
- [at_client_sdk](https://github.com/atsign-foundation/at_client_sdk.git)
- [at_libraries](https://github.com/atsign-foundation/at_libraries.git)
- [at_widgets](https://github.com/atsign-foundation/at_widgets.git)
- [at_tools](https://github.com/atsign-foundation/at_tools.git)

