import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new insurance pool with minimum stake requirement",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;

    let block = chain.mineBlock([
      Tx.contractCall(
        'crowd-haven',
        'create-pool',
        [types.ascii("Test Pool"), types.uint(1000)],
        deployer.address
      )
    ]);

    assertEquals(block.receipts[0].result.expectOk(), "u1");

    let poolInfo = chain.callReadOnlyFn(
      'crowd-haven',
      'get-pool-info',
      [types.uint(1)],
      deployer.address
    );

    let pool = poolInfo.result.expectOk().expectSome();
    assertEquals(pool['min-stake'], types.uint(1000));
    assertEquals(pool['active'], true);
  },
});

Clarinet.test({
  name: "Cannot join pool with stake less than minimum",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;

    let block = chain.mineBlock([
      Tx.contractCall(
        'crowd-haven',
        'create-pool',
        [types.ascii("Test Pool"), types.uint(1000)],
        deployer.address
      ),
      Tx.contractCall(
        'crowd-haven',
        'join-pool',
        [types.uint(1), types.uint(500)],
        wallet1.address
      )
    ]);

    assertEquals(block.receipts[1].result, "(err u104)");
  },
});
