import 'hardhat-deploy-ethers';

export default async function func(hre: any) {

  const BigNumber = hre.ethers.BigNumber;
  const ethers = hre.ethers;
  const deployments = hre.deployments;
  const getContractAt = hre.ethers.getContractAt;
  const get = hre.deployments.get;
  const d = hre.deployments.deploy;
  const deploy = hre.deployments.deploy;

  console.log('\n\nNextgem - requirements manager deploy\n');

  const owner = await hre.ethers.getSigner();
  const ownerAddress = await owner.getAddress();

  // deployment params
  const libDeployParams = {
    from: ownerAddress,
    log: true,
    args: [
    ]
  };

  // deploy the address set
  const addressSet = await deploy(
    'AddressSet',
    libDeployParams
  );
  // dpeloy the uint set
  const uint256Set = await deploy(
    'UInt256Set',
    libDeployParams
  );

  const tokenSet = await deploy(
    'TokenSet',
    libDeployParams
  );

  const reqLibDeployParams = {
    from: ownerAddress,
    log: true,
    libraries: {
      UInt256Set: uint256Set.address,
      TokenSet: tokenSet.address
    }
  };
  const requirementLib = await deploy(
    'RequirementLib',
    reqLibDeployParams
  );

  // deployment params
  const deployParams = {
    from: ownerAddress,
    log: true,
    libraries: {
      AddressSet: addressSet.address,
      UInt256Set: uint256Set.address,
      RequirementLib: requirementLib.address,
    },
    args: []
  };

  // deploy the contract
  await deploy('RequirementsManagerDeployer', deployParams);

  // get the dpeloyer
  let deployer = await getContractAt(
    'RequirementsManagerDeployer',
    ( await get('RequirementsManagerDeployer') ).address,
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
func.tags = ['RequirementsManager'];
