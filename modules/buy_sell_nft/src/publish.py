from pyteal import *
from pyteal.ast import *
from modules.buy_sell_nft.src.asset_balance import *
from modules.buy_sell_nft.src.buy import *


@Subroutine(TealType.none)
def optInAsset():
    return Seq(
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields({
            TxnField.type_enum: TxnType.AssetTransfer,
            TxnField.asset_amount: Int(0),
            TxnField.xfer_asset: Txn.assets[0],
            TxnField.asset_receiver: Global.current_application_address(),
        }),
        InnerTxnBuilder.Submit(),
    )


@Subroutine(TealType.none)
def publishNft():
    return Seq(
        If(
            hasAsset(Global.current_application_address(),
                     App.globalGet(nft_id)),
            Reject()
        ),
        Assert(
            And(
                Txn.assets.length() == Int(1),
                Txn.sender() == Global.creator_address(),

                Gtxn[0].type_enum() == TxnType.Payment,
                Gtxn[0].receiver() == Global.current_application_address(),
                Gtxn[0].amount() == Add(Int(200000), Int(1000)),

                Gtxn[2].type_enum() == TxnType.AssetTransfer,
                Gtxn[2].asset_receiver() == Global.current_application_address(),
                Gtxn[2].xfer_asset() == App.globalGet(nft_id),
                Gtxn[2].asset_amount() == Int(1),
            )
        ),
        optInAsset(),
        Approve()
    )
