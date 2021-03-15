# confluent-operator-helper
Helpers for working with the Confluent Operator


## [co-latest-images.sh](./co-latest-images.sh)

Searches the current directory for yaml files that contain references to container images. It then searches Docker Hub for the latest version of that image. This tool does not take into account version compatibilities. For example, if executed against a directory containing Confluent Operator 1.5.2 it will report the original tag of an image as something like 5.5.2.0 and the latest version as something like 6.1.0.0, but that doesn't guarantee that version of Operator will work with the latest version of the image. The following environment variables are used.

* **REGISTRY** : Registry to search for the latest versions (default: https://registry.hub.docker.com)
* **OPERATOR_DIR** : Directory to search for image references (default: current directory, i.e. '.')

## Released Operators

* [Early Access 2.0](https://github.com/confluentinc/operator-earlyaccess/)
* [v1.7.0 for CP 6.1.0.0](https://platform-ops-bin.s3-us-west-1.amazonaws.com/operator/confluent-operator-1.7.0.tar.gz)
* [v1.6.0 for CP 6.0.0.0](https://platform-ops-bin.s3-us-west-1.amazonaws.com/operator/confluent-operator-1.6.0-for-confluent-platform-6.0.0.tar.gz)
* [v1.5.2 for CP 5.5.2.0](https://platform-ops-bin.s3-us-west-1.amazonaws.com/operator/confluent-operator-1.5.2-for-confluent-platform-5.5.2.tar.gz)
* [v0.65.1 for CP 5.3.1.0](https://platform-ops-bin.s3-us-west-1.amazonaws.com/operator/confluent-operator-20190912-v0.65.1.tar.gz)
