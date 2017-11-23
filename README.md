# Devery Protocol Contracts

Status: Work in progress

<br />

<hr />

## Summary

This repository contains the Devery protocol contracts on the Ethereum Network.

<br />

<hr />

## Plans

![](images/photo6096086051354421244.jpg)

![](images/photo6096086051354421245.jpg)

![](images/photo6098337851168106486.jpg)

<br />

<hr />

## DeveryRegistry Smart Contract Design

### Stored Data

* `mapping(appAccount => App[appAccount, appName, feeAccount, active]) apps`
* `mapping(brandAccount => Brand[brandAccount, appAccount, brandName, active]) brands`
* `mapping(productAccount => Product[productAccount, brandAccount, description, details, year, origin, active]) products`
* `mapping(sha3(itemPublicKey) => productAccount) markings`
* `mapping(markerAccount => (brandAccount => permission)) permissions`

<br />

### Functions

#### App Accounts

* An account can add itself as an *App* account using `addApp(string appName, address feeAccount)`
* An account can update it's *App* account data using `updateApp(string appName, address feeAccount, bool active)`

<br />

#### Brand Accounts

* An *App* account can add *Brand* accounts using `addBrand(address brandAccount, string brandName)`
* An *App* account can update it's *Brand* account data using `updateBrand(address brandAccount, string brandName, bool active)`

<br />

#### Product Accounts

* A *Brand* account can add *Product* accounts using `addProduct(address productAccount, string description, string details, uint year, string origin)`
* A *Brand* account can update it's *Product* account data using `updateProduct(address productAccount, string description, string details, uint year, string origin, bool active)`

<br />

#### Permissions

* A *Brand* account can add *Marker* accounts using `permissionMarker(address marker, bool permission)`

<br />

#### Marking

* A *Marker* account can add the hash of an *Item*'s public key using `mark(address productAccount, bytes32 itemHash)`. The `productAccount` is the
  type of *Product* the *Item* is.

<br />

#### Checking

* Anyone can check the validity of an *Item*'s public key using `check(address item)`

<br />

<hr />

## Sample Data

