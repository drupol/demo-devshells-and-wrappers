[![GitHub stars][github stars]][1] [![Donate!][donate github]][5]

# Nix Hands-on Tutorial

This repository is a step-by-step tutorial designed to help you master three
core concepts in Nix: development shells (`devShells`), packages (`packages`),
and NixOS configurations (`nixosConfigurations`). Each concept is demonstrated
through practical examples, with each step implemented in its own branch for
easy comparison.

- **Development shells**: Temporary, reproducible environments that provide the
  tools and dependencies needed for development on the command line. With Nix,
  you can define these environments declaratively, ensuring consistency across
  different machines and collaborators, and facilitating the development and
  onboarding process.
- **Packages**: Software and tools built and managed by Nix. A package can be a
  script, the result of a compilation, a container image, and more. Packages can
  be reused in development shells, container images, or system configurations.
  This tutorial shows how to create and customise your own packages within a
  flake.
- **NixOS configurations**: Declarative operating system configurations. These
  configurations specify everything about your operating system, from installed
  packages to services and system settings, making it easy to reproduce and
  manage entire machines.

By following this tutorial, you will learn how to create and manage development
shells, build custom packages, and define NixOS system configurations, all using
modern Nix workflows such as [`flakes`] and the [`flake.parts`] framework.

Each step is gradually implemented in its own branch. Use the links below to
open a branch or view the diff between steps.

---

## How to Use This Tutorial

- Ensure you have [Nix] installed with [`flakes`] enabled.
- Switch between branches using `git checkout stepN` (replace `N` with the step
  number).
- Follow the instructions in each step to run the development shell.
- Use the provided GitHub links to view branch contents or compare changes
  between steps.

---

## Step 1: Classic shell.nix

The first step is to create a `shell.nix` file in your project directory. This
file defines the development environment for your project.

Run it with `nix-shell`. It provides the PHP interpreter and its package
manager, Composer.

This legacy method of defining development shells is still widely used, but it
has some limitations. A `shell.nix` can only define one development shell. If
you require multiple shells, you must create multiple `shell.nix` files in
different directories and call `nix-shell` with the path to the folder
containing the desired `shell.nix` file.

Note that the input parameter `pkgs` is not locked to a specific version,
meaning the development shell may change over time as the [`nixpkgs`] repository
evolves.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step1
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step0..step1

## Step 2: Simple flake

This step converts the `shell.nix` file into a `flake.nix` file. [`Flake`] is an
experimental feature that provides a more reproducible and shareable way to
define Nix projects. You will notice that a `flake.lock` file has been created
to lock the dependencies' versions, ensuring the development shell remains
consistent over time. You cannot use a flake without this lock file.

A single flake file can define multiple development shells within the same file.

To enter the development shell, run `nix develop .#default`. If you omit the
`.#default` part, Nix will use the `default` development shell defined in the
flake, so both commands are equivalent.

Now that a flake is used, it can be shared and reused more easily. For example,
it is now possible to enter a development shell defined in this flake remotely:

```sh
nix develop github:drupol/demo-devshells-and-wrappers#default
```

Here, `default` is the name of the development shell to use.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step2
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step1..step2

## Step 3: Multi-architecture support

This step focuses on making the flake more accessible to different
architectures. Architectures are hardcoded manually, and a custom function is
created to abstract the logic and avoid code duplication.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step3
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step2..step3

## Step 4: Architectures as flake input

In this step, the custom list of architectures is replaced by a flake input.
There is no longer any need to hardcode and maintain the architecture list.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step4
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step3..step4

## Step 5: Introducing flake.parts

This step introduces [`flake.parts`], a framework designed to structure Nix
flakes. As projects grow, a single `flake.nix` file can become difficult to
manage. `flake.parts` solves this by providing a modular structure that
simplifies the organisation of your shells, packages, and system configurations.

A key benefit is that it abstracts away boilerplate code. For instance, it
handles the multi-architecture logic that we had to write manually in the
previous steps. By promoting a clean, modular design, `flake.parts` makes Nix
configurations easier to manage and scale, making it an excellent choice for
this tutorial and beyond.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step5
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step4..step5

## Step 6: Splitting into modules

This step introduces the project [`vic/import-tree`], which provides a function
to autoload files from a directory. The original `flake.nix` file is now split
into multiple files under the `modules` directory. There is no imposed file or
directory structure; you can organise subdirectories as you wish.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step6
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step5..step6

## Step 7: Using make-shell

This step introduces the [`flake.parts`] component [`make-shell`]. It simplifies
the creation of development shells, making them more declarative and easier to
manage.

