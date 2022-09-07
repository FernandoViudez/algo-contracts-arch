
from pyteal import *
from pyteal.ast import *


@Subroutine(TealType.uint64)
def hasAsset(account: Expr, asset: Expr):
    accountAssetBalance = AssetHolding.balance(account, asset)
    return Seq(
        accountAssetBalance,
        Return(accountAssetBalance.hasValue())
    )
