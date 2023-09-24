# CallingsPlus

Native iOS client for CallingsPlus platform based on the [VSM for iOS architecture](https://github.com/wayfair/vsm-ios) and [Firebase](https://firebase.google.com/) ecosystem.

(Instructions for how to contribute to this repo will be coming soon™)

## Supported Environments

- Production (Live Firebase)
- Staging (Coming Soon™)
- Localhost (Coming Soon™)
- Mocked / Previews

## Supported Work Flows

The repo supports three workflows, utilizing the 4 unique environments for super speedy development.

### Integration Workflow

This workflow allows you to run the app in the production, staging, and localhost configurations for testing the integration of features together against a real data store (Firebase).

_Workflow Instructions_

1. Open the CallingsPlus.xcworkspace file found at the root of the repository.
1. Select the CallingsPlus target and run the app.

Note: You can also access any of the feature app's and sub-modules from this workspace by expanding the FeatureApps section of the navigation pane, and build them by switching the current target.

### Feature UI Integration Workflow

This workflow allows you to build and test mocked feature behaviors and navigation in a demo app, as well as write and execute automated UI tests. It's especially helpful when testing multiple view's interactions.

_Workflow Instructions_

1. Open the demo project file found in the feature's folder. (e.g. `Features/Foo/App/FooApp.xcodeproj`)
1. Select the project's demo/ui-test App target and run the app. (e.g. "FooApp")

Note: You can also access any of the feature's sub-modules from this workspace by opening the Packages folder in the navigation pane, and build them by switching the current target.

### Feature UI Coding Workflow

This workflow allows you to build and preview features using Xcode's preview feature and mocks. You can also accomplish this in other workflows, but for maximum iteration & preview speed, follow these instructions.

_Workflow Instructions_

1. Open the feature package found in the feature's folder. (e.g. `Features/Foo`)
1. Select the feature's target and hack away! (e.g. "Foo")


## Modularization Strategy

The project file/folder structure and modularization approach may seem a bit complicated, but it hyper-optimizes for build times, dependency injection, and feature ownership while preserving flexibility.

### Layering

The following folder structure represent the "layers" of the app modules:

- App: This is the app layer and solely glues the feature modules together into a cohesive app (e.g. CallingsPlusApp, CallingsPlusAppCode)
- Feature: This layer contains the feature code, grouped into discrete feature modules.
- Common: This layer contains code that is shared by two or more feature modules, but is unique to the CallingsPlus app.
- Platform: This layer contains code that is ubiquitously helpful to iOS apps and supports behavior in all other layers.

Modules should only reference each other in this order. (Skipping a level is allowed. e.g. Feature -> Platform) This creates a more flattened dependency graph that optimizes build speed, scoping, and ownership.

### Feature Modules

The feature modules are arranged in such a way as to enable flexible configurations, maximum ownership, encapsulation, and build speed. At the same time minimizing, and in some cases, eliminating risk of breakages from downstream impact of other actors.

```
             ┌──────────────────┐       ┌───────────────┐
             │                  │       │               │
             │  Production App  │       │  Example App  │
             │                  │       │               │
             └────────┬─────────┘       └───────┬───────┘
                      │                         │
          ┌───────────┴───────────┐  ┌──────────┴─────────────┐
          ▼                       ▼  ▼                        ▼
 ┌──────────────────┐  ┌───────────────────────┐  ┌───────────────────────┐
 │                  │  │                       │  │                       │
 │  (Other Feature  │  │  Feature Prod Config  │  │  Feature Mock Config  │
 │   Prod Configs)  │  │                       │  │                       │
 │                  │  └────────────┬──────────┘  └───────────┬───────────┘
 └────────┬─────────┘               │                         │
          │                         └──────────┐  ┌───────────┘
          ▼                                    ▼  ▼
 ┌────────────────────┐                    ┌───────────┐
 │                    │                    │           │
 │  (Other Features)  │                    │  Feature  │
 │                    │                    │           │
 └────────────────────┘                    └───────────┘
```

### Folder Structure

This folder structure will be repeated for each feature module, so that the naming and location of the various feature module components will be consistent across the app.

```
Features/                       (Contains all feature modules)
    Foo/                        (Name of the feature)
        Foo.package             (Swift package declaration)
        App/                    (Demo/UITest app project & files)
            FooApp.xcodeproj    (Demo app & UITest target)
            ...
        Sources/
            Foo/                (Contains the views, behavior, and abstractions of a feature)
            FooAppCode/         (Contains the Demo app code files to avoid xcodeproj file conflicts)
            FooMockConfig/      (Contains the mock configuration for the feature's behavior)
            FooProdConfig/      (Contains the prod configuration for the feature's behavior)
        Tests/FooTests          (Contains the unit tests for the feature's behavior & code APIs)
```