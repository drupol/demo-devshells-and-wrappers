[![GitHub stars][github stars]][1] [![Donate!][donate github]][5]

# Nix Hands-On Tutorial

This repository is a step-by-step Nix tutorial designed to help you master core
concepts in Nix: development shells (`devShells`), packages (`packages`), and
NixOS configurations (`nixosConfigurations`). Each concept is demonstrated
through practical examples, with each step implemented in its own commit and
branch for easy comparison.

- **Development shells**: Temporary, reproducible environments that provide the
  tools and dependencies in a shell. With Nix, you can define these environments
  declaratively, ensuring consistency across different machines and
  collaborators, and facilitating development and onboarding.
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

## Step 1: Shell script

The first step creates a shell script named `active-php-version.sh`. It will
print the currently active PHP version in a fancy way.

This is the starting point for the tutorial.

- View branch: https://github.com/drupol/nix-hands-on/tree/step1
- Diff: https://github.com/drupol/nix-hands-on/compare/step0..step1

## Step 2: Portable Shebang

In this step, we update the shell script's Shebang (`#!`) to make it work on
any machine with Nix installed.

You will notice that the script now works on any system with Nix, regardless of the
installed software.

- View branch: https://github.com/drupol/nix-hands-on/tree/step2
- Diff: https://github.com/drupol/nix-hands-on/compare/step1..step2

## Step 3: Development shells

This step introduces a `shell.nix` file to the project. This file defines a
reproducible development environment.

To enter this environment, run `nix-shell`. It will provide the [PHP]
interpreter and its package manager, [Composer], regardless of what is installed
on your host system. The command `nix-shell` will first look for a `shell.nix`
or `default.nix` file in the current directory. If found, it will set up the
development environment by instantiating the Nix expression defined in the file.

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
      repo = fetchTarball "https://github.com/drupol/nix-hands-on/archive/refs/heads/step3.zip";
    in
      import (if builtins.pathExists "${repo}/shell.nix" then "${repo}/shell.nix" else "${repo}/default.nix")'
    '
```

- View branch: https://github.com/drupol/nix-hands-on/tree/step3
- Diff: https://github.com/drupol/nix-hands-on/compare/step2..step3

## Step 4: Adding a new development shell

In this step, we introduce an additional development shell, this time for the Go
programming language.

When creating multiple development shells within the same project using
`shell.nix`, you must return an attribute set of shells rather than a single
one.

To enter a specific shell, use the `--attr` flag.

To enter the PHP shell:

```shell
nix-shell --attr php
```

To enter the Go shell:

```shell
nix-shell --attr go
```

To run one of these shells remotely:

```shell
nix-shell \
  --expr '
    let
      repo = fetchTarball "https://github.com/drupol/nix-hands-on/archive/refs/heads/step4.zip";
    in
      import (if builtins.pathExists "${repo}/shell.nix" then "${repo}/shell.nix" else "${repo}/default.nix")
    ' \
  --attr go
