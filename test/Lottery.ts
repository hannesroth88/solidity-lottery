import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Lottery", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploy() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy();

    return { lottery: lottery, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { lottery: lottery, owner } = await loadFixture(deploy);

      expect(await lottery.owner()).to.equal(owner.address);
    });
  });

  /*     describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { lottery: lock, unlockTime, lockedAmount } = await loadFixture(deploy);

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).to.emit(lock, "Withdrawal").withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
      });
    });
 */
  /*     describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { lottery: lock, unlockTime, lockedAmount, owner } = await loadFixture(deploy);

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).to.changeEtherBalances([owner, lock], [lockedAmount, -lockedAmount]);
      });
    });
  }); */
});
