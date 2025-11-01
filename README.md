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
- Clone this repository.
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
- The Nix lectures: https://ayats.org/blog/nix-tuto-1

---

## Step 1: The basics

The first step is to create a `shell.nix` file in your project directory. This
file defines the development environment for your project.

Run it with `nix-shell`. It provides the [PHP] interpreter and its package
manager, [Composer].

The command `nix-shell` will first look for a `shell.nix` or `default.nix` file
in the current directory. If found, it will set up the development environment
by instantiating the Nix expression defined in the file.

Under the hood, `nix-shell` implicitly runs a Nix expression similar to:

```shell
nix-shell \
  --expr 'import (if builtins.pathExists ./shell.nix then ./shell.nix else ./default.nix)'
```

This _legacy_ method of defining development shells is still widely used because
of its simplicity and brevity. It is suitable for small projects or when you
need a quick development environment without complex requirements.

It is also possible to run `nix-shell` against a remote repository:

```shell
nix-shell \
  --expr '
    let
      repo = fetchTarball "https://github.com/drupol/demo-devshells-and-wrappers/archive/refs/heads/step1.zip";
    in
      import (if builtins.pathExists "${repo}/shell.nix" then "${repo}/shell.nix" else "${repo}/default.nix")'
    '
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step1
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step0..step1

## Step 2: Adding a new development shell

In this step, we introduce an additional development shell, this time for the Go
programming language.

When creating multiple development shells within the same project, you must
return an attribute set of shells rather than a single one. Notice that
`shell.nix` now returns such a set. In this case, use
`nix-shell --attr <attribute-name>` to enter a specific shell, where
`<attribute-name>` corresponds to the declared development shell.

Therefore, to enter the PHP shell:

```shell
nix-shell --attr php
```

Or to enter the Go shell:

```shell
nix-shell --attr go
```

To run one of these shells remotely:

```shell
nix-shell \
  --expr '
    let
      repo = fetchTarball "https://github.com/drupol/demo-devshells-and-wrappers/archive/refs/heads/step2.zip";
    in
      import (if builtins.pathExists "${repo}/shell.nix" then "${repo}/shell.nix" else "${repo}/default.nix")
    ' \
  --attr go
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step2
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step1..step2

## Step 3: Migrating to flakes

This step converts the project to a _flake_. A _flake_ refers to a project
containing a `flake.nix` file and exposing _output(s)_ following a specific
structure, based on a well-defined schema. A [`flake`] can define multiple
outputs: development shells, packages, checks, etc.

[`Flake`] is an experimental feature that provides a more reproducible and
shareable way to define Nix projects. You will notice that a `flake.lock` file
has been created to lock the dependencies' versions, ensuring the development
shell remains consistent over time. You cannot use a flake without this lock
file.

To enter a development shell, run `nix develop .#<attribute>` where `attribute`
is the name of the development shell (e.g., `go`, `php`). If you omit the last
part, Nix will attempt to use the `default` development shell, if one is
defined. This allows you to quickly access the main shell configuration, while
still being able to specify alternative shells by name when needed.

Now that our project contains a `flake.nix` file, it can be shared and reused,
simply by sharing the repository URL.

To list the available outputs (development shells, packages, etc.):

```shell
nix flake show github:drupol/demo-devshells-and-wrappers
```

Alternatively, to do this locally, after cloning the repository:

```shell
git clone https://github.com/drupol/demo-devshells-and-wrappers
cd demo-devshells-and-wrappers
nix flake show
```

To "remote-enter" the PHP shell:

```shell
nix develop github:drupol/demo-devshells-and-wrappers#php
```

The old `nix-shell` commands still works thanks to [`NixOS/flake-compat`] which
provides backward compatibility for flake projects.

```shell
nix-shell --attr go
```

> [!IMPORTANT]
>
> The original `shell.nix` provided by [`NixOS/flake-compat`] has been slightly
> modified to use `builtins.currentSystem` to determine the current system
> dynamically. This ensures that legacy `nix-shell` commands function correctly
> across different architectures without needing to hardcode the system name in
> the command line attribute.
>
> The usage of `builtins.currentSystem` is generally restricted in `flake.nix`,
> unless the `--impure` flag is used. This is because [`flakes`] are designed to
> be pure and reproducible, and relying on the host system's details introduces
> "impurity", making the build dependent on the machine running it.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step3
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step2..step3

## Step 4: Multi-system support

This step focuses on making the flake (here: _the "outputs" of the project
containing the `flake.nix` file_) more accessible to different systems. Systems
are hardcoded manually, and a custom function is created to abstract the logic
and avoid code duplication.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step4
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step3..step4

