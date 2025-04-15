# `pdptool` dockerized

`pdptool`  images are available in the repository [packages](https://github.com/LesnyRumcajs/pdp/pkgs/container/pdptool) and can be pulled from there. The images are built automatically on every commit to the `main` branch for both `amd64` and `arm64` architectures.

## Usage

All examples are in `fish` shell, but they can be easily adapted to `bash` or `zsh`.

The images are built with the following tags:
- `edge` - latest commit from the `main` branch
- `<DATE>-<COMMIT>` - specific commit from the `main` branch, e.g., `2025-04-15-f7a298a`.

To test the image, you can run the following command:
```fish
docker run -it ghcr.io/lesnyrumcajs/pdptool:edge --version
``` 

### Running `pdptool`

If running via `docker` exclusively, I recommend creating an alias (which I'll use from now on) for the command:
```fish
alias --save pdpd='docker run -it --mount type=bind,src=$PWD/pdp-data,dst=/data ghcr.io/lesnyrumcajs/pdptool:edge'
```
Note the `--mount` option, which mounts the current `pdp-data` directory to the `/data` directory in the container. This allows you to access the data files from your host machine. It is  needed to persist secrets and share files. You might just want to bind to the current directory.

### Creating a service secret

This secret is to be configured on the Curio side. You should get a service name in return, which will be used in other commands.
```fish
pdpd create-service-secret
Public Key:
-----BEGIN PUBLIC KEY-----
cGgnbmdsdWkgbWdsdyduYWZoIEN0aHVsaHUgUidseWVoIHdnYWgnbmFnbCBmaHRhZ24K
-----END PUBLIC KEY-----
```

### Uploading a file
Move the file to the `pdp-data` directory and run:
```fish
pdpd upload-file --service-url https://pdp.rumcajs.dev --service-name pdp-service-3 /data/cathulhu-cute.jpg
Uploading... 100% |████████████████████████████████████████| 0: pieceSize: 65536                                                                                               15:08:41 [72/89]
baga6ea4seaqegv4ec6qtzzjk4gfk64ltyoicya4brgq5n34ove7gcmojynuroaa:baga6ea4seaqegv4ec6qtzzjk4gfk64ltyoicya4brgq5n34ove7gcmojynuroaa
```

### Creating a proof set
You can get the contract address [here](https://github.com/FilOzone/pdp?tab=readme-ov-file#contracts).
You'll get a transaction hash in return.
```fish
pdpd create-proof-set --service-url https://pdp.rumcajs.dev --service-name pdp-service-3 --recordkeeper 0x6170dE2b09b404776197485F3dc6c968Ef948505
Proof set creation initiated successfully.
Location: /pdp/proof-sets/created/0x5b4a0b4193f24ec4a47ed00ea7fca065192bd3f186e9cda40289aed035d3db93
Response:
```

Periodically query the status:
```fish
pdpd get-proof-set-create-status --service-url https://pdp.rumcajs.dev --service-name pdp-service-3 --tx-hash 0x5b4a0b4193f24ec4a47ed00ea7fca065192bd3f186e9cda40289aed035d3db93
Proof Set Creation Status:
Transaction Hash: 0x5b4a0b4193f24ec4a47ed00ea7fca065192bd3f186e9cda40289aed035d3db93
Transaction Status: confirmed
Transaction Successful: true
Proofset Created: true
ProofSet ID: 45
```

Note down the `ProofSet ID`, as it will be used in the next command.

### Add roots
```fish
❯ pdpd add-roots --service-url https://pdp.rumcajs.dev --service-name pdp-service-3 --proof-set-id=45  --root baga6ea4seaqegv4ec6qtzzjk4gfk64ltyoicya4brgq5n34ove7gcmojynuroaa:baga6ea4seaqegv4ec6qtzzjk4gfk64ltyoicya4brgq5n34ove7gcmojynuroaa
```

Assert all is in place in the [PDP Explorer](https://calibration.pdp-explorer.eng.filoz.org). This specific proofset can be found [here](https://calibration.pdp-explorer.eng.filoz.org/proofsets/45).
