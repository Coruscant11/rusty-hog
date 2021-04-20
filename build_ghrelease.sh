#!/bin/bash

if [[ $(uname) != "Darwin" ]]; then
  echo "script currently designed to build for macs and musl"
  exit 1
fi

cargo build --release
if [ $? -ne 0 ]; then
  echo "cargo build returned non-zero exit code"
  exit 1
fi

cross build --release --target x86_64-unknown-linux-musl
if [ $? -ne 0 ]; then
  echo "cross build returned non-zero exit code"
  exit 1
fi

cp target/x86_64-unknown-linux-musl/release/berkshire_hog_lambda bootstrap
zip -j berkshire_lambda.zip bootstrap
mkdir darwin_releases
mkdir musl_releases
cp target/release/*_hog darwin_releases
cp target/x86_64-unknown-linux-musl/release/*_hog musl_releases
mv scripts/.idea ../
strip darwin_releases/*
upx --best --lzma musl_releases/*
zip -r rustyhogs-darwin_$1.zip darwin_releases
zip -r rustyhogs-linux_$1.zip musl_releases
zip -r rustyhogs-lambda_$1.zip berkshire_lambda.zip
zip -r rustyhogs-scripts_$1.zip scripts
rm -rf darwin_releases musl_releases
mv ../.idea scripts
echo "Output build in release.zip"

