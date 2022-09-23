import { describe } from 'mocha';
import { AccountStore, Runtime } from '@algo-builder/runtime';
import { types } from '@algo-builder/web';
import { AppInfo } from '@algo-builder/runtime/build/types';
import { expect } from 'chai';

describe('Stateful smart contract', function () {
    let donator: AccountStore;
    let creator: AccountStore;
    let runtime: Runtime;
    let initialAlgo = 1000000n;
    let appInfo: AppInfo;

    this.beforeAll(() => {
        donator = new AccountStore(initialAlgo);
        creator = new AccountStore(initialAlgo);
        runtime = new Runtime([donator, creator]);
        runtime.setRoundAndTimestamp(20, 100);
        appInfo = runtime.deployApp(creator.account, {
            appName: "CounterApp",
            metaType: types.MetaType.FILE,
            approvalProgramFilename: "approval.teal",
            clearProgramFilename: "clear.teal",
            globalBytes: 5,
            globalInts: 3,
            localBytes: 0,
            localInts: 0,
        },
            {}
        );
    })

    describe('[App-call] donate', function () {
        // execute txn
        it('App should receive some microalgos from sender account', function () {
            const appCallTxnParams: types.ExecParams = {
                type: types.TransactionType.CallApp,
                sign: types.SignType.SecretKey,
                fromAccount: donator.account,
                appID: appInfo.appID,
                appArgs: ['str:donate'],
                payFlags: { totalFee: 1000 },
            };

            const paymentTxnParams: types.ExecParams = {
                type: types.TransactionType.TransferAlgo,
                sign: types.SignType.SecretKey,
                fromAccount: donator.account,
                toAccountAddr: appInfo.applicationAccount,
                amountMicroAlgos: 100000,
                payFlags: { totalFee: 1000 },
            };

            runtime.executeTx([appCallTxnParams, paymentTxnParams]);
            const appAccount = runtime.getAccount(appInfo.applicationAccount);
            expect(appAccount.balance()).to.eq(100000n);
        })

        it('Donator account should have 102.000 less than his previous balance', function () {
            const donatorAccount = runtime.getAccount(donator.address);
            // 100.000 donated
            // 1000 for app txn fee
            // 1000 for payment txn fee
            expect(donatorAccount.balance()).to.eq(initialAlgo - 102000n);
        })
    })
})