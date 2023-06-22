#[contract]
mod ERC20 {

    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use zeroable::Zeroable;
    use integer::BoundedInt;

    struct Storage{
        _name: felt252,
        _symbol: felt252,
        _total_supply: u256,
        _balances: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
    }

    #[event] 
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256){}

    #[event] 
    fn Approval(owner: ContractAddress, spender: ContractAddress, value:u256){}

    #[view] 
    fn name() -> felt252{
        _name::read()
    }

    #[view] 
    fn symbol() -> felt252{
        _symbol::read()
    }

    #[view] 
    fn decimal() -> u8{
        18_u8
    }

    #[view] 
    fn total_supply() -> u256 {
        _total_supply::read()
    }

    #[view]
    fn balances(account: ContractAddress) -> u256{
        _balances::read(account)
    }

    #[view] 
    fn allowances(owner: ContractAddress, spender: ContractAddress) ->u256 {
        _allowances::read((owner,spender))
    }



    #[constructor]
    fn constructor( name: felt252, symbol: felt252, initial_supply: u256, recipient: ContractAddress) {

        initializer(name, symbol);
        _mint(recipient, initial_supply);
    }



    fn initializer(name_: felt252 ,symbol_ : felt252){
        _name::write(name_);
        _symbol::write(symbol_);
    }


    fn _mint( recipient: ContractAddress, amount: u256){
        assert(!recipient.is_zero(), 'ERC20: mint to 0');
        _total_supply::write(_total_supply::read() + amount);
        _balances::write(recipient, _balances::read(recipient) + amount);
        Transfer(Zeroable::zero(), recipient, amount);
    }



    #[external] 
    fn transfer(recipient: ContractAddress, amount: u256) -> bool {

        let sender = get_caller_address();
        _transfer(sender, recipient, amount);
        true
    }

    #[external] 
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount:u256) -> bool{

        let caller = get_caller_address();
        _spend_allowance(sender, caller, amount);
        _transfer(sender, recipient, amount);
        true
    }

    #[external]
    fn approve(spender: ContractAddress, amount: u256) -> bool{
        let caller = get_caller_address();
        _approve(caller, spender, amount);
        true
    }

    #[external] 
    fn increase_allowance(spender: ContractAddress, added_value: u256) -> bool{
        _increase_allowance(spender, added_value)
    }

    #[external]
    fn decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool{
        _decrease_allowance(spender, subtracted_value)
    }



    fn _transfer( sender: ContractAddress, recipient: ContractAddress, amount: u256){
        assert(!sender.is_zero(), 'ERC20: transfer from 0');
        assert(!recipient.is_zero(), 'ERC20: transfer to 0');
        _balances::write(sender, _balances::read(sender) - amount);
        _balances::write(recipient, _balances::read(recipient) + amount);
        Transfer(sender, recipient, amount);
    }

    fn _spend_allowance(owner: ContractAddress, spender: ContractAddress, amount: u256){

        let current_allowance = _allowances::read((owner, spender));
        if current_allowance != BoundedInt::max() {
            _approve(owner, spender, current_allowance - amount);
        }
    }
    
    fn _approve(owner: ContractAddress, spender: ContractAddress ,amount: u256) {

        assert(!owner.is_zero(), 'ERC20: approve from 0');
        assert(!spender.is_zero(), 'ERC20: approve to 0');
        _allowances::write((owner, spender), amount);
        Approval(owner, spender, amount);

    }

    fn _increase_allowance(spender: ContractAddress, added_value: u256) -> bool{

        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) + added_value);
        true
    }

    fn _decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool{

        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) + subtracted_value);
        true
    }
}





