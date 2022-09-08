from locale import atoi
from pyteal import *
from pyteal.ast import *
from modules.buy_sell_nft.src.buy import *
from modules.buy_sell_nft.src.publish import *
from modules.buy_sell_nft.src.remove_from_sell import *


def handle_event():
    return Seq(
        Cond(
            [Txn.application_args[0] == Bytes('buy'), buyNft()],
            [Txn.application_args[0] == Bytes('publish'), publishNft()]
        ),
        Reject()
    )


def approval() -> Expr:
    return Cond(
        [Txn.application_id() == Int(0), Seq(
            App.globalPut(nft_id, Btoi(Txn.application_args[0])),
            App.globalPut(nft_price, Btoi(Txn.application_args[1])),
            App.globalPut(nft_owner, Txn.sender()),
            Approve()
        )],
        [Txn.on_completion() == OnComplete.DeleteApplication, removeFromSale()],
        [Txn.on_completion() == OnComplete.UpdateApplication, Approve()],
        [Txn.on_completion() == OnComplete.OptIn, Approve()],
        [Txn.on_completion() == OnComplete.CloseOut, Approve()],
        [Txn.on_completion() == OnComplete.NoOp, handle_event()],
    )


def clear():
    return Approve()
