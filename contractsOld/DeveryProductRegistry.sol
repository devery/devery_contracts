pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// Devery Contracts - Product Registry
//
// Deployed to : 
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd for Devery 2017. The MIT Licence.
// ----------------------------------------------------------------------------

import "./DeveryCommon.sol";

interface DeveryAppRegistry {
    function getAccounts(address appAccount) public constant returns (address feeAccount);
}

interface DeveryBrandRegistry {
    function getAccounts(address brandAccount) public constant returns (address appAccount, address appFeeAccount);
}

contract DeveryProductRegistry is Admined {

    struct ProductRegistryEntry {
        address productAccount;
        address brandAccount;
        string description;
        string details;
        uint year;
        string origin;
    }

    DeveryAppRegistry public appRegistry;
    DeveryBrandRegistry public brandRegistry; 
    mapping(address => ProductRegistryEntry) public entries;
    address[] public productAccounts;

    event EntryAdded(address productAccount, address brandAccount, address appAccount, string description);
    event EntryUpdated(address productAccount, address brandAccount, address appAccount, string description);
    event EntryRemoved(address productAccount, address brandAccount, address appAccount, string description);

    function DeveryProductRegistry(DeveryAppRegistry _appRegistry, DeveryBrandRegistry _brandRegistry) public {
        require(_appRegistry != address(0));
        appRegistry = _appRegistry;
        require(_brandRegistry != address(0));
        brandRegistry = _brandRegistry;
    }


    // ------------------------------------------------------------------------
    // Brand account can register a new Product account, or update an existing
    // Product account
    // ------------------------------------------------------------------------
    function register(address productAccount, string description, string details, uint year, string origin) public {
        address appAccount;
        address appFeeAccount;
        (appAccount, appFeeAccount) = brandRegistry.getAccounts(msg.sender);
        require(appAccount != address(0));
        ProductRegistryEntry storage e = entries[productAccount];
        if (e.brandAccount == address(0)) {
            entries[productAccount] = ProductRegistryEntry({
                productAccount: productAccount,
                brandAccount: msg.sender,
                description: description,
                details: details,
                year: year,
                origin: origin
            });
            productAccounts.push(productAccount);
            EntryAdded(productAccount, msg.sender, appAccount, description);
        } else {
            require(msg.sender == e.brandAccount);
            e.description = description;
            e.details = details;
            e.year = year;
            e.origin = origin;
            EntryUpdated(productAccount, msg.sender, appAccount, description);
        }
    }

/*
    // ------------------------------------------------------------------------
    // App account can deregister their Brand account, or admin can deregister
    // ------------------------------------------------------------------------
    function deRegister(address brandAccount) public {
        BrandRegistryEntry storage e = entries[brandAccount];
        require(e.appAccount == msg.sender || isAdmin(msg.sender));
        for (uint i = 0; i < brandAccounts.length - 1; i++) {
            if (brandAccounts[i] == brandAccount) {
                brandAccounts[i] = brandAccounts[brandAccounts.length - 1];
                break;
            }
        }
        brandAccounts.length -= 1;
        EntryRemoved(brandAccount, e.appAccount, e.brandName);
        delete entries[brandAccount];
    }

    */

    /*
    function get(address productAccount) public constant returns (address brandAccount, address appAccount, address appFeeAccount, string brandName) {
        BrandRegistryEntry storage e = entries[brandAccount];
        require(e.appAccount != address(0));
        appAccount = e.appAccount;
        appFeeAccount = appRegistry.getAccounts(e.appAccount);
        brandName = e.brandName;
    }*/

    function getAccounts(address productAccount) public constant returns (address brandAccount, address appAccount, address appFeeAccount) {
        ProductRegistryEntry storage e = entries[productAccount];
        require(e.brandAccount != address(0));
        brandAccount = e.brandAccount;
        (appAccount, appFeeAccount) = brandRegistry.getAccounts(e.brandAccount);
    }

    function productAccountsLength() public constant returns (uint) {
        return productAccounts.length;
    }
}
