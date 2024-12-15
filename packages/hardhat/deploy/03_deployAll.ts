import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

//The only way to successfully deploy the SimpleDEX contract in my PC was by creating a combined deployment script along with the token deployment scripts. 

const deploySimpleDexProject: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, get } = hre.deployments;
  // Deploy TokenA
  const tokenADeployment = await deploy("TokenA", {
    from: deployer,
    args: [deployer],
    log: true,
    autoMine: true,
  });
  console.log(`🎇 TokenA deployed at ${tokenADeployment.address}`);

  // Deploy TokenB
  const tokenBDeployment = await deploy("TokenB", {
    from: deployer,
    args: [deployer],
    log: true,
    autoMine: true,
  });
  console.log(`🎇 TokenB deployed at ${tokenBDeployment.address}`);

  // Deploy SimpleDEX with TokenA and TokenB addresses
  const simpleDexDeployment = await deploy("SimpleDex", {
    from: deployer,
    args: [tokenADeployment.address, tokenBDeployment.address],
    log: true,
    autoMine: true,
  });
  console.log(`🎇SimpleDex deployed at ${simpleDexDeployment.address}`);
};

export default deploySimpleDexProject;

deploySimpleDexProject.tags = ["SimpleDexProject"];