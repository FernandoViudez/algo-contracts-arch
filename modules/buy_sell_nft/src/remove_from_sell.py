from re import I
from pyteal import *
from pyteal.ast import *


@Subroutine(TealType.none)
def optOutAsa():
    return Seq(
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields({
            TxnField.type_enum: TxnType.AssetTransfer,
            TxnField.asset_close_to: Global.current_application_address(),
            TxnField.xfer_asset: Txn.assets[0],
            TxnField.asset_amount: Int(0),
            TxnField.asset_receiver: Global.current_application_address(),
            TxnField.fee: Int(0)
        }),
        InnerTxnBuilder.Submit(),
    )


@Subroutine(TealType.none)
def clawbackBalanceAndCloseAccount():
    return Seq(
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields({
            TxnField.type_enum: TxnType.Payment,
            TxnField.close_remainder_to: Txn.sender(),
            TxnField.fee: Int(0)
        }),
        InnerTxnBuilder.Submit(),
    )


def removeFromSale():
    return Seq(
        Assert(
            And(
                Txn.sender() == Global.creator_address(),
                Txn.fee() == Global.min_txn_fee() * Int(3)
            )
        ),
        optOutAsa(),
        clawbackBalanceAndCloseAccount(),
        Approve()
    )
