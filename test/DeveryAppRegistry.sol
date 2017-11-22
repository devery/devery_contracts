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
        string name;
        address feeAccount;
    }

    mapping(address => AppRegistryEntry) public entries;
    address[] public appAccounts;

    event EntryAdded(address appAccount, string name, address feeAccount);
    event EntryUpdated(address appAccount, string name, address feeAccount);
    event EntryRemoved(address appAccount, string name, address feeAccount);

    // ------------------------------------------------------------------------
    // Account can register a new App account, or update existing App account
    // ------------------------------------------------------------------------
    function register(string name, address feeAccount) public {
        AppRegistryEntry storage e = entries[msg.sender];
        if (e.appAccount == address(0)) {
            entries[msg.sender] = AppRegistryEntry({
                appAccount: msg.sender,
                name: name,
                feeAccount: feeAccount
            });
            appAccounts.push(msg.sender);
            EntryAdded(msg.sender, name, feeAccount);
        } else {
            require(msg.sender == e.appAccount);
            e.name = name;
            e.feeAccount = feeAccount;
            EntryUpdated(msg.sender, name, feeAccount);
        }
    }

    // ------------------------------------------------------------------------
    // Account can deregister an App account, or admin can deregister
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
        EntryRemoved(appAccount, e.name, e.feeAccount);
        delete entries[appAccount];
    }

    function get(address appAccount) public constant returns (string name, address feeAccount) {
        AppRegistryEntry storage e = entries[appAccount];
        name = e.name;
        feeAccount = e.feeAccount;
    }

    function appAccountsLength() public constant returns (uint) {
        return appAccounts.length;
    }
}
