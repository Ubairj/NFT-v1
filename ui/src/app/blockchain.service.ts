import {Injectable} from '@angular/core';
/* eslint-disable @typescript-eslint/no-var-requires */
import {Moralis} from 'moralis';
import {ToastrService} from 'ngx-toastr';
import {ethers, BigNumber, Contract, providers} from 'ethers';
import {Network} from '@ethersproject/networks';
import {pack, keccak256} from '@ethersproject/solidity';
import swal from 'sweetalert2';
import { environment } from 'src/environments/environment';

const networks: {
  name: {[id: string]: string};
  coin: {[id: string]: string};
} = {
  name: {
    '1': 'Ethereum',
    '3': 'ropsten',
    '4': 'rinkeby',
    '5': 'goerli',
    '42': 'kovan',
    '56': 'Binance',
    '77': 'sokol',
    '97': 'bsc-testnet',
    '99': 'POA',
    '250': 'Opera',
    '1337': 'local',
    '4002': 'ftmtest',
    '43113': 'fuji',
    '43114': 'Avalanche'
  },
  coin: {
    '1': 'ETH',
    '3': 'rETH',
    '4': 'rETH',
    '5': 'kETH',
    '42': 'kETH',
    '56': 'BNB',
    '77': 'sPOS',
    '97': 'tBNB',
    '99': 'POA',
    '250': 'FTM',
    '1337': 'lETH',
    '4002': 'tFTM',
    '43113': 'tAVAX',
    '43114': 'AVAX'
  }
};

@Injectable({
  providedIn: 'root'
})
export class BlockchainService {
  ethers: providers.Web3Provider | undefined;
  provider: providers.Web3Provider | null = null;
  account: string | undefined;
  signer: providers.JsonRpcSigner | undefined;
  network: Network | null = null;
  networkId = 0;
  user: Moralis.User | undefined;

  currentTokenHash = 1;

  tokenSale: any;
  token: any;

  contractData: any;
  public connected = false;
  public isLoading = false;

  constructor(public toastr: ToastrService) {
    this.connectAccount = this.connectAccount.bind(this);
    this.reloadAccount = this.reloadAccount.bind(this);
    this.resetApp = this.resetApp.bind(this);
  }

  networkName(): string {
    const nid = this.networkId + '';
    return networks.name[nid];
  }

  COIN(): string {
    const nid = this.networkId + '';
    return this.networkId ? networks.coin[nid] : '???';
  }

  async login(user: Moralis.User): Promise<void> {
    this.user = user;
    this.account = this.user.attributes['ethAddress'];
    await this.connectAccount();
  }

  async connectAccount(): Promise<void> {
    this.resetApp();
    await Moralis.enableWeb3();
    if (Moralis.provider) {
      this.provider = new providers.Web3Provider((Moralis as any).provider);
      await this.subscribeProvider();
      await this.setupAccount();
    }
  }

  async reloadAccount(): Promise<void> {
    const externalProvider: any = (await Moralis.Web3.enable()).currentProvider;
    this.provider = new providers.Web3Provider(externalProvider);
    await this.subscribeProvider();
    await this.setupAccount();
  }

  resetApp(): void {
    if (this.provider) {
      this.provider = null;
    }
  }

  async subscribeProvider(): Promise<void> {
    const provider = this.provider;
    if (!provider || provider === null || !provider.on) {
      return;
    }
    provider.on('close', async () => this.resetApp());
    provider.on('accountsChanged', async (accounts: string[]) => {
      console.log('accountsChanged', accounts);
      return await this.reloadAccount();
    });
    provider.on('chainChanged', async (chainId: number) => {
      console.log('chainChanged', chainId);
      return await this.reloadAccount();
    });

    provider.on('networkChanged', async (networkId: number) => {
      console.log('networkChanged', networkId);
      this.networkId = networkId;
      return await this.reloadAccount();
    });
    this.signer = provider.getSigner();
    const [account, network] = await Promise.all([
      this.signer?.getAddress(),
      this.provider?.getNetwork()
    ]);
    if (account) {
      this.account = account;
    }
    if (network) {
      this.network = network;
      this.networkId = this.network?.chainId;
    }
  }

