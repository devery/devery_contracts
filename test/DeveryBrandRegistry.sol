pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// Devery Contracts - App Registry
//
// Deployed to : 
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd for Devery 2017. The MIT Licence.
// ----------------------------------------------------------------------------

import "./DeveryCommon.sol";

interface DeveryAppRegistry {
    function get(address appAccount) public constant returns (string name, address feeAccount);
    function getFeeAccount(address appAccount) public constant returns (address feeAccount);
}

contract DeveryBrandRegistry is Admined {

    struct BrandRegistryEntry {
        address brandAccount;
        address appAccount;
        string name;
    }

    DeveryAppRegistry public appRegistry; 
    mapping(address => BrandRegistryEntry) public entries;
    address[] public brandAccounts;

    event EntryAdded(address brandAccount, address appAccount, string name);
    event EntryUpdated(address brandAccount, address appAccount, string name);
    event EntryRemoved(address brandAccount, address appAccount, string name);

    function DeveryBrandRegistry(DeveryAppRegistry _appRegistry) public {
        require(_appRegistry != address(0));
        appRegistry = _appRegistry;
    }

    // ------------------------------------------------------------------------
    // App account can register a new Brand account, or update an existing
    // Brand account
    // ------------------------------------------------------------------------
    function register(address brandAccount, string name) public {
        address feeAccount = appRegistry.getFeeAccount(msg.sender);
        require(feeAccount != address(0));
        BrandRegistryEntry storage e = entries[brandAccount];
        if (e.appAccount == address(0)) {
            entries[brandAccount] = BrandRegistryEntry({
                brandAccount: brandAccount,
                appAccount: msg.sender,
                name: name
            });
            brandAccounts.push(brandAccount);
            EntryAdded(brandAccount, msg.sender, name);
        } else {
            require(msg.sender == e.appAccount);
            e.name = name;
            EntryUpdated(brandAccount, msg.sender, name);
        }
    }

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
        EntryRemoved(brandAccount, e.appAccount, e.name);
        delete entries[brandAccount];
    }

    function get(address brandAccount) public constant returns (address appAccount, address appFeeAccount, string brandName) {
        BrandRegistryEntry storage e = entries[brandAccount];
        require(e.appAccount != address(0));
        appAccount = e.appAccount;
        appFeeAccount = appRegistry.getFeeAccount(e.appAccount);
        brandName = e.name;
    }

    function brandAccountsLength() public constant returns (uint) {
        return brandAccounts.length;
    }
}
