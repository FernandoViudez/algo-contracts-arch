from pyteal import *
from pyteal.ast import *


@Subroutine(TealType.none)
def _mintNft() -> Expr:
    return Seq(
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields({
            TxnField.type_enum: TxnType.AssetConfig,
            TxnField.config_asset_total: Int(1),
            TxnField.config_asset_decimals: Int(0),
            TxnField.config_asset_unit_name: Txn.application_args[2],
            TxnField.config_asset_name: Txn.application_args[1],
            TxnField.config_asset_url: Txn.application_args[3],
            TxnField.config_asset_manager: Txn.sender(),
        }),
        InnerTxnBuilder.Submit(),
    )


@Subroutine(TealType.none)
def mint():
    return Seq(
        Assert(
            And(
                Gtxn[1].type_enum() == TxnType.ApplicationCall,
                Gtxn[0].type_enum() == TxnType.Payment,
                Gtxn[0].amount() >= Add(
                    Int(100000), Global.min_txn_fee() * Int(1)),
                Gtxn[0].receiver() == Global.current_application_address(),
            )
        ),
        _mintNft(),
        Approve()
    )
