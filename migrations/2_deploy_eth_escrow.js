const EthEscrow = artifacts.require("EthEscrow");
const Usdt = artifacts.require("Usdt");

module.exports = async function(deployer, network, accounts) {
  // deploy mock USDT token for development perpose
  await deployer.deploy(Usdt, "10000000000000000000");
  const USDT = await Usdt.deployed();

  // deploy ETH smart contract
  await deployer.deploy(EthEscrow, USDT.address);
};
