# CVC5 WebAssembly converter

This project provides an easy-going way to compile CVC5 into a WebAssembly binary.

## Run

To generate the binary, just run the `cvc5.sh` bash. The main thing to be concerned about is that this bash file is signaling to CVC5, by default, to compile in the JS mode (generate a .wasm binary and a .js glue code).

To change this, go inside the bash file in the `Configuring CVC5` section and change the `--wasm` flag in the `CVC5_CONFIGURE_OPTS` variable. The values that can be assigned to this flag are described below.

## Compilation options:

The `--wasm` flag accepts four values:

* OFF: Disable the WebAssembly compilation. This way, it enables the default compilation.
* WASM: Enable the WebAssembly compilation, generating a .wasm file.
* JS: Enable the WebAssembly compilation, generating a .wasm and .js (glue code) files.
* HTML:  Enable the WebAssembly compilation, generating a .wasm, .js (glue code) and .html files.

## Author:
* Vinícius Braga Freire: vinicius.braga.freire@gmail.com