```
 # Account                                             EtherBalanceChange                          Token Name
-- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e       62.009912518000000000           0.000000000000000000 Account #0 - Miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -0.004998436000000000           0.000000000000000000 Account #1 - Contract Owner
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976        0.000000000000000000           0.000000000000000000 Account #2 - Wallet
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000 Account #3
 4 0xa44a08d3f6933c69212114bb66e2df1813651844        0.000000000000000000           0.000000000000000000 Account #4
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.000821940000000000           0.000000000000000000 Bevery App Account
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.000237772000000000           0.000000000000000000 Mevery App Account
 7 0xa77a2b9d4b1c010a22a7c565dc418cef683dbcec       -0.000252900000000000           0.000000000000000000 Zevery App Account
 8 0xa88a05d2b88283ce84c8325760b72a64591279a2        0.000000000000000000           0.000000000000000000 Bevery Fee Account
 9 0xa99a0ae3354c06b1459fd441a32a3f71005d7da0        0.000000000000000000           0.000000000000000000 Mevery Fee Account
10 0xaaaa9de1e6c564446ebca0fd102d8bd92093c756        0.000000000000000000           0.000000000000000000 Zevery Fee Account
11 0xabba43e7594e3b76afb157989e93c6621497fd4b       -0.002504824000000000           0.000000000000000000 Bevery Brand 1 Account
12 0xacca534c9f62ab495bd986e002ddf0f054caae4f        0.000000000000000000           0.000000000000000000 Bevery Brand 2 Account
13 0xadda9b762a00ff12711113bfdc36958b73d7f915        0.000000000000000000           0.000000000000000000 Bevery Brand 1 Product A Account
14 0xaeea63b5479b50f79583ec49dacdcf86ddeff392        0.000000000000000000           0.000000000000000000 Bevery Brand 1 Product B Account
15 0xaffa4d3a80add8ce4018540e056dacb649589394       -0.000548259000000000           0.000000000000000000 Bevery Marker 1
16 0xb00bfde102270687324f9205b693859df64f8923       -0.000548387000000000           0.000000000000000000 Bevery Marker 2
17 0xb11be1d4ef8e94d01cb2695092a79d139a8dad98        0.000000000000000000           0.000000000000000000 Bevery Brand 1 Product A Item 1
18 0xb22be2d9eef0d7e260cf96a64feea0b95ed3e74f        0.000000000000000000           0.000000000000000000 Bevery Brand 1 Product B Item 2
19 0x0e946b999033257976aa5cbe0e3530618ca1582d        0.000000000000000000           0.000000000000000000 Devery Registry
-- ------------------------------------------ --------------------------- ------------------------------ ---------------------------
                                                                                    0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ---------------------------

PASS Mark Items - Mark Bevery Brand 1 Product A Item 1
PASS Mark Items - Mark Bevery Brand 1 Product A Item 2
registryContractAddress=0x0e946b999033257976aa5cbe0e3530618ca1582d
registry.owner=0xa11aae29840fbb5c86e6fd4cf809eba183aef433
registry.newOwner=0x0000000000000000000000000000000000000000
registry.appAccountsLength=3
registry.appAccounts(0)=0xa55a151eb00fded1634d27d1127b4be4627079ea ["0xa55a151eb00fded1634d27d1127b4be4627079ea","Bevery","0xa88a05d2b88283ce84c8325760b72a64591279a2",true]
registry.appAccounts(1)=0xa77a2b9d4b1c010a22a7c565dc418cef683dbcec ["0xa77a2b9d4b1c010a22a7c565dc418cef683dbcec","Zevery","0xaaaa9de1e6c564446ebca0fd102d8bd92093c756",true]
registry.appAccounts(2)=0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9 ["0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9","Mevery","0xa99a0ae3354c06b1459fd441a32a3f71005d7da0",true]
registry.brandAccountsLength=2
registry.brandAccounts(0)=0xabba43e7594e3b76afb157989e93c6621497fd4b ["0xabba43e7594e3b76afb157989e93c6621497fd4b","0xa55a151eb00fded1634d27d1127b4be4627079ea","Bevery Brand 1",true]
registry.brandAccounts(1)=0xacca534c9f62ab495bd986e002ddf0f054caae4f ["0xacca534c9f62ab495bd986e002ddf0f054caae4f","0xa55a151eb00fded1634d27d1127b4be4627079ea","Bevery Brand 2",true]
registry.productAccountsLength=2
registry.productAccounts(0)=0xadda9b762a00ff12711113bfdc36958b73d7f915 ["0xadda9b762a00ff12711113bfdc36958b73d7f915","0xabba43e7594e3b76afb157989e93c6621497fd4b","Bevery Brand 1 Product A","eeeeks","2016","AU",true]
registry.productAccounts(1)=0xaeea63b5479b50f79583ec49dacdcf86ddeff392 ["0xaeea63b5479b50f79583ec49dacdcf86ddeff392","0xabba43e7594e3b76afb157989e93c6621497fd4b","Bevery Brand 1 Product B","yiikes","2017","AU",true]
Marked 0 #20 {"itemHash":"0x2b3634a5c18d4e8930e0f611da00ec8a02f8621a48cfe55f3ed01f2403714bcd","marker":"0xaffa4d3a80add8ce4018540e056dacb649589394","productAccount":"0xadda9b762a00ff12711113bfdc36958b73d7f915"}
Marked 1 #20 {"itemHash":"0x72155cd1c213c52cf878b5a5870f491df385a53fc68499ec839865239c19a7d1","marker":"0xb00bfde102270687324f9205b693859df64f8923","productAccount":"0xaeea63b5479b50f79583ec49dacdcf86ddeff392"}

Checking Bevery Brand 1 Product A Item 1: 0xb11be1d4ef8e94d01cb2695092a79d139a8dad98 productAccount=0xadda9b762a00ff12711113bfdc36958b73d7f915 brandAccount=0xabba43e7594e3b76afb157989e93c6621497fd4b appAccount=0xa55a151eb00fded1634d27d1127b4be4627079ea
  productDetails: ["0xadda9b762a00ff12711113bfdc36958b73d7f915","0xabba43e7594e3b76afb157989e93c6621497fd4b","Bevery Brand 1 Product A","eeeeks","2016","AU",true]
Checking Bevery Brand 1 Product A Item 2: 0xb22be2d9eef0d7e260cf96a64feea0b95ed3e74f productAccount=0xaeea63b5479b50f79583ec49dacdcf86ddeff392 brandAccount=0xabba43e7594e3b76afb157989e93c6621497fd4b appAccount=0xa55a151eb00fded1634d27d1127b4be4627079ea
  productDetails: ["0xaeea63b5479b50f79583ec49dacdcf86ddeff392","0xabba43e7594e3b76afb157989e93c6621497fd4b","Bevery Brand 1 Product B","yiikes","2017","AU",true]
Checking Invalid Item: 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0 productAccount=0x0000000000000000000000000000000000000000 brandAccount=0x0000000000000000000000000000000000000000 appAccount=0x0000000000000000000000000000000000000000
```

<br />

<hr />

## Deployment On Ropsten

[DeveryRegistry.sol #caec998](https://github.com/devery/devery_contracts/blob/caec998c47ca3b9d111d58b8ea1d907b131c1706/contracts/DeveryRegistry.sol)
has been deployed to Ropsten at address [0x654f4a3e3B7573D6b4bB7201AB70d718961765CD](https://ropsten.etherscan.io/address/0x654f4a3e3B7573D6b4bB7201AB70d718961765CD#code).

