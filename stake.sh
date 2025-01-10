set -x

cast rpc anvil_impersonateAccount $USER
cast send $TOKEN --from $USER "mint(address,uint256)" $USER 1000000000000000000000 --unlocked
cast call $TOKEN "balanceOf(address)(uint256)" $USER
cast send $TOKEN --from $USER "approve(address,uint256)" $STAKE $(cast max-uint) --unlocked
cast send $STAKE --from $USER "stake(uint256)" 1000000000000000000000 --unlocked
cast send $STAKE --from $USER "unstake(uint256)" 100000000000000000000 --unlocked
cast send $STAKE --from $USER "unstake(uint256)" 100000000000000000000 --unlocked