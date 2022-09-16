from re import T
from pyteal import *
from pyteal.ast import *


@Subroutine(TealType.none)
def _withdraw():
    return Seq(
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields({
            TxnField.type_enum: TxnType.AssetTransfer,
            TxnField.asset_receiver: Txn.sender(),
            TxnField.asset_amount: Btoi(Txn.application_args[1]),
            TxnField.xfer_asset: Txn.assets[0],
            TxnField.fee: Int(0),
        }),
        InnerTxnBuilder.Submit(),
    )


@Subroutine(TealType.none)
def withdraw():
    senderAssetBalance = AssetHolding.balance(Int(0), Txn.assets[0])
    return Seq(
        senderAssetBalance,
        Assert(
            And(
                # txn 0 = asa optin
                Gtxn[0].type_enum() == TxnType.AssetTransfer,
                Gtxn[0].asset_receiver() == Gtxn[0].sender(),
                Gtxn[0].asset_amount() == Int(0),

                Txn.type_enum() == TxnType.ApplicationCall,
                Global.group_size() == Int(2),
                Txn.application_args.length() == Int(2),
                Txn.assets.length() == Int(1),
                Txn.fee() == Global.min_txn_fee() * Int(2),
            ),
            senderAssetBalance.hasValue()
        ),
        _withdraw(),
        Approve()
    )
