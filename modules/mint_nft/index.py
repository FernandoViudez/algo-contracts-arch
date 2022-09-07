from pyteal import *
from pyteal.ast import *
from modules.mint_nft.src.mint import mint
from modules.mint_nft.src.withdraw import withdraw


def handle_event():
    return Seq(
        Cond(
            [Txn.application_args[0] == Bytes('mint'), mint()],
            [Txn.application_args[0] == Bytes('withdraw'), withdraw()]
        ),
        Reject()
    )


def approval() -> Expr:
    return Cond(
        [Txn.application_id() == Int(0), Approve()],
        [Txn.on_completion() == OnComplete.DeleteApplication, Approve()],
        [Txn.on_completion() == OnComplete.UpdateApplication, Approve()],
        [Txn.on_completion() == OnComplete.OptIn, Approve()],
        [Txn.on_completion() == OnComplete.CloseOut, Approve()],
        [Txn.on_completion() == OnComplete.NoOp, handle_event()],
    )


def clear():
    return Approve()
