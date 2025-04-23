use token::interfaces::SimpleERC20::{ISimpleERC20Dispatcher, ISimpleERC20DispatcherTrait};

#[starknet::contract]
mod Counter {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::Map;
    use super::{ISimpleERC20Dispatcher, ISimpleERC20DispatcherTrait};

    #[storage]
    struct Storage {
        value: u256,
        asset: ContractAddress,
        // Strange sheme using value_account
        // value_account: Map<ContractAddress, u256>,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Update: Update,
    }

    #[derive(Drop, starknet::Event)]
    struct Update {
        #[key]
        account: ContractAddress,
        value: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, asset: ContractAddress) {
        self.asset.write(asset);
        self.value.write(0);
    }

    #[abi(embed_v0)]
    impl CounterImpl of token::interfaces::Counter::ICounter<ContractState> {

        fn get_value(self: @ContractState) -> u256 {
            self.value.read()
        }

        fn increase(ref self: ContractState) -> u256{
            let caller = get_caller_address();
            let val = self.value.read() + 1;

            self.value.write(val);
            // Strange sheme using value_account
            // let caller_balance = self.value_account.read(caller);
            // self.value_account.write(caller, caller_balance + 1);

            ISimpleERC20Dispatcher{ contract_address: self.asset.read() }
                .mint(caller, val);

            self.emit(Update { value: val, account: caller });
            val
        }

        fn decrease(ref self: ContractState) -> u256{
            let caller = get_caller_address();
            let asset = ISimpleERC20Dispatcher{ contract_address: self.asset.read() };

            let val = self.value.read();
            let caller_balance = asset.balanceOf(caller);
            // Strange sheme using value_account
            // let caller_counter = self.value_account.read(caller);
            // assert!(caller_counter > 0, "The caller has no counter and should increase it first");

            assert!(caller_balance >= val, "The caller has insufficient balance on the underlying asset. (Increase before)");

            asset.burn(caller, val);
            
            self.value.write(val - 1);
            // self.value_account.write(caller, caller_counter - 1);

            self.emit(Update { value: val, account: caller });
            val
        }
    }
}
