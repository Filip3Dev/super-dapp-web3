// const Register = artifacts.require("Register");
const Raffle = artifacts.require("Raffle");
// const NFT = artifacts.require("NFT");

module.exports = function (deployer) {
  // deployer.deploy(Register);
  deployer.deploy(Raffle);
  // deployer.deploy(NFT);
};
