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

contract DeveryAppRegistry is Admined {

    struct AppRegistryEntry {
        address appAccount;
        string appName;
        address feeAccount;
    }

    mapping(address => AppRegistryEntry) public entries;
    address[] public appAccounts;

    event EntryAdded(address appAccount, string appName, address feeAccount);
    event EntryUpdated(address appAccount, string appName, address feeAccount);
    event EntryRemoved(address appAccount, string appName, address feeAccount);

    // ------------------------------------------------------------------------
    // Account can register a new App account, or update an existing App
    // account
    // ------------------------------------------------------------------------
    function register(string appName, address feeAccount) public {
        AppRegistryEntry storage e = entries[msg.sender];
        if (e.appAccount == address(0)) {
            entries[msg.sender] = AppRegistryEntry({
                appAccount: msg.sender,
                appName: appName,
                feeAccount: feeAccount
            });
            appAccounts.push(msg.sender);
            EntryAdded(msg.sender, appName, feeAccount);
        } else {
            require(msg.sender == e.appAccount);
            e.appName = appName;
            e.feeAccount = feeAccount;
            EntryUpdated(msg.sender, appName, feeAccount);
        }
    }

    // ------------------------------------------------------------------------
    // Account can deregister their App account, or admin can deregister
    // ------------------------------------------------------------------------
    function deRegister(address appAccount) public {
        require(appAccount == msg.sender || isAdmin(msg.sender));
        AppRegistryEntry storage e = entries[appAccount];
        for (uint i = 0; i < appAccounts.length - 1; i++) {
            if (appAccounts[i] == appAccount) {
                appAccounts[i] = appAccounts[appAccounts.length - 1];
                break;
            }
        }
        appAccounts.length -= 1;
        EntryRemoved(appAccount, e.appName, e.feeAccount);
        delete entries[appAccount];
    }

    function get(address appAccount) public constant returns (string appName, address feeAccount) {
        AppRegistryEntry storage e = entries[appAccount];
        appName = e.appName;
        feeAccount = e.feeAccount;
    }

    function getFeeAccount(address appAccount) public constant returns (address feeAccount) {
        AppRegistryEntry storage e = entries[appAccount];
        feeAccount = e.feeAccount;
    }

    function appAccountsLength() public constant returns (uint) {
        return appAccounts.length;
    }
}