Thanks to [`flake.parts`], a single development shell can be declared across
multiple files and parts. Nix will merge these parts to create the final
development shell. (Note: This feature is not demonstrated in this tutorial.)

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step7
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step6..step7

## Step 8: Multiple shells

This step introduces more development shells for NodeJS, Go, and Python. Notice
how easy it is to declare these new shells. Now, simply creating a new file
under the `modules` directory is sufficient—there is no need to bind files
manually, as everything is dynamically loaded thanks to [`vic/import-tree`].

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step8
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step7..step8

## Step 9: Wrappers

This step shows how to create a wrapper around an existing programme and pass
custom arguments to it. Wrappers are useful for setting environment variables or
passing default arguments to a program without modifying the underlying package.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step9
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step8..step9

## Step 10: Custom package

This step introduces a custom package, `nodejs14-bin`, to demonstrate how to
create custom packages inside a flake. By declaring this package, it can now be
used on any system architecture supported by the package itself.

To illustrate this, you can use the package "remotely" simply by running:

```sh
❯ nix shell github:drupol/demo-devshells-and-wrappers#nodejs14-bin
❯ node --version
v14.21.3
❯ exit
❯ node --version
fish: Unknown command: node
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step10
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step9..step10

## Step 11: Development shell with custom package

This step creates a new development shell that uses the custom package
`nodejs14-bin`, introduced in the previous step.

```sh
nix develop .#node14
```

Or remotely:

```sh
nix develop github:drupol/demo-devshells-and-wrappers#node14
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step11
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step10..step11

## Step 12: Add formatting checks with `treefmt`

This step adds the [`treefmt-nix`] component to the project. [`treefmt-nix`]
enables consistent formatting of all project files with a single command:
`nix fmt`.

You can configure different formatters for different file types. In this
tutorial, only Nix and Markdown files are automatically formatted.

To check if all files are correctly formatted, run:

```sh
nix flake check
```

If any file is not properly formatted, `nix flake check` will report an error.
This is useful for integrating formatting checks into CI pipelines.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step12
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step11..step12

## Step 13: Add new package that creates a container image

This step creates a new package in the project that builds a container image
using `dockerTools`. The container image includes the custom package
`nodejs14-bin`.

```sh
❯ nix build .#development-image
❯ podman load -i ./result
❯ podman run -ti --rm localhost/nodejs14-bin-image:latest node --version
v14.21.3
```

> Note: This image can be built locally on any computer, and it will be
> bit-for-bit reproducible, no matter when or where you build it. You are
> guaranteed that it will always contain the same version of NodeJS (v14.21.3)
> and the same dependencies.

## Step 14: Add NixOS configuration

A flake can also define NixOS configurations. A NixOS configuration is a set of
declarative settings that define how a NixOS system should be configured. You
can therefore define your NixOS system configuration in the same flake as your
development shells and packages.

To build the NixOS configuration defined in this step, run:

```sh
nix build .#nixosConfigurations.my-custom-config.config.system.build.toplevel
```

You can also preview your configuration in a virtual machine (QEMU) by running:

```sh
nix run .#nixosConfigurations.my-custom-config.config.system.build.vm
```

To deploy it to your system, run:

```sh
nixos-rebuild switch --flake .#my-custom-config
```

To deploy onto another machine via SSH, run:

```sh
nixos-rebuild switch --flake .#my-custom-config --target-host user@remote-host
```

---

## Useful Commands

- Show all available outputs from the flake (shells, packages, etc.):
  `nix flake show`
- Update all flake inputs and re-generate the lock file: `nix flake update`
- Enter the `default` development shell: `nix develop`
- Enter the `go` development shell: `nix develop .#go`
- Run a command from a package without installing it:
  `nix shell .#treefmt --command treefmt`
- Clean up old, unused packages from the Nix store: `nix-collect-garbage -d`

---

[1]: https://github.com/drupol/demo-devshells-and-wrappers
[5]: https://github.com/sponsors/drupol
[github stars]:
  https://img.shields.io/github/stars/drupol/demo-devshells-and-wrappers.svg?style=flat-square
[donate github]:
  https://img.shields.io/badge/Sponsor-Github-brightgreen.svg?style=flat-square
[Nix]: https://nixos.org/download.html
[`nixpkgs`]: https://github.com/NixOS/nixpkgs
[`flake`]: https://wiki.nixos.org/wiki/Flakes
[`flakes`]: https://wiki.nixos.org/wiki/Flakes
[`flake.parts`]: https://flake.parts
[`vic/import-tree`]: https://github.com/vic/import-tree/
[`make-shell`]: https://flake.parts/options/make-shell.html
[`treefmt-nix`]: https://treefmt.com
