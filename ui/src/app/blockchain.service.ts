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
    const externalProvider: any = (await Moralis.Web3.enable()).currentProvider;
    if (externalProvider) {
      this.provider = new providers.Web3Provider(externalProvider);
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

    try {
      this.contractData = await import(`../../abis/${this.networkId}/abis.json`);
    } catch (e) {
      this.isLoading = false;
      return invalidNetwork();
    }

    const [token, tokenSale] = await Promise.all([
      this.getContractRef('MultiToken'),
      this.getContractRef('TokenSale')
    ]);

    // the primary bitgem multitoken
    this.token = token;

    // the bitgem pool factory
    this.tokenSale = tokenSale;
  }

  /**
   * load a contract given its details.
   */
  async getContractRef(
    contract: string,
    address?: string,
    version?: number
  ): Promise<Contract> {
    version = version === undefined ? this.contractData.length - 1 : version;
    const tokenData = await require(`../../../abis/${contract}.json`);
    if (!tokenData.abi) throw new Error(`abi not found for ${contract}`);
    tokenData.__contract = new Contract( // this could be cached
      address ? address : tokenData.address,
      tokenData.abi,
      this.signer
    );
    return tokenData.__contract;
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

  async purchaseTokens(): Promise<void> {

    // currently-sold token hash
    const currentToken = environment.token;

    this.showSidebarMessage('Please wait while your purchase is being processed.');
    // get quantity of tokens to purchase from input
    const quantity = parseInt(
      (document.getElementById('quantity') as HTMLInputElement).value,
      10
    );

    // get the price of tokens to purchase from the contract
    const price = await this.tokenSale.salePrice(currentToken);
    // get the amount of ether to send to the contract
    const amount = price.mul(quantity);

    // send the transaction
    const tx = await this.tokenSale.purchaseTokens(currentToken, quantity, {
      value: amount
    });

  }

}
