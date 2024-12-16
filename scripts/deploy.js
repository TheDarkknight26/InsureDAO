const { ethers } = require("hardhat");


async function main() {
    const [deployer] = await ethers.getSigners();
    const Governancetoken = await ethers.getContractFactory("Governancetoken");
    const governancetoken = await Governancetoken.deploy();
    console.log("insurance is deploying");
    console.log(`GovernanceToken deployed to: ${governancetoken.target}`);

    
} 

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });