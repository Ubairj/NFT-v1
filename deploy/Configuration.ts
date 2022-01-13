import 'hardhat-deploy-ethers';

import nextgemDeployer from '../src/deploy/nextgem/deployer';

export default async function func(hre: any) {



  console.log('\n\nNextgem - post-deploy configuration\n');

  const owner = await hre.ethers.getSigner();
  const ownerAddress = await owner.getAddress();

  const getContractAt = hre.ethers.getContractAt;
  const get = hre.deployments.get;
  const deploy = hre.deployments.deploy;

  console.log('loading deployers')

  // const {
  //   bank,
  //   mintingManager,
  //   mintingRegistry,
  //   permissionManager,
  //   dataManager,
  //   requirementsManager,
  //   multiToken,
  //   serviceRegistry,
  //   randomFarmer,
  //   feeManager,
  //   tokenCollectionFactory,
  //   gemPoolFactory,
  //   stakingPoolFactory,
  //   mutationPoolFactory,
  //   mintToken,
  //   createGemPool,
  //   fundMinterBalance
  // } = await nextgemDeployer(hre);

  // get the metadata manager dpeloyer
  const bankDeployer = await getContractAt(
    'BankDeployer',
    ( await get('BankDeployer') ).address,
    owner
  )

  // get the minting manager dpeloyer
  const mintingManagerDeployer = await getContractAt(
    'MintingManagerDeployer',
    ( await get('MintingManagerDeployer') ).address,
    owner
  )

  // get the minting manager dpeloyer
  const mintingRegistryDeployer = await getContractAt(
    'MintingRegistryDeployer',
    ( await get('MintingRegistryDeployer') ).address,
    owner
  )

  // get thenetwork bridge  dpeloyer
  const networkBridgeDeployer = await getContractAt(
    'NetworkBridgeDeployer',
    ( await get('NetworkBridgeDeployer') ).address,
    owner
  )

  // get the permissoin manager dpeloyer
  const permissionManagerDeployer = await getContractAt(
    'PermissionManagerDeployer',
    ( await get('PermissionManagerDeployer') ).address,
    owner
  )

  // get the on chain data manager dpeloyer
  const dataManagerDeployer = await getContractAt(
    'DataManagerDeployer',
    ( await get('DataManagerDeployer') ).address,
    owner
  )

  // get the multitoken dpeloyer
  const multiTokenDeployer = await getContractAt(
    'MultiTokenDeployer',
    ( await get('MultiTokenDeployer') ).address,
    owner
  )

  // get the multitoken dpeloyer
  const requirementsManagerDeployer = await getContractAt(
    'RequirementsManagerDeployer',
    ( await get('RequirementsManagerDeployer') ).address,
    owner
  )

  // get the multitoken dpeloyer
  const serviceRegistryDeployer = await getContractAt(
    'ServiceRegistryDeployer',
    ( await get('ServiceRegistryDeployer') ).address,
    owner
  )

  // get the multitoken dpeloyer
  const feeManagerDeployer = await getContractAt(
    'FeeManagerDeployer',
    ( await get('FeeManagerDeployer') ).address,
    owner
  )

  // get the multitoken dpeloyer
  const randomFarmerDeployer = await getContractAt(
    'RandomFarmerDeployer',
    ( await get('RandomFarmerDeployer') ).address,
    owner
  )

  // get the multitoken dpeloyer
  const tokenCollectionFactoryDeployer = await getContractAt(
    'TokenCollectionFactoryDeployer',
    ( await get('TokenCollectionFactoryDeployer') ).address,
    owner
  )

  // get the multitoken dpeloyer
  const gemPoolFactoryDeployer = await getContractAt(
    'GemPoolFactoryDeployer',
    ( await get('GemPoolFactoryDeployer') ).address,
    owner
  )

  // get the multitoken dpeloyer
  const stakingPoolFactoryDeployer = await getContractAt(
    'StakingPoolFactoryDeployer',
    ( await get('StakingPoolFactoryDeployer') ).address,
    owner
  )

  // get the multitoken dpeloyer
  const mutationPoolFactoryDeployer = await getContractAt(
    'MutationPoolFactoryDeployer',
    ( await get('MutationPoolFactoryDeployer') ).address,
    owner
  )


  console.log('getting deployed contract addresses')

  // get addresses for all the contracts
  let [
    bank,
    mintingManager,
    mintingRegistry,
    networkBridge,
    permissionManager,
    dataManager,
    requirementsManager,
    multiToken,
    serviceRegistry,
    feeManager,
    randomFarmer,
    tokenCollectionFactory,
    gemPoolFactory,
    stakingPoolFactory,
    mutationPoolFactory,
    ] = await Promise.all([
    bankDeployer.deployedToken(),
    mintingManagerDeployer.deployedToken(),
    mintingRegistryDeployer.deployedToken(),
    networkBridgeDeployer.deployedToken(),
    permissionManagerDeployer.deployedToken(),
    dataManagerDeployer.deployedToken(),
    requirementsManagerDeployer.deployedToken(),
    multiTokenDeployer.deployedToken(),
    serviceRegistryDeployer.deployedToken(),
    feeManagerDeployer.deployedToken(),
    randomFarmerDeployer.deployedToken(),
    tokenCollectionFactoryDeployer.deployedToken(),
    gemPoolFactoryDeployer.deployedToken(),
    stakingPoolFactoryDeployer.deployedToken(),
    mutationPoolFactoryDeployer.deployedToken(),
    ]);

  console.log('loading contracts')

  // get the metadata manager
  bank = await getContractAt(
    'NextgemBank',
    bank,
    owner
  )

  // get the minting manager
  mintingManager = await getContractAt(
    'MintingManager',
    mintingManager,
    owner
  )

  // get the metadata manager
  requirementsManager = await getContractAt(
    'RequirementsManager',
    requirementsManager,
    owner
  )

  // get the minting manager
  mintingRegistry = await getContractAt(
    'MintingRegistry',
    mintingRegistry,
    owner
  )

  // get the network bridge
  networkBridge = await getContractAt(
    'NextgemNetworkBridge',
    networkBridge,
    owner
  )

  // get the permission manager
  permissionManager = await getContractAt(
    'PermissionManager',
    permissionManager,
    owner
  )

  // get the multitoken dpeloyer
  dataManager = await getContractAt(
    'DataManager',
    dataManager,
    owner
  )

  // get the multitoken dpeloyer
  multiToken = await getContractAt(
    'MultiToken',
    multiToken,
    owner
  )

  // get the multitoken dpeloyer
  randomFarmer = await getContractAt(
    'RandomFarmer',
    randomFarmer,
    owner
  )

  // get the multitoken dpeloyer
  feeManager = await getContractAt(
    'NextgemFeeManager',
    feeManager,
    owner
  )

  // get the multitoken dpeloyer
  serviceRegistry = await getContractAt(
    'ServiceRegistry',
    serviceRegistry,
    owner
  )

  // get the multitoken dpeloyer
  tokenCollectionFactory = await getContractAt(
    'TokenCollectionFactory',
    tokenCollectionFactory,
    owner
  )

  // get the multitoken dpeloyer
  gemPoolFactory = await getContractAt(
    'GemPoolFactory',
    gemPoolFactory,
    owner
  )

  // get the multitoken dpeloyer
  stakingPoolFactory = await getContractAt(
    'StakingPoolFactory',
    stakingPoolFactory,
    owner
  )

  // get the multitoken dpeloyer
  mutationPoolFactory = await getContractAt(
    'MutationPoolFactory',
    mutationPoolFactory,
    owner
  )

  // deploy the service registry first - it lets other contracts know how to find services
  console.log('initializing service registry');
  const tx = await serviceRegistry.initialize(owner.address);
  await tx.wait();

  // update service registry
  const updateManager = async (f: any, n: any, v: any) => {
    const tx = await serviceRegistry.setServiceNamed(f, n, v)
    await tx.wait();
    console.log(`Added service named ${n} with address ${v} to registry`);
    return tx;
  }

  console.log('adding services to registry');

  // add all the services to the registry
  await updateManager("", 'Bank', bank.address);
  await updateManager("", 'DataManager', dataManager.address);
  await updateManager("", 'MintingManager', mintingManager.address);
  await updateManager("", 'RequirementsManager', requirementsManager.address);
  await updateManager("", 'MintingRegistry', mintingRegistry.address);
  //await updateManager("", 'NetworkBridge', networkBridge.address);
  await updateManager("", 'PermissionManager', permissionManager.address);
  await updateManager("", 'MultiToken', multiToken.address);
  await updateManager("", 'FeeManager', feeManager.address);
  await updateManager("", 'RandomFarmer', randomFarmer.address);
  await updateManager("", 'TokenCollectionFactory', tokenCollectionFactory.address);
  await updateManager("", 'GemPoolFactory', gemPoolFactory.address);
  await updateManager("", 'StakingPoolFactory', stakingPoolFactory.address);
  await updateManager("", 'MutationPoolFactory', mutationPoolFactory.address);

  await updateManager("", 'FeeReceiver', ownerAddress);
  await updateManager("", 'RoyaltyPayee', ownerAddress);

  const initialize = async (name: string, contract: any, serviceRegistry: any) => {
    console.log(`initializing ${name} with service registry`);
    const tx = await contract.initialize(serviceRegistry.address);
    await tx.wait();
  };

  // add all the services to the registry
  await initialize('bank', bank, serviceRegistry);
  await initialize('data manager', dataManager, serviceRegistry);
  await initialize('minting manager', mintingManager, serviceRegistry);
  await initialize('requirements manager', requirementsManager, serviceRegistry);
  await initialize('minting registry', mintingRegistry, serviceRegistry);
  //await initialize('network bridge', networkBridge, serviceRegistry);
  await initialize('permission manager', permissionManager, serviceRegistry);
  await initialize('multitoken', multiToken, serviceRegistry);
  await initialize('fee manager', feeManager, serviceRegistry);
  await initialize('random farmer', randomFarmer, serviceRegistry);
  await initialize('token collection factory', tokenCollectionFactory, serviceRegistry);
  await initialize('gem pool factory', gemPoolFactory, serviceRegistry);
  await initialize('staking pool factory', stakingPoolFactory, serviceRegistry);
  await initialize('mutation pool factory', mutationPoolFactory, serviceRegistry);


};

func.tags = ['Configuration'];
func.dependencies = [
  'Bank',
  'MintingManager',
  'MintingRegistry',
  'MultiToken',
  'NetworkBridge',
  'PermissionManager',
  'ServiceRegistry',
  'DataManager',
  'RandomFarmer',
  'FeeManager',
  'TokenCollectionFactory',
  'StakingPoolFactory',
  'GemPoolFactory',
  'MutationPoolFactory',
  'RequirementsManager'
];
