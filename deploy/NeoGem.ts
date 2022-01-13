import 'hardhat-deploy-ethers';

import {BigNumber, Contract} from 'ethers';
import {keccak256, solidityPack} from 'ethers/lib/utils';
import {
  loadAllGemPoolContracts,
  loadPoolDetails
} from '../src/scripts/bitgem/import'

import { getFactorySeries } from '../src/scripts/bitgem/blockchain';

import nextgemDeployer from '../src/deploy/nextgem/deployer';

export default async function func(hre: any) {
  console.log('\nNeogem deploy\n');

  const ethers = hre.ethers;
  const owner = await hre.ethers.getSigner();
  const ownerAddress = await owner.getAddress();

  const getContractAt = hre.ethers.getContractAt;
  const get = hre.deployments.get;

   // fund the minter's balance
   async function fundMinterBalance(ownerAddress: string, deposit ?: string, fee ?: string) {

    // get the minter balance to determine if we need to fund the minting manager
    console.log('getting minting balance');
    const minterBalance = await mintingManager.balance(ownerAddress, 0);

    // fund the minting manager if it not funded
    if (minterBalance.isZero()) {

      deposit = deposit ? deposit : '1';
      console.log(`depositing ${deposit} ether to minting manager`);
      const oneEther = hre.ethers.utils.parseEther(deposit);
      const out = await mintingManager.depositTokens(oneEther, {
        value: oneEther,
      });
      await out.wait();
      //fee = fee ? fee : '0.01';
      //await feeManager.setFee("Mint", hre.ethers.utils.parseEther(fee));
    }

  }

  // mint token with the given token hash and amount. tokens minted to owner
  async function mintToken(tokenHash: string, tokenType: string, amount: number) {

    // get the key token balance
    const tokenBalance = await multiToken.balanceOf(
      ownerAddress,
      tokenHash
    );
    console.log(`token ${tokenHash} balance: ${tokenBalance.toString()}`);

    // if there is no key token balance then mint 1000 tokens
    if (tokenBalance.isZero()) {

      // mint the key token
      const tx = await mintingManager.mint(
        ownerAddress,
        BigNumber.from(ownerAddress),
        tokenHash,
        BigNumber.from(amount));
      await tx.wait();
      await dataManager.setStringData(tokenHash, "TokenType", tokenType);
      console.log(`minted token '${tokenType}' ${tokenHash}: ${amount}`);

    }

  }

  async function createGemPool(gemPoolData: any) {

    // create the gem pool hash from the gem pool address
    const _hash = await gemPoolFactory.collectionHash(gemPoolData);

    // try to retrieve the gem pool, it might be created already
    let coll = await gemPoolFactory.collectionByHash(_hash);

    if(BigNumber.from(coll).isZero()) {

      console.log(`creating gem pool ${gemPoolData} ${_hash}`);

      // create the gem pool
      const tx = await gemPoolFactory.createGemPool(gemPoolData);
      await tx.wait();

      // get the gem pool address
      coll = await gemPoolFactory.collectionByHash(_hash);

    }
    return coll;

  }

  console.log('loading deployment artifacts');


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

  const gpc = await loadAllGemPoolContracts();
  const pro = gpc.map(async (poolContract: any) =>
    loadPoolDetails(poolContract, false)
  );

  // load all the gem pool data
  const poolDetails = await Promise.all(pro);

  // create the gem pool contract
  const gemPoolAddress = await createGemPool("TEST");
  const gemPoolContract = await getContractAt(
    'GemPool',
    gemPoolAddress,
    owner
  )

  // fund the minter balance
  await fundMinterBalance(gemPoolAddress);

  const minterBalance = await mintingManager.balance(ownerAddress, 0);
  console.log('minting balance', minterBalance.toHexString());

  let curFactory: any = BigNumber.from(0), curCollectionId: any;
  for(let i = 0; i < poolDetails.length; i++) {

    // get the pool details
    const pool = poolDetails[i];

    const fs = await getFactorySeries(pool.factory);
    if(!curFactory.eq(pool.factory)) {
      curFactory = pool.factory;
      curCollectionId = keccak256(solidityPack(['string'], [`Bitgem Series ${fs}`]));
    }

    const poolSymbol =  pool.symbol;
    const poolName = pool.name;
    const gemPoolSettings = [
      serviceRegistry.address,
      [
        hre.ethers.constants.Zero,
        hre.ethers.constants.Zero,
        hre.ethers.constants.AddressZero,
      ],
      [
        multiToken.address,
        hre.ethers.constants.Zero,
        curCollectionId,
        poolSymbol + fs,
        poolName + ' series ' + fs,
        `Bitgem Series ${fs} ${poolName} (${poolSymbol})`,
        hre.ethers.constants.Zero,
        1000,
        true,
        hre.ethers.constants.Zero,
        hre.ethers.constants.Zero,
        hre.ethers.constants.Zero
      ],
      [pool.ethPrice, 2, pool.difficultyStep, 0],
      true,
      true,
      pool.minTime,
      pool.maxTime,
      pool.difficultyStep,
      0,
      0,
      0,
      0,
      0,
      false,
      true,
      0,
      false
    ];
    // const gemPoolHash = await gemPoolContract.addGemPool(gemPoolSettings);
    // console.log(`created gem pool ${poolSymbol} ${poolName} with hash ${gemPoolHash} and settings ${gemPoolSettings}`);

  }

}
func.tags = ['NeoGems'];
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
  'RequirementsManager',
  'Configuration'
];
