pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// Devery Contracts
//
// Deployed to : 
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd for Devery 2017. The MIT Licence.
// ----------------------------------------------------------------------------

// import "./DeveryCommon.sol";

contract DeveryAppRegistry /* is Admined */ {

    struct AppRegistryEntry {
        address appAccount;
        address appOwner;
        string name;
        address feeAccount;
    }
    mapping(address => AppRegistryEntry) entries;
    // address[] public appOwners;

    event Registered(address appOwner, address appAccount, string name, address feeAccount);
    event DeRegistered(address appOwner, address appAccount, string name, address feeAccount);

    // accounts[0] 0xca35b7d915458ef540ade6068dfe2f44e8fa733c
    // accounts[1] 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c
    // accounts[2] 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db
    // accounts[3] 0x583031d1113ad414f02576bd6afabfb302140225
    // "0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db", "test1", "0x583031d1113ad414f02576bd6afabfb302140225"
    // "0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db", "test2", "0x583031d1113ad414f02576bd6afabfb302140225"
    // "0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db", "test3", "0x583031d1113ad414f02576bd6afabfb302140225"
    function register(address appAccount, string name, address feeAccount) public {
        AppRegistryEntry storage e = entries[appAccount];
        if (e.appOwner == address(0)) {
            entries[appAccount] = AppRegistryEntry({
                appAccount: appAccount,
                appOwner: msg.sender,
                name: name,
                feeAccount: feeAccount
            });
            Registered(msg.sender, appAccount, name, feeAccount);
        } else {
            require(msg.sender == e.appOwner);
            entries[appAccount].name = name;
            entries[appAccount].feeAccount = feeAccount;
            Registered(msg.sender, appAccount, name, feeAccount);
        }
    }


    function deRegister(address appAccount) public {
        AppRegistryEntry storage e = entries[appAccount];
        // TODO: add admin below
        require(e.appOwner == msg.sender);
        DeRegistered(e.appOwner, e.appAccount, e.name, e.feeAccount);
        delete entries[appAccount];
    }

    function get(address appAccount) public constant returns (address appOwner, string name, address feeAccount) {
        AppRegistryEntry storage e = entries[appAccount];
        appOwner = e.appOwner;
        name = e.name;
        feeAccount = e.feeAccount;
    }
}
