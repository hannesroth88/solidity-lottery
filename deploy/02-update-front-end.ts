const { frontEndContractsFile, frontEndAbiFile } = require("../helper-hardhat-config")
import fs from "fs"
import {DeployFunction} from "hardhat-deploy/types"
import {HardhatRuntimeEnvironment} from "hardhat/types"
import { ethers, network } from "hardhat"

const updateUI: DeployFunction = async function (
    hre: HardhatRuntimeEnvironment
  ) {
    if (process.env.UPDATE_FRONT_END) {
        console.log("Writing to front end...")
        await updateContractAddresses()
        await updateAbi()
        console.log("Front end written!")
    }
}

async function updateAbi() {
    const raffle = await ethers.getContract("Raffle")
    fs.writeFileSync(frontEndAbiFile, raffle.interface.format(ethers.utils.FormatTypes.json).toString())
}

async function updateContractAddresses() {
    const raffle = await ethers.getContract("Raffle")
    const contractAddresses = JSON.parse(fs.readFileSync(frontEndContractsFile, "utf8"))
    if (network.config.chainId && network.config.chainId.toString() in contractAddresses) {
        if (!contractAddresses[network.config.chainId.toString()].includes(raffle.address)) {
            contractAddresses[network.config.chainId.toString()].push(raffle.address)
        }
    } else {
        contractAddresses[network.config.chainId?.toString() ?? "undefined"] = [raffle.address]
    }
    fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddresses))


}
export default updateUI
updateUI.tags = ["all", "frontend"]
