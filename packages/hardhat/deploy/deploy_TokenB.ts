import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys a contract named "TokenB" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployTokenB: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {

  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("TokenB", {
    from: deployer,
    // Contract constructor arguments
    args: [deployer],
    log: true,
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  const tokenB = await hre.ethers.getContract<Contract>("TokenB", deployer);
  console.log("🎇 TokenB deployed to: ", await tokenB.getAddress());
  const tokenSymbol = await tokenB.symbol();
  console.log("💹 Token symbol:", tokenSymbol);
  const tokenOwner = await tokenB.owner();
  console.log("👤 Contract owner address:", tokenOwner);
};

export default deployTokenB;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployTokenB.tags = ["TokenB"];
