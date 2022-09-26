from pyteal import *
from pyteal.ast import *
from modules.donate.src.donate import *
from modules.donate.src.generous_person import *


def handle_event() -> Expr:
    return Cond(
        [Txn.application_args[0] == Bytes('donate'), donate()],
        [Txn.application_args[0] == Bytes(
            'getMostGenerousPerson'), getMostGenerousPerson()],
    )


def approval() -> Expr:
    return Cond(
        [Txn.application_id() == Int(0), Seq(
            App.globalPut(most_generous_person, Bytes("")),
            App.globalPut(max_donated, Int(0)),
            Approve(),
        )],
        [Txn.on_completion() == OnComplete.DeleteApplication, Approve()],
        [Txn.on_completion() == OnComplete.UpdateApplication, Approve()],
        [Txn.on_completion() == OnComplete.OptIn, Approve()],
        [Txn.on_completion() == OnComplete.CloseOut, Approve()],
        [Txn.on_completion() == OnComplete.NoOp, handle_event()],
    )


def clear():
    return Approve()