```

- View branch: https://github.com/drupol/nix-hands-on/tree/step4
- Diff: https://github.com/drupol/nix-hands-on/compare/step3..step4

## Step 5: Migrating to flakes

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
just by sharing the repository URL.

To list the available outputs (development shells, packages, etc.):

```shell
nix flake show github:drupol/nix-hands-on
```

Alternatively, to do this locally, after cloning the repository:

```shell
git clone https://github.com/drupol/nix-hands-on
cd nix-hands-on
nix flake show
```

To "remote-enter" the PHP shell:

```shell
nix develop github:drupol/nix-hands-on#php
```

The old `nix-shell` commands still work thanks to [`NixOS/flake-compat`] which
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

- View branch: https://github.com/drupol/nix-hands-on/tree/step5
- Diff: https://github.com/drupol/nix-hands-on/compare/step4..step5

## Step 6: Multi-system support

This step focuses on making the flake compatible with multiple system
architectures (e.g., `x86_64-linux`, `aarch64-darwin`).

We explicitly list supported systems and use a helper function to generate
outputs for each of them, replacing the single-system definition.

- View branch: https://github.com/drupol/nix-hands-on/tree/step6
- Diff: https://github.com/drupol/nix-hands-on/compare/step5..step6

## Step 7: Using an existing systems list

In this step, we remove the hardcoded list of systems. Instead, we use the
default list of supported systems provided by [`NixOS/nixpkgs`]. This reduces
maintenance burden and ensures we support standard architectures.

- View branch: https://github.com/drupol/nix-hands-on/tree/step7
- Diff: https://github.com/drupol/nix-hands-on/compare/step6..step7

## Step 8: Introducing `flake.parts`

This step introduces [`flake.parts`], a framework designed to structure Nix
files. As projects grow, a single `flake.nix` file can become difficult to
manage. [`flake.parts`] solves this by providing a modular structure that
simplifies the organisation of your files into "parts". The framework does not
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

- View branch: https://github.com/drupol/nix-hands-on/tree/step8
- Diff: https://github.com/drupol/nix-hands-on/compare/step7..step8

## Step 9: Splitting into modules

This step demonstrates how to split the `flake.nix` file into multiple files
(modules), leveraging the benefits of [`flake.parts`]. Each file (or module) is
responsible for a specific aspect of the [`flake`], such as defining development
shells or packages. This modular approach enhances maintainability and
readability.

Nix will automatically merge these modules together to create the final
configuration of the [`flake`]. This allows you to organise your code logically,
making it easier to navigate and manage as the project grows.

- View branch: https://github.com/drupol/nix-hands-on/tree/step9
- Diff: https://github.com/drupol/nix-hands-on/compare/step8..step9

## Step 10: Autoloading modules

We introduce [`vic/import-tree`] to automatically load all modules from a
directory. This means you no longer need to manually import every new file you
create; simply adding a file to the `modules/` directory includes it in the
configuration.

- View branch: https://github.com/drupol/nix-hands-on/tree/step10
- Diff: https://github.com/drupol/nix-hands-on/compare/step9..step10

## Step 11: Using make-shell

We adopt the [`make-shell`] component from [`flake.parts`]. This allows us to
define development shells in a more declarative and concise way within our
modules.

> **Note**: Thanks to [`flake.parts`], a single development shell can be
> declared across multiple files and parts. Nix will merge these modules
> together to create the final configuration of the development shell. This
> feature is not demonstrated in this tutorial.

- View branch: https://github.com/drupol/nix-hands-on/tree/step11
- Diff: https://github.com/drupol/nix-hands-on/compare/step10..step11

## Step 12: Defining multiple shells

We add shells for additional languages: Go (`go`), NodeJS (`node`), Python
(`python`), and Rust (`rust`).

Thanks to [`vic/import-tree`], adding these was as simple as creating a new
file. You can enter any of these shells with:

```shell
nix develop .#rust
```

You can also enter these shells remotely without cloning the repository:

```shell
nix develop github:drupol/nix-hands-on#rust
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
      repo = fetchTarball "https://github.com/drupol/nix-hands-on/archive/refs/heads/step12.zip";
    in
      import (if builtins.pathExists "${repo}/shell.nix" then "${repo}/shell.nix" else "${repo}/default.nix")
    ' \
  --attr rust
```

Notice how verbose the last command is! This is one of the reasons why using
[`flake`] is more convenient in such cases.

- View branch: https://github.com/drupol/nix-hands-on/tree/step12
- Diff: https://github.com/drupol/nix-hands-on/compare/step11..step12

## Step 13: Creating a wrapper

This step demonstrates how to create a "wrapper" around an existing program.
Wrappers are useful for setting environment variables or passing default
arguments to a program without modifying the upstream package source. Here, we
create a wrapped version of a tool with custom defaults.

- View branch: https://github.com/drupol/nix-hands-on/tree/step13
- Diff: https://github.com/drupol/nix-hands-on/compare/step12..step13

## Step 14: Using `lassulus/wrappers`

We replace our manual wrapper code with the [`lassulus/wrappers`] library. This
library provides convenient, reusable functions for simplifying wrapper
creation, making our code cleaner and less error-prone.

- View branch: https://github.com/drupol/nix-hands-on/tree/step14
- Diff: https://github.com/drupol/nix-hands-on/compare/step13..step14

## Step 15: From a script to a package

In this step, we take the shell script from Step 2 (`active-php-version.sh`) and
package it properly. This makes the script available as a buildable Nix package
that can be run on any system.

- View branch: https://github.com/drupol/nix-hands-on/tree/step15
- Diff: https://github.com/drupol/nix-hands-on/compare/step14..step15

## Step 16: Add another custom package

We add another custom package, `nodejs14-bin`, to the flake. This demonstrates
how to package binaries or other software.

You can run this package without installing it:

```shell
nix run .#nodejs14-bin -- --version
```

Or build it:

```shell
nix build .#nodejs14-bin

