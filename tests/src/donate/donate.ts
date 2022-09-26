import { describe } from 'mocha';
import { AccountStore, Runtime } from '@algo-builder/runtime';
import { types, } from '@algo-builder/web';
import { AppInfo, } from '@algo-builder/runtime/build/types';
import { expect } from 'chai';
import { decodeAddress } from 'algosdk';

let donator: AccountStore;
let creator: AccountStore;
let runtime: Runtime;
let initialAlgo = 1000000n;
let appInfo: AppInfo;

function setRuntime() {
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
}

describe('[App-call] donate', function () {
    let appCallTxnParams: types.ExecParams;
    let paymentTxnParams: types.ExecParams;

    this.beforeEach(function () {
        setRuntime();
        appCallTxnParams = {
            type: types.TransactionType.CallApp,
            sign: types.SignType.SecretKey,
            fromAccount: donator.account,
            appID: appInfo.appID,
            appArgs: ['str:donate'],
            payFlags: { totalFee: 1000 },
        };
        paymentTxnParams = {
            type: types.TransactionType.TransferAlgo,
            sign: types.SignType.SecretKey,
            fromAccount: donator.account,
            toAccountAddr: appInfo.applicationAccount,
            amountMicroAlgos: 100000,
            payFlags: { totalFee: 1000 },
        };
    })

    it('App should receive some microalgos from sender account', function () {
        runtime.executeTx([appCallTxnParams, paymentTxnParams]);
        const appAccount = runtime.getAccount(appInfo.applicationAccount);
        expect(appAccount.balance()).to.eq(100000n);
    })

    it('Donator account should have 102.000 less than his previous balance', function () {
        runtime.executeTx([appCallTxnParams, paymentTxnParams]);
        const donatorAccount = runtime.getAccount(donator.address);
        // 100.000 donated
        // 1000 for app txn fee
        // 1000 for payment txn fee
        expect(donatorAccount.balance()).to.eq(initialAlgo - 102000n);
    })

    it('Should fail if donation amount is less than the maximum donated', function () {
        paymentTxnParams = {
            type: types.TransactionType.TransferAlgo,
            sign: types.SignType.SecretKey,
            fromAccount: donator.account,
            toAccountAddr: appInfo.applicationAccount,
            amountMicroAlgos: 100000,
            payFlags: { totalFee: 1000 },
        };
        runtime.executeTx([appCallTxnParams, paymentTxnParams]);
        paymentTxnParams = {
            type: types.TransactionType.TransferAlgo,
            sign: types.SignType.SecretKey,
            fromAccount: donator.account,
            toAccountAddr: appInfo.applicationAccount,
            amountMicroAlgos: 9000,
            payFlags: { totalFee: 1000 },
        };

        try {
            runtime.executeTx([appCallTxnParams, paymentTxnParams])
        } catch (error: any) {
            expect(error.message).includes("Teal code rejected by logic");
        }

        const appAccount = runtime.getAccount(appInfo.applicationAccount);
        const donatorAccount = runtime.getAccount(donator.address);

        expect(appAccount.balance()).to.eq(100000n);
        expect(donatorAccount.balance()).to.eq(initialAlgo - 102000n);
    })

    it('Should fail if receiver is not the application address', function () {
        paymentTxnParams = {
            type: types.TransactionType.TransferAlgo,
            sign: types.SignType.SecretKey,
            fromAccount: donator.account,
            toAccountAddr: creator.address,
            amountMicroAlgos: 100000,
            payFlags: { totalFee: 1000 },
        };

        try {
            runtime.executeTx([appCallTxnParams, paymentTxnParams])
        } catch (error: any) {
            expect(error.message).includes("Teal code rejected by logic");
        }
        const donatorAccount = runtime.getAccount(donator.address);
        expect(donatorAccount.balance()).to.eq(initialAlgo);
    })

    it('Should have the global state empty', function () {
        const maximumDonated = runtime.getGlobalState(appInfo.appID, "max_donated");
        const mostGenerousPerson = runtime.getGlobalState(appInfo.appID, "most_generous_person");
        expect(mostGenerousPerson).eql(new Uint8Array())
        expect(maximumDonated).equal(0n);
    })

    it('Should have an address & maximum balance in the global state', function () {
        runtime.executeTx([appCallTxnParams, paymentTxnParams]);
        const maximumDonated = runtime.getGlobalState(appInfo.appID, "max_donated");
        const mostGenerousPerson = runtime.getGlobalState(appInfo.appID, "most_generous_person");
        expect(mostGenerousPerson).eql(decodeAddress(donator.address).publicKey);
        expect(maximumDonated).equal(100000n);
    })


})