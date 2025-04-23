#[starknet::contract]
mod Exemple {
    use starknet::{ContractAddress, ClassHash, get_caller_address};
    #[storage]
    struct Storage {
        value: u256,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Update: Update,
    }

    #[derive(Drop, starknet::Event)]
    struct Update {
        #[key]
        value: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_value: u256) {
        self.value.write(initial_value);
    }

    #[abi(embed_v0)]
    impl ExempleImpl of hello_starknet::interfaces::exemple::IExemple<ContractState> {
        fn change_value(ref self: ContractState, value: u256) {
            self.value.write(value);
            self.emit(Update { value: value });
        }

        fn get_value(self: @ContractState) -> u256 {
            self.value.read()
        }
    }

    #[generate_trait]
    impl ExempleHelper of ExempleHelperTrait {
        fn get_value_internal(self: @ContractState) -> u256 {
            self.value.read()
        }
    }
}
