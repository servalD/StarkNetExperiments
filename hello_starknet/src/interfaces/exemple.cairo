use starknet::ContractAddress;
use starknet::ClassHash;

#[starknet::interface]
pub trait IExemple<TContractState> {
    fn change_value(ref self: TContractState, value: u256);
    fn get_value(self: @TContractState) -> u256;
}


