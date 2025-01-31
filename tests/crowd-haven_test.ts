import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new insurance pool",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;

    let block = chain.mineBlock([
      Tx.contractCall(
        'crowd-haven',
        'create-pool',
        [types.ascii("Test Pool")],
        deployer.address
      )
    ]);

    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});

Clarinet.test({
  name: "Can join existing pool",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    // Test implementation
  },
});

Clarinet.test({
  name: "Can submit and vote on claims",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    // Test implementation
  },
});
