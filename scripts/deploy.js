async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  const ConsensusScore = await ethers.getContractFactory('ConsensusScore');
  const consensusScore = await ConsensusScore.deploy();

  console.log('Token address:', consensusScore.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
