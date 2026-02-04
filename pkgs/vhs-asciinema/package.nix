{
  vhs,
  fetchurl,
}:

# We will use the `vhs` package from `nixpkgs` and
# override some parts of its definition.
vhs.overrideAttrs (oldAttrs: {
  patches =
    # This is a safeguard measure in case there are existing patches in the
    # original definition.
    (oldAttrs.patches or [ ])
    ++
    # Add a custom patch to support `asciinema` output with `vhs`
    # See https://github.com/charmbracelet/vhs/discussions/225#discussioncomment-15730366
    [
      (fetchurl {
        url = "https://github.com/taigrr/vhs/commit/6f4958692aa321d5ccf671d1ff0ca34674bd0475.patch";
        hash = "sha256-IxWpn8pQr3uVUzseTetHbfcpHa15JJKqcP2oXiyLFQs=";
      })
    ];
})
