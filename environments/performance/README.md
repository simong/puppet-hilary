# Sakai OAE Performance Testing Environment

## Environment
The environment can be configured in the `env-staging.json` file in the slapchop repository.
At a minimum it should contain:

 * 1 App node
 * 1 Cassandra node
 * 1 Elasticsearch node
 * 1 Redis node
 * 1 Rabbitmq node
 * 1 Driver node

 ## Process

 The driver node is responsible for creating and tearing down the environment. This means that you should always leave
 the driver and puppet node running.

 When you install the driver node, puppet will configure a cronjob to run at midnight which will execute the `nightly-run.sh` script
 from the `oae-nightly-stats` repository. This script takes care of everything.
 It will:
  * Bootstrap a performance environment
  * Generate and load data
  * Run a tsung test
  * Destroy the environment (all nodes except the puppet and driver node)

Bootstrapping the environment happens by virtue of `Slapchop`. It's a small wrapper
around the Joyent API which allows us to create a whole bunch of nodes in one go.


# Manual intervention
Make sure that your puppetmaster is updated with the latest code and the repositories point too the correct revisions.