## Step 5: Using an existing systems list

In this step, we will remove the custom list of systems. There is no longer any
need to hardcode and maintain the system list ourselves. Instead, we will use a
default existing list of systems from the [`NixOS/nixpkgs`] project.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step5
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step4..step5

## Step 6: Introducing `flake.parts`

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

[`flake.parts`] does not invent something entirely new _per se_. Instead, it
leverages Nix's inherent modularity by bringing the concept of [modules] to
[`flakes`]. This allows you to break down complex configurations into smaller,
manageable, and reusable pieces.

> **Note**: Using [`flake.parts`] is intentional and opinionated. However, there
> are many other Nix frameworks available. Feel free to explore alternatives and
> choose the one that best fits your needs and preferences.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step6
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step5..step6

## Step 7: Splitting into modules

This step demonstrates how to split the `flake.nix` file into multiple files
(modules), leveraging the benefits of [`flake.parts`]. Each file (or module) is
responsible for a specific aspect of the [`flake`], such as defining development
shells or packages. This modular approach enhances maintainability and
readability.

Nix will automatically merge these modules together to create the final
configuration of the [`flake`]. This allows you to organize your code logically,
making it easier to navigate and manage as the project grows.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step7
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step6..step7

## Step 8: Autoloading modules

This step introduces the project [`vic/import-tree`], which provides a function
to autoload files from a directory. There is no need to bind files manually
anymore. All files under the `modules` directory are automatically loaded and
merged together.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step8
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step7..step8

## Step 9: Using make-shell

This step introduces the [`flake.parts`] component: [`make-shell`]. It
simplifies the creation of development shells, making them more declarative and
easier to manage.

> **Note**: Thanks to [`flake.parts`], a single development shell can be
> declared across multiple files and parts. Nix will merge these modules
> together to create the final configuration of the development shell. This
> feature is not demonstrated in this tutorial.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step9
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step8..step9

## Step 10: Defining multiple shells

This step introduces additional development shells for Go (`go`), NodeJS
(`node`), Python (`python`) and Rust (`rust`). Notice how trivial it is to
declare these new shells. Creating a single file under the `modules` directory
is sufficient. There is no need to bind files manually, as everything is
dynamically loaded thanks to [`vic/import-tree`].

You can enter each shell using the following command, where `rust` is used as an
example. Replace `rust` with `go`, `nodejs`, or `python` to enter the respective
shells.

```shell
nix develop .#rust
```

You can also enter these shells remotely without cloning the repository:

```shell
nix develop github:drupol/demo-devshells-and-wrappers#rust
```

And obviously, you can still use the old `nix-shell` command if you prefer
because the backward compatibility is still provided by [`NixOS/flake-compat`]:

```shell
nix-shell --attr rust
```

And finally, we can also do that remotely with `nix-shell`:

```shell
nix-shell \
  --expr '
    let
      repo = fetchTarball "https://github.com/drupol/demo-devshells-and-wrappers/archive/refs/heads/step10.zip";
    in
      import (if builtins.pathExists "${repo}/shell.nix" then "${repo}/shell.nix" else "${repo}/default.nix")
    ' \
  --attr rust
```

Notice how verbose the last command is! This is one of the reasons why using
[`flake`] is more convenient in such cases.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step10
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step9..step10

## Step 11: Creating a wrapper

This step shows how to create a wrapper around an existing program and pass
custom arguments to it. Wrappers are useful for setting environment variables or
passing default arguments to a program without modifying the underlying package.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step11
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step10..step11

## Step 12: Using `lassulus/wrappers`

In the previous step, we created a custom wrapper using the core functions of
Nix. In this step, we use a library that exposes convenient functions to
facilitate the creation of such wrappers: [`lassulus/wrappers`].

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step12
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step11..step12

## Step 13: Creating a custom package

This step introduces a custom package, `nodejs14-bin`, to demonstrate how to
create custom packages inside a flake. By declaring this package, it can now be
used on any system supported by the package itself.

To illustrate this, you can use the package remotely simply by running:

```shell
nix run github:drupol/demo-devshells-and-wrappers#nodejs14-bin -- --version

# v14.21.3
```

```shell
nix build .#nodejs14-bin

# ./result/bin/node --version
# v14.21.3
```

Since we want to make sure the compatibility with Nix legacy (non-flake), the
file `default.nix` has been added. This file comes from [`NixOS/flake-compat`]
and is a bridge between the flake and non-flake worlds as we have seen before.
It exposes the same outputs as the flake itself. Therefore, you can also build
the package with the `nix-build` command:

