#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

REGISTRYSOL=`grep ^REGISTRYSOL= settings.txt | sed "s/^.*=//"`
REGISTRYJS=`grep ^REGISTRYJS= settings.txt | sed "s/^.*=//"`
TOKENSOL=`grep ^TOKENSOL= settings.txt | sed "s/^.*=//"`
TOKENJS=`grep ^TOKENJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

BLOCKSINDAY=10

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+90" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*3" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE            = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD        = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR       = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "REGISTRYSOL     = '$REGISTRYSOL'\n" | tee -a $TEST1OUTPUT
printf "REGISTRYJS      = '$REGISTRYJS'\n" | tee -a $TEST1OUTPUT
printf "TOKENSOL     = '$TOKENSOL'\n" | tee -a $TEST1OUTPUT
printf "TOKENJS      = '$TOKENJS'\n" | tee -a $TEST1OUTPUT
printf "DEPLOYMENTDATA  = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS       = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT     = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS    = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME     = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "STARTTIME       = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST1OUTPUT
printf "ENDTIME         = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp $SOURCEDIR/*.sol .`
#`cp $SOURCEDIR/$ECVERIFYSOL .`

# --- Modify parameters ---
# `perl -pi -e "s/bool transferable/bool public transferable/" $TOKENSOL`
# `perl -pi -e "s/MULTISIG_WALLET_ADDRESS \= 0xc79ab28c5c03f1e7fbef056167364e6782f9ff4f;/MULTISIG_WALLET_ADDRESS \= 0xa22AB8A9D641CE77e06D98b7D7065d324D3d6976;/" GimliCrowdsale.sol`
# `perl -pi -e "s/START_DATE = 1505736000;.*$/START_DATE \= $STARTTIME; \/\/ $STARTTIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/END_DATE = 1508500800;.*$/END_DATE \= $ENDTIME; \/\/ $ENDTIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/VESTING_1_DATE = 1537272000;.*$/VESTING_1_DATE \= $VESTING1TIME; \/\/ $VESTING1TIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/VESTING_2_DATE = 1568808000;.*$/VESTING_2_DATE \= $VESTING2TIME; \/\/ $VESTING2TIME_S/" GimliCrowdsale.sol`

DIFFS1=`diff $SOURCEDIR/$REGISTRYSOL $REGISTRYSOL`
echo "--- Differences $SOURCEDIR/$REGISTRYSOL $REGISTRYSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc --version | tee -a $TEST1OUTPUT

echo "var registryOutput=`solc --optimize --combined-json abi,bin,interface $REGISTRYSOL`;" > $REGISTRYJS
echo "var tokenOutput=`solc --optimize --combined-json abi,bin,interface $TOKENSOL`;" > $TOKENJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$REGISTRYJS");
loadScript("$TOKENJS");
loadScript("functions.js");

