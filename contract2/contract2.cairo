#[contract]
mod SayiOyunu{
use starknet::get_caller_address;
use starknet::ContractAddress;



struct Storage{
    user_counters: LegacyMap<ContractAddress, u128>,
}

#[view]
fn get_user_counters(account: ContractAddress)-> u128{

    let user_counter = user_counters::read(account);
    user_counter
}

#[external] 
fn increment_counter(){

    let sender_address: ContractAddress = get_caller_address();
    let current_counter_value = user_counters::read(sender_address);

    user_counters::write(sender_address,current_counter_value + 2_u128);
}

#[external] 
fn decerment_counter(){

    let sender_address: ContractAddress = get_caller_address();
    let current_counter_value = user_counters::read(sender_address);
    
    user_counters::write(sender_address, current_counter_value - 1_u128);
}

#[external] 
fn reset_counter(){

    let sender_address: ContractAddress = get_caller_address();

    user_counters::write(sender_address, 0_u128);
}















}
