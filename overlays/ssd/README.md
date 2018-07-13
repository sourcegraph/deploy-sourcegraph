# SSD

This overlay adds a local SSD to each deployment that would benefit from the performance of a SSD.

## Usage

This overlay can't be used directly because the path where SSDs are mounted depends on your compute provider.

- If you are using Google Cloud Platform, you can use the overlay defined in the `gcp` subfolder.
- If you are using any other provider, create your own overlay by copying the `gcp` subfolder and replacing all instances of `/mnt/disks/ssd0` with the SSD path that your provider uses for mounted SSDs. We would love to have examples for all providers, so submit a pull request!
