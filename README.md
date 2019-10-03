## Fabric Private Data 
This tutorial will help to understand the private data storage and retrieval by authorised and unauthorised organisation.
  

### Installation Guide
Kindly install all the [Prerequisites](https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html) mentioned on the official documentation. Make sure we have all the Docker Images downloaded locally.
For exploration, take a VM with 16GB and 4 vCPU.

**# Step 1**

Clone the git repository on all the VM as below.

```bash
    https://github.com/dineshrivankar/fabric-private-data.git
```

**# Step 2**

Create a Swarm Network by running the below script from home directory of the cloned repository.

```bash
    ./network-setup.sh
```

**# Step 3**

Generate Crypto material for all the participants and Deploy the peers by running the below script. For exploration we will use Solo mode for the Ordering service

```bash
     ./deploy.sh
```

**# Step 4**

Org1 runs a cli container, below script will create a channel, join all the peers to the channel, install & instantiate chaincode, invoke & query chaincode.


```bash
     ./run.sh
```

**# Step 5**

Reset the network by running below script.

```bash
     ./reset.sh 
```


That’s it!

Feel free to submit a PR.