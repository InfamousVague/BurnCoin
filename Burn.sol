pragma solidity ^0.4.0;

// Burn coin burns a little bit of coin on every transaction gradually recuding
// the total supply
contract Burn {
    // Constants
    address public minter;
    uint public supply;
    string public name;
    string public symbol;
    uint public decimals;
    uint public burnRate;

    // Variables
    uint public burned = 0;
    mapping (address => uint) public balances;
    
    // Events
    event Sent(address from, address to, uint amount);
    event Burned(address burner, uint amount);
    
    /* @constructor Burn
     * @param {uint} _supply - The total coin in circulation
     * @param {string} _name - The name of the coin
     * @param {string} _symbol - The symbol of the coin
     * @param {uint} _decimals - The total decimal places
     * @param {uint} _burnRate - ppt to burn
     */
    function Burn(uint _supply, string _name, string _symbol, uint _decimals, uint _burnRate) {
        minter = msg.sender;
        supply = _supply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        burnRate = _burnRate;
        balances[minter] = _supply;
    }
    
    /* @function burnCoin
     * @name burnCoin
     * @param {uint} amount - Amount of coin to burn from
     * @returns {uint} remaining - Amount of coin left 
     */
    function burnCoin(uint amount) internal returns (uint remaining) {
        uint burn = (amount / 1000) * burnRate;
        burned += burn;
        Burned(msg.sender, burn);
        
        return (amount - burn);
    }

    /* @function send
     * @name send
     * @param {address} receiver - Address to send coin to
     * @param {uint} amount - Amount of coin to send
     */
    function send(address receiver, uint amount) public {
        if (balances[msg.sender] < amount) throw;
        if (amount < burnRate * 1000) throw;
        balances[msg.sender] -= amount;
        uint remining = burnCoin(amount);
        balances[receiver] += remining;
        Sent(msg.sender, receiver, remining);
    }
}
