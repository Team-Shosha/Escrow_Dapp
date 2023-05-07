const hre = require("hardhat");

async function main() {
  
    const Escrow = await hre.ethers.getContractFactory("Escrow");
    const escrow = await Escrow.deploy();
  
    await escrow.deployed();
    console.log(`
    deployed to ${escrow.address}`
  );
  
   
}
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
// hardhat deployed address = 0x5FbDB2315678afecb367f032d93F642f64180aa3
