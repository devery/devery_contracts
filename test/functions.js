// Nov 1 2017
var ethPriceUSD = 307.7210;
var defaultGasPrice = web3.toWei(1, "gwei");

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Contract Owner");
addAccount(eth.accounts[2], "Account #2 - Wallet");
addAccount(eth.accounts[3], "Account #3");
addAccount(eth.accounts[4], "Account #4");
addAccount(eth.accounts[5], "Bevery App Account");
addAccount(eth.accounts[6], "Mevery App Account");
addAccount(eth.accounts[7], "Zevery App Account");
addAccount(eth.accounts[8], "Bevery Fee Account");
addAccount(eth.accounts[9], "Mevery Fee Account");
addAccount(eth.accounts[10], "Zevery Fee Account");
addAccount(eth.accounts[11], "Bevery Brand1 Account");
addAccount(eth.accounts[12], "Bevery Brand2 Account");


var minerAccount = eth.accounts[0];
var contractOwnerAccount = eth.accounts[1];
var wallet = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var beveryAppAccount = eth.accounts[5];
var meveryAppAccount = eth.accounts[6];
var zeveryAppAccount = eth.accounts[7];
var beveryFeeAccount = eth.accounts[8];
var meveryFeeAccount = eth.accounts[9];
var zeveryFeeAccount = eth.accounts[10];
var beveryBrand1Account = eth.accounts[11];
var beveryBrand2Account = eth.accounts[12];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 18 : token.decimals();
  var i = 0;
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                          Token Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalance, decimals) + " Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  var block = eth.getBlock(txReceipt.blockNumber);
  console.log("RESULT: " + name + " status=" + txReceipt.status + (txReceipt.status == 0 ? " Failure" : " Success") + " gas=" + tx.gas +
    " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH + " costUSD=" + gasCostUSD +
    " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + web3.fromWei(gasPrice, "gwei") + " gwei block=" + 
    txReceipt.blockNumber + " txIx=" + tx.transactionIndex + " txId=" + txId +
    " @ " + block.timestamp + " " + new Date(block.timestamp * 1000).toUTCString());
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function failIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 0) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 1) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


//-----------------------------------------------------------------------------
// Wait until some unixTime + additional seconds
//-----------------------------------------------------------------------------
function waitUntil(message, unixTime, addSeconds) {
  var t = parseInt(unixTime) + parseInt(addSeconds) + parseInt(1);
  var time = new Date(t * 1000);
  console.log("RESULT: Waiting until '" + message + "' at " + unixTime + "+" + addSeconds + "s =" + time + " now=" + new Date());
  while ((new Date()).getTime() <= time.getTime()) {
  }
  console.log("RESULT: Waited until '" + message + "' at at " + unixTime + "+" + addSeconds + "s =" + time + " now=" + new Date());
  console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
// Wait until some block
//-----------------------------------------------------------------------------
function waitUntilBlock(message, block, addBlocks) {
  var b = parseInt(block) + parseInt(addBlocks);
  console.log("RESULT: Waiting until '" + message + "' #" + block + "+" + addBlocks + " = #" + b + " currentBlock=" + eth.blockNumber);
  while (eth.blockNumber <= b) {
  }
  console.log("RESULT: Waited until '" + message + "' #" + block + "+" + addBlocks + " = #" + b + " currentBlock=" + eth.blockNumber);
  console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
// App Registry Contract
//-----------------------------------------------------------------------------
var appRegistryContractAddress = null;
var appRegistryContractAbi = null;

function addAppRegistryContractAddressAndAbi(address, tokenAbi) {
  appRegistryContractAddress = address;
  appRegistryContractAbi = tokenAbi;
}

var appRegistryFromBlock = 0;

function printAppRegistryContractDetails() {
  console.log("RESULT: appRegistryContractAddress=" + appRegistryContractAddress);
  if (appRegistryContractAddress != null && appRegistryContractAbi != null) {
    var contract = eth.contract(appRegistryContractAbi).at(appRegistryContractAddress);
    console.log("RESULT: appRegistry.owner=" + contract.owner());
    console.log("RESULT: appRegistry.newOwner=" + contract.newOwner());
    console.log("RESULT: appRegistry.appAccountsLength=" + contract.appAccountsLength());

    var latestBlock = eth.blockNumber;
    var i;

    for (i = 0; i < contract.appAccountsLength(); i++) {
        console.log("RESULT: appRegistry.appAccounts(" + i + ")=" + contract.appAccounts(i));
    }

    var entryAddedEvents = contract.EntryAdded({}, { fromBlock: appRegistryFromBlock, toBlock: latestBlock });
    i = 0;
    entryAddedEvents.watch(function (error, result) {
      console.log("RESULT: EntryAdded " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    entryAddedEvents.stopWatching();

    var entryUpdatedEvents = contract.EntryUpdated({}, { fromBlock: appRegistryFromBlock, toBlock: latestBlock });
    i = 0;
    entryUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: EntryUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    entryUpdatedEvents.stopWatching();

    var entryRemovedEvents = contract.EntryRemoved({}, { fromBlock: appRegistryFromBlock, toBlock: latestBlock });
    i = 0;
    entryRemovedEvents.watch(function (error, result) {
      console.log("RESULT: EntryRemoved " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    entryRemovedEvents.stopWatching();

    appRegistryFromBlock = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// Brand Registry Contract
//-----------------------------------------------------------------------------
var brandRegistryContractAddress = null;
var brandRegistryContractAbi = null;

function addBrandRegistryContractAddressAndAbi(address, tokenAbi) {
  brandRegistryContractAddress = address;
  brandRegistryContractAbi = tokenAbi;
}

var brandRegistryFromBlock = 0;

function printBrandRegistryContractDetails() {
  console.log("RESULT: brandRegistryContractAddress=" + brandRegistryContractAddress);
  if (brandRegistryContractAddress != null && brandRegistryContractAbi != null) {
    var contract = eth.contract(brandRegistryContractAbi).at(brandRegistryContractAddress);
    console.log("RESULT: brandRegistry.owner=" + contract.owner());
    console.log("RESULT: brandRegistry.newOwner=" + contract.newOwner());
    console.log("RESULT: brandRegistry.brandAccountsLength=" + contract.brandAccountsLength());

    var latestBlock = eth.blockNumber;
    var i;

    for (i = 0; i < contract.brandAccountsLength(); i++) {
        console.log("RESULT: brandRegistry.brandAccounts(" + i + ")=" + contract.brandAccounts(i));
    }

    var entryAddedEvents = contract.EntryAdded({}, { fromBlock: brandRegistryFromBlock, toBlock: latestBlock });
    i = 0;
    entryAddedEvents.watch(function (error, result) {
      console.log("RESULT: EntryAdded " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    entryAddedEvents.stopWatching();

    var entryUpdatedEvents = contract.EntryUpdated({}, { fromBlock: brandRegistryFromBlock, toBlock: latestBlock });
    i = 0;
    entryUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: EntryUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    entryUpdatedEvents.stopWatching();

    var entryRemovedEvents = contract.EntryRemoved({}, { fromBlock: brandRegistryFromBlock, toBlock: latestBlock });
    i = 0;
    entryRemovedEvents.watch(function (error, result) {
      console.log("RESULT: EntryRemoved " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    entryRemovedEvents.stopWatching();

    brandRegistryFromBlock = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// Token Contract
//-----------------------------------------------------------------------------
var tokenFromBlock = 0;
function printTokenContractDetails() {
  console.log("RESULT: tokenContractAddress=" + tokenContractAddress);
  if (tokenContractAddress != null && tokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: token.owner=" + contract.owner());
    console.log("RESULT: token.newOwner=" + contract.newOwner());
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.decimals=" + decimals);
    console.log("RESULT: token.decimalsFactor=" + contract.decimalsFactor());
    console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));
    console.log("RESULT: token.transferable=" + contract.transferable());
    console.log("RESULT: token.mintable=" + contract.mintable());
    console.log("RESULT: token.minter=" + contract.minter());

    var latestBlock = eth.blockNumber;
    var i;

    var minterUpdatedEvents = contract.MinterUpdated({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    minterUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: MinterUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    minterUpdatedEvents.stopWatching();

    var mintingDisabledEvents = contract.MintingDisabled({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    mintingDisabledEvents.watch(function (error, result) {
      console.log("RESULT: MintingDisabled " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    mintingDisabledEvents.stopWatching();

    var minterUpdatedEvents = contract.MinterUpdated({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    minterUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: MinterUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    minterUpdatedEvents.stopWatching();

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " owner=" + result.args.owner +
        " spender=" + result.args.spender + " tokens=" + result.args.tokens.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": from=" + result.args.from + " to=" + result.args.to +
        " tokens=" + result.args.tokens.shift(-decimals));
    });
    transferEvents.stopWatching();

    tokenFromBlock = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// Factory Contract
//-----------------------------------------------------------------------------
var factoryContractAddress = null;
var factoryContractAbi = null;

function addFactoryContractAddressAndAbi(address, tokenAbi) {
  factoryContractAddress = address;
  factoryContractAbi = tokenAbi;
}

var factoryFromBlock = 0;

function getBTTSFactoryTokenListing() {
  var addresses = [];
  console.log("RESULT: factoryContractAddress=" + factoryContractAddress);
  if (factoryContractAddress != null && factoryContractAbi != null) {
    var contract = eth.contract(factoryContractAbi).at(factoryContractAddress);

    var latestBlock = eth.blockNumber;
    var i;

    var bttsTokenListingEvents = contract.BTTSTokenListing({}, { fromBlock: factoryFromBlock, toBlock: latestBlock });
    i = 0;
    bttsTokenListingEvents.watch(function (error, result) {
      console.log("RESULT: get BTTSTokenListing " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
      addresses.push(result.args.bttsTokenAddress);
    });
    bttsTokenListingEvents.stopWatching();
  }
  return addresses;
}

function printFactoryContractDetails() {
  console.log("RESULT: factoryContractAddress=" + factoryContractAddress);
  if (factoryContractAddress != null && factoryContractAbi != null) {
    var contract = eth.contract(factoryContractAbi).at(factoryContractAddress);
    console.log("RESULT: factory.owner=" + contract.owner());
    console.log("RESULT: factory.newOwner=" + contract.newOwner());

    var latestBlock = eth.blockNumber;
    var i;

    var bttsTokenListingEvents = contract.BTTSTokenListing({}, { fromBlock: factoryFromBlock, toBlock: latestBlock });
    i = 0;
    bttsTokenListingEvents.watch(function (error, result) {
      console.log("RESULT: BTTSTokenListing " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    bttsTokenListingEvents.stopWatching();

    factoryFromBlock = latestBlock + 1;
  }
}

