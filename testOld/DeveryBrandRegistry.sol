pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// Devery Contracts - Brand Registry
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

contract DeveryBrandRegistry is Admined {

    struct BrandRegistryEntry {
        address brandAccount;
        address appAccount;
        string brandName;
    }

    DeveryAppRegistry public appRegistry; 
    mapping(address => BrandRegistryEntry) public entries;
    address[] public brandAccounts;

    event EntryAdded(address brandAccount, address appAccount, string brandName);
    event EntryUpdated(address brandAccount, address appAccount, string brandName);
    event EntryRemoved(address brandAccount, address appAccount, string brandName);

    function DeveryBrandRegistry(DeveryAppRegistry _appRegistry) public {
        require(_appRegistry != address(0));
        appRegistry = _appRegistry;
    }

    // ------------------------------------------------------------------------
    // App account can register a new Brand account, or update an existing
    // Brand account
    // ------------------------------------------------------------------------
    function register(address brandAccount, string brandName) public {
        address feeAccount = appRegistry.getAccounts(msg.sender);
        require(feeAccount != address(0));
        BrandRegistryEntry storage e = entries[brandAccount];
        if (e.appAccount == address(0)) {
            entries[brandAccount] = BrandRegistryEntry({
                brandAccount: brandAccount,
                appAccount: msg.sender,
                brandName: brandName
            });
            brandAccounts.push(brandAccount);
            EntryAdded(brandAccount, msg.sender, brandName);
        } else {
            require(msg.sender == e.appAccount);
            e.brandName = brandName;
            EntryUpdated(brandAccount, msg.sender, brandName);
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
        EntryRemoved(brandAccount, e.appAccount, e.brandName);
        delete entries[brandAccount];
    }

    function get(address brandAccount) public constant returns (address appAccount, address appFeeAccount, string brandName) {
        BrandRegistryEntry storage e = entries[brandAccount];
        require(e.appAccount != address(0));
        appAccount = e.appAccount;
        appFeeAccount = appRegistry.getAccounts(e.appAccount);
        brandName = e.brandName;
    }

    function getAccounts(address brandAccount) public constant returns (address appAccount, address appFeeAccount) {
        BrandRegistryEntry storage e = entries[brandAccount];
        require(e.appAccount != address(0));
        appAccount = e.appAccount;
        appFeeAccount = appRegistry.getAccounts(e.appAccount);
    }

    function brandAccountsLength() public constant returns (uint) {
        return brandAccounts.length;
    }
}
