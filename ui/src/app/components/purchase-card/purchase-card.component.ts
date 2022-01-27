import { Component, OnInit } from '@angular/core';
import { BlockchainService } from 'src/app/blockchain.service';

@Component({
  selector: 'app-purchase-card',
  templateUrl: './purchase-card.component.html',
  styleUrls: ['./purchase-card.component.css']
})
export class PurchaseCardComponent implements OnInit {
  quantity = 1;
  constructor(public blockchainService: BlockchainService) { }

  ngOnInit(): void {
  }

  buyNowClicked() {
    this.blockchainService.purchaseTokens(this.quantity);
  }

}