var registryAbi = JSON.parse(registryOutput.contracts["$REGISTRYSOL:DeveryRegistry"].abi);
var registryBin = "0x" + registryOutput.contracts["$REGISTRYSOL:DeveryRegistry"].bin;
var tokenAbi = JSON.parse(tokenOutput.contracts["$TOKENSOL:TestEVEToken"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$TOKENSOL:TestEVEToken"].bin;

// console.log("DATA: registryAbi=" + JSON.stringify(registryAbi));
// console.log("DATA: registryBin=" + JSON.stringify(registryBin));
// console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: tokenBin=" + JSON.stringify(tokenBin));


unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployRegistryMessage = "Deploy Registry Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + deployRegistryMessage);
var registryContract = web3.eth.contract(registryAbi);
var registryTx = null;
var registryAddress = null;

var registry = registryContract.new({from: contractOwnerAccount, data: registryBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        registryTx = contract.transactionHash;
      } else {
        registryAddress = contract.address;
        addAccount(registryAddress, "Devery Registry");
        addRegistryContractAddressAndAbi(registryAddress, registryAbi);
        console.log("DATA: registryAddress=" + registryAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("registryAddress=" + registryAddress, registryTx);
printBalances();
failIfTxStatusError(registryTx, deployRegistryMessage);
printRegistryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var tokenMessage = "Deploy Registry Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
var tokenContract = web3.eth.contract(tokenAbi);
var tokenTx = null;
var tokenAddress = null;

var token = tokenContract.new({from: contractOwnerAccount, data: tokenBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("tokenAddress=" + tokenAddress, tokenTx);
printBalances();
failIfTxStatusError(tokenTx, tokenMessage);
printRegistryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var registerAppsMessage = "Register App Accounts";
// -----------------------------------------------------------------------------
console.log("RESULT: " + registerAppsMessage);
var registerApps1Tx = registry.addApp("Bevery", beveryFeeAccount, {from: beveryAppAccount, gas: 500000, gasPrice: defaultGasPrice});
var registerApps2Tx = registry.addApp("Mevery", meveryFeeAccount, {from: meveryAppAccount, gas: 500000, gasPrice: defaultGasPrice});
var registerApps3Tx = registry.addApp("Zevery", zeveryFeeAccount, {from: zeveryAppAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printTxData("registerApps1Tx", registerApps1Tx);
printTxData("registerApps2Tx", registerApps2Tx);
printTxData("registerApps3Tx", registerApps3Tx);
printBalances();
failIfTxStatusError(registerApps1Tx, registerAppsMessage + " - Bevery");
failIfTxStatusError(registerApps2Tx, registerAppsMessage + " - Mevery");
failIfTxStatusError(registerApps3Tx, registerAppsMessage + " - Zevery");
printRegistryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var registerBrandsMessage = "Register Brand Accounts";
// -----------------------------------------------------------------------------
console.log("RESULT: " + registerBrandsMessage);
var registerBrands1Tx = registry.addBrand(beveryBrand1Account, "Bevery Brand 1", {from: beveryAppAccount, gas: 500000, gasPrice: defaultGasPrice});
var registerBrands2Tx = registry.addBrand(beveryBrand2Account, "Bevery Brand 2", {from: beveryAppAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printTxData("registerBrands1Tx", registerBrands1Tx);
printTxData("registerBrands2Tx", registerBrands2Tx);
printBalances();
failIfTxStatusError(registerBrands1Tx, registerBrandsMessage + " - Bevery Brand 1");
failIfTxStatusError(registerBrands2Tx, registerBrandsMessage + " - Bevery Brand 2");
printRegistryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var registerProductsMessage = "Register Brand Accounts";
// -----------------------------------------------------------------------------
console.log("RESULT: " + registerProductsMessage);
var registerProducts1Tx = registry.addProduct(beveryBrand1ProductAAccount, "Bevery Brand 1 Product A", "eeeeks", 2016, "AU", {from: beveryBrand1Account, gas: 500000, gasPrice: defaultGasPrice});
var registerProducts2Tx = registry.addProduct(beveryBrand1ProductBAccount, "Bevery Brand 1 Product B", "yiikes", 2017, "AU", {from: beveryBrand1Account, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printTxData("registerProducts1Tx", registerProducts1Tx);
printTxData("registerProducts2Tx", registerProducts2Tx);
printBalances();
failIfTxStatusError(registerProducts1Tx, registerProductsMessage + " - Bevery Brand 1 Product A");
failIfTxStatusError(registerProducts2Tx, registerProductsMessage + " - Bevery Brand 1 Product B");
printRegistryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var permissionMarkersMessage = "Permission Marker For Brands";
// -----------------------------------------------------------------------------
console.log("RESULT: " + permissionMarkersMessage);
var permissionMarkers1Tx = registry.permissionMarker(beveryMarker1Account, true, {from: beveryBrand1Account, gas: 500000, gasPrice: defaultGasPrice});
var permissionMarkers2Tx = registry.permissionMarker(beveryMarker2Account, true, {from: beveryBrand1Account, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printTxData("permissionMarkers1Tx", permissionMarkers1Tx);
printTxData("permissionMarkers2Tx", permissionMarkers2Tx);
printBalances();
failIfTxStatusError(permissionMarkers1Tx, permissionMarkersMessage + " - Permission Bevery Marker 1");
failIfTxStatusError(permissionMarkers2Tx, permissionMarkersMessage + " - Permission Bevery Marker 2");
printRegistryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var markItemsMessage = "Mark Items";
// -----------------------------------------------------------------------------
console.log("RESULT: " + markItemsMessage);
var markItems1Tx = registry.mark(beveryBrand1ProductAAccount, registry.addressHash(beveryBrand1ProductAItem1Account), {from: beveryMarker1Account, gas: 500000, gasPrice: defaultGasPrice});
var markItems2Tx = registry.mark(beveryBrand1ProductBAccount, registry.addressHash(beveryBrand1ProductBItem2Account), {from: beveryMarker2Account, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printTxData("markItems1Tx", markItems1Tx);
printTxData("markItems2Tx", markItems2Tx);
printBalances();
failIfTxStatusError(markItems1Tx, markItemsMessage + " - Mark Bevery Brand 1 Product A Item 1");
failIfTxStatusError(markItems2Tx, markItemsMessage + " - Mark Bevery Brand 1 Product A Item 2");
printRegistryContractDetails();
console.log("RESULT: ");

var result1 = registry.check(beveryBrand1ProductAItem1Account);
console.log("RESULT: Checking Bevery Brand 1 Product A Item 1: " + beveryBrand1ProductAItem1Account + " productAccount=" + result1[0] + " brandAccount=" + result1[1] + " appAccount=" + result1[2]);
var product1 = registry.products(result1[0]);
console.log("RESULT:   productDetails: " + JSON.stringify(product1));
var result2 = registry.check(beveryBrand1ProductBItem2Account);
console.log("RESULT: Checking Bevery Brand 1 Product A Item 2: " + beveryBrand1ProductBItem2Account + " productAccount=" + result2[0] + " brandAccount=" + result2[1] + " appAccount=" + result2[2]);
var product2 = registry.products(result2[0]);
console.log("RESULT:   productDetails: " + JSON.stringify(product2));
var result3 = registry.check(account3);
console.log("RESULT: Checking Invalid Item: " + account3 + " productAccount=" + result3[0] + " brandAccount=" + result3[2] + " appAccount=" + result3[2]);


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
