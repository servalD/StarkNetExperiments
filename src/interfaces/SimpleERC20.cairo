use starknet::ContractAddress;

#[starknet::interface]
pub trait ISimpleERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn totalSupply(self: @TContractState) -> u256;
    fn balanceOf(self: @TContractState, address: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, to: ContractAddress, amount: u256) -> ();
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> ();
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transferFrom(ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256) -> ();
    fn mint(ref self: TContractState, to: ContractAddress, amount: u256) -> ();
    fn burn(ref self: TContractState, from: ContractAddress, amount: u256) -> ();
}


