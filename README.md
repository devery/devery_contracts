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
