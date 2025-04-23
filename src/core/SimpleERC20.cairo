#[starknet::contract]
mod SimpleERC20 {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        Map,
    };
    #[storage]
    struct Storage {
        _name: felt252,
        _symbol: felt252,
        _total_supply: u256,
        _balance: Map<ContractAddress, u256>,
        _allowance: Map<(ContractAddress, ContractAddress), u256>,
        _owner: ContractAddress,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Mint: Mint,
        Burn: Burn,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key]
        from: ContractAddress,
        to: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Mint {
        #[key]
        to: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Burn {
        #[key]
        from: ContractAddress,
        amount: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, name: felt252, symbol: felt252, initial_supply: u256) {
        self._name.write(name);
        self._symbol.write(symbol);
        self._total_supply.write(initial_supply);
        self._balance.write(owner, initial_supply);
        self._owner.write(owner);
    }

    #[abi(embed_v0)]
    impl SimpleERC20Impl of token::interfaces::SimpleERC20::ISimpleERC20<ContractState> {

        fn name(self: @ContractState) -> felt252 {
            self._name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self._symbol.read()
        }

        fn totalSupply(self: @ContractState) -> u256 {
            self._total_supply.read()
        }

        fn balanceOf(self: @ContractState, address: ContractAddress) -> u256 {
            self._balance.read(address)
        }

        fn transfer(ref self: ContractState, to: ContractAddress, amount: u256) -> () {
            let caller = get_caller_address();
            let caller_balance = self._balance.read(caller);
            let to_balance = self._balance.read(to);

            assert!(caller_balance >= amount, "Insufficient balance");
            assert!(to != caller, "Cannot transfer to self");

            self._balance.write(caller, caller_balance - amount);
            self._balance.write(to, to_balance + amount);

            self.emit(Transfer { from: caller, to, amount });
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> () {
            let caller = get_caller_address();
            self._allowance.write((caller, spender), amount);
        }

        fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
            self._allowance.read((owner, spender))
        }

        fn transferFrom(ref self: ContractState, from: ContractAddress, to: ContractAddress, amount: u256) -> () {
            let caller = get_caller_address();
            let from_balance = self._balance.read(from);
            let to_balance = self._balance.read(to);
            let allowance = self._allowance.read((from, caller));

            assert!(from_balance >= amount, "Insufficient balance");
            assert!(from != caller, "Cannot transfer from self (use transfer instead)");
            assert!(to != from, "Cannot transfer to self");
            assert!(allowance >= amount, "Allowance exceeded");

            self._balance.write(from, from_balance - amount);
            self._balance.write(to, to_balance + amount);
            self._allowance.write((from, caller), allowance - amount);

            self.emit(Transfer { from, to, amount });
        }

        fn mint(ref self: ContractState, to: ContractAddress, amount: u256) -> () {
            assert!(get_caller_address() == self._owner.read(), "Only owner can mint");

            let total_supply = self._total_supply.read();
            let to_balance = self._balance.read(to);

            self._total_supply.write(total_supply + amount);
            self._balance.write(to, to_balance + amount);

            self.emit(Mint { to, amount });
        }

        fn burn(ref self: ContractState, from: ContractAddress, amount: u256) -> () {
            assert!(get_caller_address() == self._owner.read(), "Only owner can burn");

            let from_balance = self._balance.read(from);
            assert!(from_balance >= amount, "Insufficient balance");
            let total_supply = self._total_supply.read();

            self._balance.write(from, from_balance - amount);
            self._total_supply.write(total_supply - amount);
        }
    }
}
