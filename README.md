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

## Notes

* Currently the registries have an array to record the addresses held in the mapping contract. If the number of item gets
  too large, the `deRegister(...)` will fail. So consider removing this, and just allow the registry entries to be deactivated

<br />

<hr />

## Deployment On Ropsten

[DeveryRegistry.sol #caec998](https://github.com/devery/devery_contracts/blob/caec998c47ca3b9d111d58b8ea1d907b131c1706/contracts/DeveryRegistry.sol)
has been deployed to Ropsten at address [0x654f4a3e3B7573D6b4bB7201AB70d718961765CD](https://ropsten.etherscan.io/address/0x654f4a3e3B7573D6b4bB7201AB70d718961765CD#code).

