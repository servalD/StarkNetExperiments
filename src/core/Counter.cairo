use token::interfaces::SimpleERC20::{ISimpleERC20Dispatcher, ISimpleERC20DispatcherTrait};

#[starknet::component]
pub mod counter_component {
    use starknet::{ContractAddress, get_caller_address};
    use super::{ISimpleERC20Dispatcher, ISimpleERC20DispatcherTrait};
    use starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry,
    };

    #[storage]
    pub struct Storage {
        value: u256,
        asset: ContractAddress,
        // Strange sheme using value_account
        // value_account: Map<ContractAddress, u256>,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Update: Update,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Update {
        #[key]
        account: ContractAddress,
        value: u256,
    }

     #[generate_trait]
    pub impl CounterInternalImpl<
        TContractState, +HasComponent<TContractState>,
    > of CounterInternalTrait<TContractState> {
        fn _init(ref self: ComponentState<TContractState>, asset: ContractAddress) {
            self.asset.write(asset);
            self.value.write(0);
        }
    }
    

    #[embeddable_as(Counter)]
    impl CounterImpl<TContractState, +HasComponent<TContractState>> of token::interfaces::Counter::ICounter<ComponentState<TContractState>> {

        fn get_value(self: @ComponentState<TContractState>) -> u256 {
            self.value.read()
        }

        fn increase(ref self: ComponentState<TContractState>) -> u256{
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

        fn decrease(ref self: ComponentState<TContractState>) -> u256{
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

#[starknet::contract]
pub mod Counter {
    use super::counter_component;
    use starknet::{ContractAddress};

    #[constructor]
    fn constructor(ref self: ContractState, asset: ContractAddress) {
        self.counter._init(asset);
    }

    component!(path: counter_component, storage: counter, event: CounterEvent);

    #[abi(embed_v0)]
    impl CounterImpl = counter_component::Counter<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        counter: counter_component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        CounterEvent: counter_component::Event,
    }

    impl CounterInternalImpl = counter_component::CounterInternalImpl<ContractState>;
     
    
}
