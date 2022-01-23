import 'hardhat-deploy-ethers';

export default async function func(hre: any) {

  const BigNumber = hre.ethers.BigNumber;
  const ethers = hre.ethers;
  const deployments = hre.deployments;
  const getContractAt = hre.ethers.getContractAt;
  const get = hre.deployments.get;
  const d = hre.deployments.deploy;
  const deploy = hre.deployments.deploy;

  console.log('\n\nNextgem - token sale deploy\n');

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
  await deploy('MultiToken', deployParams);

  // get the dpeloyer
  const multitokenAddress = ( await get('MultiToken') ).address;

  // deploy the token sale
  await deploy('TokenSale', deployParams);

  // get the dpeloyer
  const tokenSale = await getContractAt(
    'TokenSale',
    ( await get('TokenSale') ).address,
    owner
  )

  // init the tokensale
  console.log('init the tokensale contract');
  await tokenSale.initialize(multitokenAddress);

};
func.tags = ['TokenSale'];
