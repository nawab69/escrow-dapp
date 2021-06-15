const BscEscrow = artifacts.require("BscEscrow");
const Busd = artifacts.require("Busd");

module.exports = async function(deployer, network, accounts) {
  // deploy mock BUSD token for development perpose
  await deployer.deploy(Busd, "1000000000000000000000000000000000");
  const BUSD = await Busd.deployed();

  // deploy ETH smart contract
  await deployer.deploy(BscEscrow, BUSD.address);
};
