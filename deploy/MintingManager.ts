import 'hardhat-deploy-ethers';

/**
 * minting manager
 * @param hre
 */
export default async function func(hre: any) {

  const BigNumber = hre.ethers.BigNumber;
  const getContractAt = hre.ethers.getContractAt;
  const get = hre.deployments.get;
  const deploy = hre.deployments.deploy;

  console.log('\n\nNextgem - minting manager deploy\n');

  const owner = await hre.ethers.getSigner();
  const ownerAddress = await owner.getAddress();

  // deployment params
  const libDeployParams = {
    from: ownerAddress,
    log: true,
    args: [
    ]
  };

  // deploy the deployer
  const addressSet = await deploy(
    'AddressSet',
    libDeployParams
  );
  const uint256Set = await deploy(
    'UInt256Set',
    libDeployParams
  );

  // deployment params
  const deployParams = {
    from: ownerAddress,
    log: true,
    libraries: {
      AddressSet: addressSet.address,
      UInt256Set: uint256Set.address,
    },
    args: []
  };

  // deploy the contract
  await deploy('MintingManagerDeployer', deployParams);

  // get the dpeloyer
  let deployer = await getContractAt(
    'MintingManagerDeployer',
    ( await get('MintingManagerDeployer') ).address,
    owner
  )

  // call the deployer to deploy the token
  let tx = await deployer.deploy(
    '0', BigNumber.from('1')
  );
  await tx.wait();

  // call the deployment address
  const deployedAddress = await deployer.deployedToken();
  if (!deployedAddress) {
    throw new Error('could not deploy the contract');
  }

};
func.tags = ['MintingManager'];
