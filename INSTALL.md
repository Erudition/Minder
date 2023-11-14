# Volta & PNPM
This project uses Volta to isolate Node versions, and PNPM to manage node packages.

While PNPM support in Volta is still behind a flag, you must
export VOLTA_FEATURE_PNPM=1
to install pnpm without using npm.

Then `volta install pnpm`.