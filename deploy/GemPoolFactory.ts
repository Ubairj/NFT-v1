import 'hardhat-deploy-ethers';

export default async function func(hre: any) {

  const BigNumber = hre.ethers.BigNumber;
  const getContractAt = hre.ethers.getContractAt;
  const get = hre.deployments.get;
  const deploy = hre.deployments.deploy;

  console.log('\n\nNextgem - gem pool factory deploy\n');

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
  const factorySet = await deploy(
    'FactorySet',
    libDeployParams
  );
  const claimsSet = await deploy(
    'ClaimsSet',
    libDeployParams
  );
  const claimLibDeployParams = {
    from: ownerAddress,
    log: true,
    libraries: {
      ClaimsSet: claimsSet.address
    }
  };
  const claimLib = await deploy(
    'ClaimLib',
    claimLibDeployParams
  );
  const gemPoolLib = await deploy(
    'GemPoolLib',
    libDeployParams
  );


  // deployment params
  const deployParams = {
    from: ownerAddress,
    log: true,
    libraries: {
      AddressSet: addressSet.address,
      UInt256Set: uint256Set.address,
      FactorySet: factorySet.address,
      ClaimsSet: claimsSet.address,
      ClaimLib: claimLib.address,
      GemPoolLib: gemPoolLib.address
    },
    args: []
  };

  // deploy the contract
  await deploy('GemPoolFactoryDeployer', deployParams);

  // deploy the contract
  await deploy('GemPool', deployParams);

  // get the dpeloyer
  const deployer = await getContractAt(
    'GemPoolFactoryDeployer',
    ( await get('GemPoolFactoryDeployer') ).address,
    owner
  )

  // call the deployer to deploy the token
  const tx = await deployer.deploy(
    '0', BigNumber.from('1')
  );
  await tx.wait();

  // call the deployment address
  const deployedAddress = await deployer.deployedToken();
  if (!deployedAddress) {
    throw new Error('could not deploy the contract');
  }

};
func.tags = ['GemPoolFactory'];
