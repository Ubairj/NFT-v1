import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import Moralis from "moralis";
import { BlockchainService } from 'src/app/blockchain.service';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css']
})
export class HeaderComponent implements OnInit {

  user: Moralis.User | undefined;
  _connected: boolean = false;
  title: string = '';


  constructor(private cdr: ChangeDetectorRef, private blockchainService: BlockchainService) {}

  /**
   * angular init. Start the moralis web3 connection
   */
  ngOnInit() {
    Moralis.start({
      appId: environment.moralis.appId,
      serverUrl: environment.moralis.serverUrl,
    })
      .then(() => console.info('Moralis has been initialised.'))
      .finally(() => {
        if (Moralis.User.current()) this.setLoggedInUser(Moralis.User.current())
      });
  }

  /**
   * set the logged in user
   * @param provider
   */
  login(provider: 'metamask' | 'walletconnect' = 'metamask') {
    (provider === 'metamask'
      ? Moralis.Web3.authenticate()
      : Moralis.Web3.authenticate({ provider }))
          .then((loggedInUser:any) => this.setLoggedInUser(loggedInUser))
          .catch((e:any) => console.error(`Moralis '${provider}' login error:`, e));
  }

  /**
   * set the logged in user and init the blockchain service
   */
  private setLoggedInUser(loggedInUser?: Moralis.User) {
    // set the user
    this.user = loggedInUser;
    this._connected = loggedInUser !== null;

    // log the user
    console.info('Loggedin user:', loggedInUser);

    // login the application service
    if(this.user) this.blockchainService.login(this.user)
    .then(() => {
      this.title = `${this.blockchainService.networkName()}-${this.connectedAccount}`;
      /**
       * Manual detect changes due to OnPush change detection.
       * This can be eliminated if you use async pipe and Observables
       * (out of scope of this)
       */
      this.cdr.detectChanges();
    });
  }

  /**
   * logout the user
   */
  logout() {
    Moralis.User.logOut()
      .then((loggedOutUser) => console.info('logout', loggedOutUser))
      // Set user to undefined
      .then(() => this.setLoggedInUser(undefined))
      // Disconnect Web3 wallet
      .then(() => Moralis.Web3.cleanup())
      .catch((e) => console.error('Moralis logout error:', e));
  }

  /**
   * return true if connected to the network
   */
  get connected(): boolean {
    return this._connected;
  }

  /**
   * return true if injected
   */
  get isInjected(): boolean {
    return !!localStorage.getItem('WEB3_CONNECT_CACHED_PROVIDER');
  }

  /**
   * clear injected provider
   */
  clearInjected(): void {
    this.logout();
    window.location.reload();
  }

  /**
   * return the connected account string
   */
  get connectedAccount(): string | undefined {
    return this.blockchainService.account !== undefined
      ? this.blockchainService.account.substring(0, 4) +
          '...' +
          this.blockchainService.account.substring(
            this.blockchainService.account.length - 2,
            this.blockchainService.account.length
          )
      : undefined;
  }

  /**
   * the button caption
   */
  get buttonCaption(): string | undefined {
    return this.title;
  }
}