```shell
nix-build --attr nodejs14-bin

# ./result/bin/node --version
# v14.21.3
```

Or remotely:

```shell
nix-build \
  --expr '
    let
      repo = fetchTarball "https://github.com/drupol/demo-devshells-and-wrappers/archive/refs/heads/step13.zip";
    in
      import (if builtins.pathExists "${repo}/shell.nix" then "${repo}/shell.nix" else "${repo}/default.nix")
    ' \
  --attr nodejs14-bin

# ./result/bin/node --version
# v14.21.3
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step13
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step12..step13

## Step 14: Using a custom package in a shell

This step creates a new development shell that uses the custom package
`nodejs14-bin`, introduced in the previous step.

```shell
nix develop .#node14
```

Alternatively, remotely:

```shell
nix develop github:drupol/demo-devshells-and-wrappers#node14
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step14
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step13..step14

## Step 15: Adding formatting checks with `treefmt`

This step adds the [`treefmt-nix`] component to the project. [`treefmt-nix`]
enables consistent formatting of all project files with a single command:
`nix fmt`.

You can configure different formatters for different file types. In this
tutorial, only Nix and Markdown files are automatically formatted.

To check if all files are correctly formatted, run:

```shell
nix flake check
```

If any file is not properly formatted, `nix flake check` will report an error.
This is useful for integrating formatting checks into CI pipelines.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step15
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step14..step15

## Step 16: Building a container image

This step creates a new package (`nodejs14-bin-image`) in the project that
builds a container image using `dockerTools`. The container image includes the
custom package `nodejs14-bin`.

```shell
nix build .#nodejs14-bin-image
podman load -i ./result
podman run -ti --rm localhost/nodejs14-bin-image:latest node --version

# v14.21.3
```

> [!NOTE]
>
> This image can be built locally on any computer, and it will be bit-for-bit
> reproducible, no matter when or where you build it. You are guaranteed that it
> will always contain the same version of NodeJS (v14.21.3) and the same
> dependencies.

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step16
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step15..step16

## Step 17: Adding a NixOS configuration

A [`flake`] can also define NixOS configurations. A NixOS configuration is a set
of declarative settings that define how a NixOS system should be configured. You
can therefore define your NixOS system configuration in the same [`flake`] as
your development shells and packages.

To build the NixOS configuration defined in this step:

```shell
nix build .#nixosConfigurations.my-custom-config.config.system.build.toplevel
```

You can also preview your configuration in a virtual machine (QEMU):

```shell
export QEMU_NET_OPTS="hostfwd=tcp:127.0.0.1:2222-:22,hostfwd=tcp:127.0.0.1:8080-:80"
nix run .#nixosConfigurations.my-custom-config.config.system.build.vm
```

> [!NOTE]
>
> The `QEMU_NET_OPTS` environment variable is used to forward ports from the
> host machine to the virtual machine. In this example, port `2222` on the host
> is forwarded to port `22` (SSH) on the VM, and port `8080` on the host is
> forwarded to port `80` (HTTP) on the VM. Try connecting via SSH
> (`ssh -p 2222 your-username@127.0.0.1`) or visiting the HTTP server
> (`http://127.0.0.1:8080/`)!

To deploy it to your system:

```shell
nixos-rebuild switch --flake .#my-custom-config
```

To deploy onto another machine via SSH:

```shell
nixos-rebuild switch --flake .#my-custom-config --target-host user@remote-host
```

- View branch: https://github.com/drupol/demo-devshells-and-wrappers/tree/step17
- Diff:
  https://github.com/drupol/demo-devshells-and-wrappers/compare/step16..step17

---

## Useful Commands

- Show all available outputs from the flake (shells, packages, etc.):
  `nix flake show`
- Update all flake inputs and re-generate the lock file: `nix flake update`
- Enter the `default` development shell: `nix develop` (this is equivalent to
  running `nix develop .#default`)
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
[modules]: https://nix.dev/tutorials/module-system/
[`flakes`]: https://wiki.nixos.org/wiki/Flakes
[`flake.parts`]: https://flake.parts
[`vic/import-tree`]: https://github.com/vic/import-tree/
[`make-shell`]: https://flake.parts/options/make-shell.html
[`treefmt-nix`]: https://treefmt.com
[`lassulus/wrappers`]: https://github.com/lassulus/wrappers
[`NixOS/flake-compat`]: https://github.com/NixOS/flake-compat
