from re import T
from pyteal import *
from pyteal.ast import *


@Subroutine(TealType.none)
def _withdraw():
    return Seq(
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields({
            TxnField.type_enum: TxnType.AssetTransfer,
            TxnField.asset_receiver: Gtxn[1].sender(),
            TxnField.asset_amount: Int(1),
            TxnField.xfer_asset: Gtxn[2].assets[0],
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
                # txn 0 = payment txn
                Gtxn[0].type_enum() == TxnType.Payment,
                Gtxn[0].amount() >= Int(1000),
                Gtxn[0].receiver() == Global.current_application_address(),

                # txn 1 = asa optin
                Gtxn[1].type_enum() == TxnType.AssetTransfer,
                Gtxn[1].asset_receiver() == Gtxn[1].sender(),
                Gtxn[1].asset_amount() == Int(0),

                # txn 2 = app call
                Gtxn[2].type_enum() == TxnType.ApplicationCall,
                Global.group_size() == Int(3),
                Gtxn[2].application_args.length() == Int(1),
                Gtxn[2].assets.length() == Int(1),
            ),
            senderAssetBalance.hasValue()
        ),
        _withdraw(),
        Approve()
    )
