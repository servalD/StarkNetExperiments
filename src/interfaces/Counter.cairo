use starknet::ContractAddress;
use starknet::ClassHash;

#[starknet::interface]
pub trait ICounter<TContractState> {
    fn get_value(self: @TContractState) -> u256;
    fn increase(ref self: TContractState) -> u256;
    fn decrease(ref self: TContractState) -> u256;
}


