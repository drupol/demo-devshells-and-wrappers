[![GitHub stars][github stars]][1] [![Donate!][donate github]][5]

# Nix Hands-On Tutorial

This repository is a step-by-step Nix tutorial designed to help you master a
couple of core concepts in Nix: development shells (`devShells`), packages
(`packages`), and NixOS configurations (`nixosConfigurations`). Each concept is
demonstrated through practical examples, with each step implemented in its own
commit and branch for easy comparison.

- **Development shells**: Temporary, reproducible environments that provide the
  tools and dependencies in a shell. With Nix, you can define these environments
  declaratively, ensuring consistency across different machines and
  collaborators, and facilitating development and onboarding.
- **Packages**: Software and tools built and managed by Nix. A package can be a
  script, the result of a compilation, a container image, and more. Packages can
  be reused in development shells, container images, or system configurations.
  This tutorial shows how to create and customize your own packages within a
  flake.
- **NixOS configurations**: Declarative operating system configurations. These
  configurations specify everything about your operating system, from installed
  packages to services and system settings, making it easy to reproduce and
  manage entire machines.

By following this tutorial, you will learn how to create and manage development
shells, build custom packages, and define NixOS system configurations, all using
modern Nix workflows such as [`flakes`] and the [`flake.parts`] framework.

Each step is implemented in its own branch. Use the links below to open a branch
or view the diff between steps.

---

## How to Use This Tutorial

- Ensure you have [Nix] installed with [`flakes`] enabled.
- Clone this repository
- Switch between branches using `git checkout stepN` (replace `N` with the step
  number).
- Use the provided GitHub links to view branch contents or compare changes
  between steps.

---

## Resources

- Wombat's Book of Nix: https://mhwombat.codeberg.page/nix-book/
- nix.dev: https://nix.dev/
- Nix Pills: https://nixos.org/guides/nix-pills/
- NixOS Manual: https://nixos.org/manual/nixos/stable
- Nixpkgs Manual: https://nixos.org/manual/nixpkgs/stable

---

## Step 1: Basic `shell.nix`

The first step is to create a `shell.nix` file in your project directory. This
file defines the development environment for your project.

Run it with `nix-shell`. It provides the [PHP] interpreter and its package
manager, [Composer].

This legacy method of defining development shells is still widely used, but it
has some limitations. A `shell.nix` can only define one development shell. If
you require multiple shells, you must create multiple `shell.nix` files in
different directories and call `nix-shell` with the path to the folder
containing the desired `shell.nix` file.

> **Note**: The input parameter `pkgs` is not locked to a specific version,
> meaning the development shell may change over time as the [`nixpkgs`]
> repository evolves.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step1
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step0..step1

## Step 2: Migration to `flake.nix`

This step converts the `shell.nix` file into a `flake.nix` file. [`Flake`] is an
experimental feature that provides a more reproducible and shareable way to
define Nix projects. You will notice that a `flake.lock` file has been created
to lock the dependencies' versions, ensuring the development shell remains
consistent over time. You cannot use a flake without this lock file.

A _flake_ refers to a project containing a `flake.nix` file and exposing
_output(s)_. A `flake` can define multiple outputs: development shells,
packages, checks, etc.

To enter the development shell, run `nix develop .#php` where `php` is the name
of the development shell. If you omit the `.#php` part, Nix will attempt to use
the `default` development shell, if one is defined. This allows you to quickly
access the main shell configuration, while still being able to specify
alternative shells by name when needed.

Now that our project contains a `flake.nix` file, it can be shared and reused,
simply by sharing the repository. For example, it is now possible to enter a
development shell defined in this project, **remotely**, without even cloning
the repository:

```sh
nix develop github:drupol/demo-devshells-and-wrappers#php
```

To list the available outputs (development shells, packages, etc.), run:

```sh
nix flake show github:drupol/demo-devshells-and-wrappers
```

Alternatively, to do this locally, after cloning the repository, run:

