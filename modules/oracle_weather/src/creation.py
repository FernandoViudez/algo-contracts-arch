from pyteal import *
from pyteal.ast import *

bet_timestamp_date = Bytes("bet_date")  # int

creator_opt = Bytes("creator_opt")  # byteslice
creator_money = Bytes("creator_money")  # int
gambler_opt = Bytes("gambler_opt")  # byteslice
gambler_money = Bytes("gambler_money")  # int
gambler_addr = Bytes("gambler_addr")  # byteslice
sv_addr = Bytes("sv_addr")  # byteslice


def createBet():
    return Seq(
        App.globalPut(creator_opt, Bytes("")),
        App.globalPut(gambler_opt, Bytes("")),
        App.globalPut(gambler_addr, Bytes("")),
        App.globalPut(creator_money, Int(0)),
        App.globalPut(gambler_money, Int(0)),
        App.globalPut(bet_timestamp_date, Int(0)),
        App.globalPut(sv_addr, Txn.application_args[0]),
        Approve(),
    )
