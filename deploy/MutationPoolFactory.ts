import 'hardhat-deploy-ethers';

export default async function func(hre: any) {

  const BigNumber = hre.ethers.BigNumber;
  const getContractAt = hre.ethers.getContractAt;
  const get = hre.deployments.get;
  const deploy = hre.deployments.deploy;

  console.log('\n\nNextgem - mutation pool factory deploy\n');

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
  const mutationPoolLib = await deploy(
    'MutationPoolLib',
    libDeployParams
  );
  const mutationPoolSet = await deploy(
    'MutationPoolSet',
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
      MutationPoolLib: mutationPoolLib.address,
      MutationPoolSet: mutationPoolSet.address
    },
    args: []
  };

  // deploy the contract
  await deploy('MutationPoolFactoryDeployer', deployParams);

  // get the dpeloyer
  const deployer = await getContractAt(
    'MutationPoolFactoryDeployer',
    ( await get('MutationPoolFactoryDeployer') ).address,
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
func.tags = ['MutationPoolFactory'];
