import { ethers, run, network } from "hardhat";

async function main() {
  console.log(`start deploying the contract`);
  const Lottery = await ethers.getContractFactory("Lottery");
  const lottery = await Lottery.deploy();

  await lottery.deployed();
  console.log(`Deployed contract to: ${lottery.address}`);
  // what happens when we deploy to our hardhat network?
  if (network.config.chainId === 5 && process.env.ETHERSCAN_API_KEY) {
    console.log("Waiting for 6 block confirmations...");
    //wait for 6 Block confirmations
    await lottery.deployTransaction.wait(6);
    await verify(lottery.address, []);
  }

  console.log(`Contract deployed`);
}

const verify = async (contractAddress: any, args: never[]) => {
  console.log("Verifying contract...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (e: any) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already Verified!");
    } else {
      console.log(e);
    }
  }
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
