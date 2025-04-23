#[starknet::contract]
mod Counter {
    // use starknet::{ContractAddress, ClassHash, get_caller_address};
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
    fn constructor(ref self: ContractState) {
        self.value.write(0);
    }

    #[abi(embed_v0)]
    impl CounterImpl of token::interfaces::Counter::ICounter<ContractState> {

        fn get_value(self: @ContractState) -> u256 {
            self.value.read()
        }

        fn increase(ref self: ContractState) -> u256{
            let val = self.value.read();
            self.value.write(val + 1);
            self.emit(Update { value: val });
            val
        }

        fn decrease(ref self: ContractState) -> u256{
            let val = self.value.read();
            self.value.write(val - 1);
            self.emit(Update { value: val });
            val
        }
    }
}
