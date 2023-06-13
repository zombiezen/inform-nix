# Inform Nix Flake

This is a packaging of [Inform][] with [Nix][].
The version available in nixpkgs predates the [open-sourcing of Inform][],
so it necessarily downloads binaries and packages them.
This packaging builds Inform from source.
I would like to upstream this to nixpkgs,
but I don't have the time to get the GUI derivation working.
I am publishing my efforts in the interest of someone helping upstream this.

Try it out with:

```shell
nix run github:zombiezen/inform-nix -- -help
```

[Inform]: https://ganelson.github.io/inform-website/
[Nix]: https://nixos.org/
[open-sourcing]: https://intfiction.org/t/inform-7-v10-1-0-is-now-open-source/55674

## License

The flake is released as [MIT](./LICENSE), same as nixpkgs.
Inform itself is released under the [Artistic License 2.0][].

[Artistic License 2.0]: https://github.com/ganelson/inform/blob/v10.1.2/LICENSE
