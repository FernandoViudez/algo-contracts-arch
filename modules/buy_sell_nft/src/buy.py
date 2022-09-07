from email import feedparser
from pyteal import *
from pyteal.ast import *

nft_price = Bytes("nft_price")  # int
nft_id = Bytes("nft_id")  # int
nft_owner = Bytes("nft_owner")  # byteslice


@Subroutine(TealType.none)
def _sendAlgosToOwner():
    return Seq(
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields({
            TxnField.type_enum: TxnType.Payment,
            TxnField.amount: App.globalGet(nft_price),
            TxnField.receiver: Txn.accounts[1],
            TxnField.fee: Int(0)
        }),
        InnerTxnBuilder.Submit(),
    )


@Subroutine(TealType.none)
def _sendAsaToBuyer():
    return Seq(
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields({
            TxnField.type_enum: TxnType.AssetTransfer,
            TxnField.asset_amount: Int(1),
            TxnField.asset_receiver: Txn.sender(),
            TxnField.xfer_asset: Txn.assets[0],
            TxnField.fee: Int(0)
        }),
        InnerTxnBuilder.Submit(),
    )


@Subroutine(TealType.none)
def _validateAsaOptInTxn():
    return Seq(
        Assert(
            And(
                Gtxn[1].type_enum() == TxnType.AssetTransfer,
                Gtxn[1].asset_amount() == Int(0),
                Gtxn[1].asset_receiver() == Gtxn[1].sender(),
                App.globalGet(nft_id) == Txn.assets[0]
            )
        )
    )


@Subroutine(TealType.none)
def buyNft():
    senderAssetBalance = AssetHolding.balance(
        Txn.sender(), Txn.assets[0])
    return Seq(
        senderAssetBalance,
        Assert(
            And(
                Txn.type_enum() == TxnType.ApplicationCall,
                Txn.assets.length() == Int(1),
                Txn.fee() == Int(0),

                Gtxn[0].type_enum() == TxnType.Payment,
                Gtxn[0].amount() >= App.globalGet(nft_price),
                Gtxn[0].fee() >= Global.min_txn_fee() * Int(4),


                # cant buy the asa himself
                Txn.sender() != App.globalGet(nft_owner),
            )
        ),
        If(
            senderAssetBalance.hasValue() == Int(0)
        )
        .Then(
            _validateAsaOptInTxn()
        ),
        _sendAlgosToOwner(),
        _sendAsaToBuyer(),
        Approve()
    )