```sh
cd demo-devshells-and-wrappers
nix flake show
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step2
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step1..step2

## Step 3: Multi-system support

This step focuses on making the flake (here: _the "outputs" of the project
containing the `flake.nix` file_) more accessible to different systems. Systems
are hardcoded manually, and a custom function is created to abstract the logic
and avoid code duplication.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step3
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step2..step3

## Step 4: Systems as flake input

In this step, the custom list of systems is replaced by a flake input. There is
no longer any need to hardcode and maintain the system list.

By making the systems a flake input, we can now easily override it with command
line arguments when calling Nix commands.

> **Note**: This step demonstrates how to re-use a trivial Nix code made in
> another repository (https://github.com/nix-systems/default) by declaring it as
> a flake input.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step4
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step3..step4

## Step 5: Introducing `flake.parts`

This step introduces [`flake.parts`], a framework designed to structure Nix
files. As projects grow, a single `flake.nix` file can become difficult to
manage. [`flake.parts`] solves this by providing a modular structure that
simplifies the organization of your files into "parts". The framework does not
enforce a specific project structure; instead, it offers flexibility while
promoting best practices.

A key benefit is that it abstracts away boilerplate code. For instance, it
handles the multi-system logic that we had to write manually in the previous
steps. By promoting a clean, modular design, [`flake.parts`] makes Nix
configurations easier to manage and scale the flake outputs, making it an
excellent choice for this tutorial and beyond.

> **Note**: Using [`flake.parts`] is intentional and opinionated. However, there
> are many other Nix frameworks available. Feel free to explore alternatives and
> choose the one that best fits your needs and preferences.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step5
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step4..step5

## Step 6: Splitting into modules

This step demonstrates how to split the `flake.nix` file into multiple files
(modules), leveraging the benefits of [`flake.parts`]. Each file (or module) is
responsible for a specific aspect of the flake, such as defining development
shells or packages. This modular approach enhances maintainability and
readability.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step6
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step5..step6

## Step 7: Autoload modules

This step introduces the project [`vic/import-tree`], which provides a function
to autoload files from a directory. There is no need to bind files manually
anymore. All files under the `modules` directory are automatically loaded and
merged together.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step7
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step6..step7

## Step 8: Using make-shell

This step introduces the [`flake.parts`] component: [`make-shell`]. It
simplifies the creation of development shells, making them more declarative and
easier to manage.

> **Note**: Thanks to [`flake.parts`], a single development shell can be
> declared across multiple files and parts. Nix will merge these modules
> together to create the final configuration of the development shell. This
> feature is not demonstrated in this tutorial.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step8
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step7..step8

## Step 9: Multiple shells

This step introduces additional development shells for NodeJS, Go, and Python.
Notice how easy it is to declare these new shells. Now, simply creating a new
file under the `modules` directory is sufficient! There is no need to bind files
manually, as everything is dynamically loaded thanks to [`vic/import-tree`].

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step9
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step8..step9

## Step 10: Create a wrapper

This step shows how to create a wrapper around an existing program and pass
custom arguments to it. Wrappers are useful for setting environment variables or
passing default arguments to a program without modifying the underlying package.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step10
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step9..step10

## Step 11: Use `lassulus/wrappers`

In the previous step, we created a custom wrapper using the core functions of
Nix. In this step, we use a library that exposes convenient functions to
facilitate the creation of such wrappers: [`lassulus/wrappers`].

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step11
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step10..step11

## Step 12: Custom package

This step introduces a custom package, `nodejs14-bin`, to demonstrate how to
create custom packages inside a flake. By declaring this package, it can now be
used on any system supported by the package itself.

To illustrate this, you can use the package remotely simply by running:

```sh
❯ nix shell github:drupol/demo-devshells-and-wrappers#nodejs14-bin
❯ node --version
v14.21.3
❯ exit
❯ node --version
fish: Unknown command: node
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step12
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step11..step12

## Step 13: Development shell with custom package

This step creates a new development shell that uses the custom package
`nodejs14-bin`, introduced in the previous step.

```sh
nix develop .#node14
```

Alternatively, remotely:

```sh
nix develop github:drupol/demo-devshells-and-wrappers#node14
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step13
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step12..step13

## Step 14: Add formatting checks with `treefmt`

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

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step14
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step13..step14

## Step 15: Add new package that creates a container image

This step creates a new package in the project that builds a container image
using `dockerTools`. The container image includes the custom package
`nodejs14-bin`.

```sh
❯ nix build .#development-image
❯ podman load -i ./result
❯ podman run -ti --rm localhost/nodejs14-bin-image:latest node --version
v14.21.3
```

> **Note**: This image can be built locally on any computer, and it will be
> bit-for-bit reproducible, no matter when or where you build it. You are
> guaranteed that it will always contain the same version of NodeJS (v14.21.3)
> and the same dependencies.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step15
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step14..step15

## Step 16: Add NixOS configuration

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
export QEMU_NET_OPTS="hostfwd=tcp:127.0.0.1:2222-:22,hostfwd=tcp:127.0.0.1:8080-:80"
nix run .#nixosConfigurations.my-custom-config.config.system.build.vm
```

> **Note**: The `QEMU_NET_OPTS` environment variable is used to forward ports
> from the host machine to the virtual machine. In this example, port `2222` on
> the host is forwarded to port `22` (SSH) on the VM, and port `8080` on the
> host is forwarded to port `80` (HTTP) on the VM. Try connecting via SSH
> (`ssh -p 2222 your-username@127.0.0.1`) or visiting the HTTP server
> (`http://127.0.0.1:8080/`)!

To deploy it to your system, run:

```sh
nixos-rebuild switch --flake .#my-custom-config
```

To deploy onto another machine via SSH, run:

```sh
nixos-rebuild switch --flake .#my-custom-config --target-host user@remote-host
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step16
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step15..step16

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
[PHP]: https://www.php.net/
[Composer]: https://getcomposer.org/
[`nixpkgs`]: https://github.com/NixOS/nixpkgs
[`flake`]: https://wiki.nixos.org/wiki/Flakes
[`flakes`]: https://wiki.nixos.org/wiki/Flakes
[`flake.parts`]: https://flake.parts
[`vic/import-tree`]: https://github.com/vic/import-tree/
[`make-shell`]: https://flake.parts/options/make-shell.html
[`treefmt-nix`]: https://treefmt.com
[`lassulus/wrappers`]: https://github.com/lassulus/wrappers
