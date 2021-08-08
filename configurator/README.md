# Install

1. Fork this repository.
1. Run `yarn generate` to generate the initial cluster manifest.
1. Open `customize.ts` and make the desired customizations.
   1. Run `yarn generate` to regenerate the cluster manifest.
   1. Run `yarn compare` to view the differences between your cluster manfiest and the default cluster manifest.
1. Commit your changes to your fork, including the contents of `customize.ts` and `rendered/`.

Notes:
* Do not make any changes directly to the files in `rendered`. These should only be emitted by
  running `yarn generate`.
* The only files you modify should be `customize.ts` and the contents of the `rendered`
  directory. If you modify any other files, this may result in merge conflicts on upgrade.

# Upgrade

1. Rebase your fork against upstream.
   1. Note: There should be no merge conflicts if you followed the installation instructions.
1. Run `yarn generate`. Use `git diff` to show the differences to the manifest as a result of the
   upgrade. Verify these are correct. If necessary, make changes to `customize.ts` and regenerate.
1. Commit the changes.