# ./result/bin/node --version
# v14.21.3
```

Since we want to ensure compatibility with legacy Nix (non-flake), the
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
      repo = fetchTarball "https://github.com/drupol/nix-hands-on/archive/refs/heads/step16.zip";
    in
      import (if builtins.pathExists "${repo}/shell.nix" then "${repo}/shell.nix" else "${repo}/default.nix")
    ' \
  --attr nodejs14-bin

# ./result/bin/node --version
# v14.21.3
```

- View branch: https://github.com/drupol/nix-hands-on/tree/step16
- Diff: https://github.com/drupol/nix-hands-on/compare/step15..step16

## Step 17: Patch an existing package with a custom patch

In this step, a new package `vhs-asciinema` will be created. This package is
derived from the `nixpkgs` package [`vhs`] where a patch will be applied to add
a new feature to support the `asciinema` output format.

- View branch: https://github.com/drupol/nix-hands-on/tree/step17
- Diff: https://github.com/drupol/nix-hands-on/compare/step16..step17

## Step 18: Using custom packages in development shells

In this step, two new development shell environments will be created.

The `node14` development shell specifically includes the custom `nodejs14-bin`
package. This shows how to consume your own flake outputs within your own
development environments.

The `vhs` development shell includes the custom package `vhs-asciinema`.

```shell
nix develop .#node14
```

Alternatively, remotely:

```shell
nix develop github:drupol/nix-hands-on#node14
```

- View branch: https://github.com/drupol/nix-hands-on/tree/step18
- Diff: https://github.com/drupol/nix-hands-on/compare/step17..step18

## Step 19: Adding formatting checks with `treefmt`

We integrate [`treefmt-nix`] to enforce code formatting. This allows us to
format the entire project (Nix files, Markdown, etc.) with a single command:

```shell
nix fmt
```

It also adds a check to `nix flake check` to ensure CI pipelines fail if code is
not formatted.

- View branch: https://github.com/drupol/nix-hands-on/tree/step19
- Diff: https://github.com/drupol/nix-hands-on/compare/step18..step19

## Step 20: Building a container image

We define a new package, `nodejs14-bin-image`, which builds a container image
(OCI-compliant) containing our custom `nodejs14-bin` package using
`dockerTools`.

```shell
nix build .#nodejs14-bin-image
podman load -i ./result
podman run -ti --rm localhost/nodejs14-bin-image:latest node --version

# v14.21.3
```

This image is bit-for-bit reproducible.

- View branch: https://github.com/drupol/nix-hands-on/tree/step20
- Diff: https://github.com/drupol/nix-hands-on/compare/step19..step20

## Step 21: Adding a NixOS configuration

Finally, we show that a flake can also define full NixOS system configurations.
We add a `nixosConfigurations` output for a custom system.

To build the system `my-custom-config`:

```shell
nix build .#nixosConfigurations.my-custom-config.config.system.build.toplevel
```

Or run it in a VM:

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

- View branch: https://github.com/drupol/nix-hands-on/tree/step21
- Diff: https://github.com/drupol/nix-hands-on/compare/step20..step21

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

[1]: https://github.com/drupol/nix-hands-on
[5]: https://github.com/sponsors/drupol
[github stars]:
  https://img.shields.io/github/stars/drupol/nix-hands-on.svg?style=flat-square
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
[`NixOS/nixpkgs`]: https://github.com/NixOS/nixpkgs
[`vhs`]: https://github.com/charmbracelet/vhs