  /**
   * perform initial setup - load contracts, query moralis, etc.
   */
  async setupAccount(): Promise<void> {
    // shown if network is invalid
    const invalidNetwork = () => {
      swal.fire({
        title: 'Wrong Network',
        text:
          'Bitgem is not deployed on your selected network. Please select a supported network in Metamask and try again.',
        buttonsStyling: false,
        customClass: {
          confirmButton: 'btn btn-info retro-confirm'
        }
      });
    };

    // display a loading message
    this.showSidebarMessage(
      'Please wait while your token information is loaded.'
    );

    const tokenSaleAbi = [
      "event PayeeChanged(address indexed)",
      "event Purchased(address indexed,uint256,uint256,uint256)",
      "event TokenMinted(address indexed,uint256,uint256)",
      "function addTokenType(tuple(uint256,uint256,uint256,uint256,bool))",
      "function getOpenState(uint256) view returns (bool)",
      "function getPayee() view returns (address)",
      "function getSalePrice(uint256) view returns (uint256)",
      "function getSaleTokens() view returns (address[])",
      "function getTokenType(uint256) view returns (tuple(uint256,uint256,uint256,uint256,bool))",
      "function mint(uint256,address,uint256)",
      "function minterList() view returns (tuple(address,uint256,uint256)[])",
      "function purchase(uint256,address,uint256) payable returns (tuple(address,uint256,uint256))",
      "function purchaserList() view returns (tuple(address,uint256,uint256)[])",
      "function salePrice(uint256,uint256) view returns (uint256)",
      "function setOpenState(uint256,bool)",
      "function setPayee(address)",
      "function setSalePrice(uint256) view"
    ];
    const tokenAbi = [
      "event ApprovalForAll(address indexed,address indexed,bool)",
      "event TransferBatch(address indexed,address indexed,address indexed,uint256[],uint256[])",
      "event TransferSingle(address indexed,address indexed,address indexed,uint256,uint256)",
      "event URI(string,uint256 indexed)",
      "function balanceOf(address,uint256) view returns (uint256)",
      "function balanceOfBatch(address[],uint256[]) view returns (uint256[])",
      "function isApprovedForAll(address,address) view returns (bool)",
      "function safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)",
      "function safeTransferFrom(address,address,uint256,uint256,bytes)",
      "function setApprovalForAll(address,bool)",
      "function supportsInterface(bytes4) view returns (bool)"
    ];

    try {
      // get the contracts
      const [token, tokenSale] = await Promise.all([
        this.getContractRef(tokenAbi, environment.token),
        this.getContractRef(tokenSaleAbi, environment.tokenSale)
      ]);

      // the primary bitgem multitoken
      this.token = token;

      // the bitgem pool factory
      this.tokenSale = tokenSale;

      // token minted event
      this.tokenSale.on('TokenMinted', (minter: string, hash: any, quantity: any) => {
        if(!this.account || !BigNumber.from(minter).eq(this.account)) {
          return;
        }
        this.showSidebarMessage(
          'You have received a new token!'
        );
      })

    } catch (e) {
      invalidNetwork();
    }

  }

  /**
   * load a contract given its details.
   */
  async getContractRef(
    abi: any,
    address: string,
  ): Promise<Contract> {
    const __contract = new Contract( // this could be cached
      address,
      abi,
      this.signer
    );
    return __contract;
  }

  /**
   * show a toast message
   * @param title
   * @param body
   */
  showToast(title: string, body: string): void {
    //console.log(title, body);
    this.showSidebarMessage(body);
  }

  /**
   * show a sidebar message
   * @param message
   * @param classes
   */
  showSidebarMessage(message: string, classes?: string): void {
    if (!classes) classes = 'toast-info2 ';
    this.toastr.show(``, message, {
      timeOut: 4000,
      closeButton: true,
      enableHtml: true,
      toastClass: `ngx-toastr ${classes}`,
      positionClass: 'toast-top-right',
    });
  }

  async purchaseTokens(quantity: number): Promise<void> {

    this.showSidebarMessage('Please wait while your purchase is being processed.');

    // get the price of tokens to purchase from the contract
    const price = await this.tokenSale.salePrice(environment.currentTokenHash, quantity);
    // get the amount of ether to send to the contract
    const amount = price.mul(quantity);

    // send the transaction
    const tx = await this.tokenSale.purchase(environment.currentTokenHash, this.account, quantity, {
      value: amount
    });

  }

}
