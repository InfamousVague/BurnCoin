pragma solidity ^0.4.0;

// Burn coin burns a little bit of coin on every transaction gradually recuding
// Circulation amount.
contract Burn {
    // Contract address
    address public minter;
    
    // Inital supply
    uint public supply;
    
    // Total coin burned to date
    uint public burned = 0;

    string public name;
    string public symbol;
    uint public decimals;
    
    // Burn rate is x ppt 
    uint public burnRate;

    mapping (address => uint) public balances;
    
    // Triggered on transactions
    event Sent(address from, address to, uint amount);
    
    // Triggered when ember is burned
    event Burned(address burner, uint amount);
    
    // Assign the minter, and send them the inital supply
    function Burn(uint _supply, string _name, string _symbol, uint _decimals, uint _burnRate) {
        minter = msg.sender;
        supply = _supply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        burnRate = _burnRate;
        balances[minter] = _supply;
    }
    
    // Burns off a little bit of coin
    function burnCoin(uint amount) internal returns (uint remaining) {
        uint burn = (amount / 1000) * burnRate;
        burned += burn;
        Burned(msg.sender, burn);
        
        return (amount - burn);
    }

    function send(address receiver, uint amount) public {
        // If the sender doesn't have enough coin throw
        if (balances[msg.sender] < amount) throw;
        // If the transaction is too low to burn coin throw
        if (amount < burnRate * 1000) throw;
        
        // Sender is deducted total amount
        balances[msg.sender] -= amount;
        
        uint remining = burnCoin(amount);
        
        // Receiver receives token after burn
        balances[receiver] += remining;
        
        // Trigger a transaction event
        Sent(msg.sender, receiver, remining);
    }
}
