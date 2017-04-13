pragma solidity ^0.4.0;

// Burn coin burns a little bit of coin on every transaction gradually recuding
// the total supply
contract Burn {
    // Constants
    string public standard = 'Token 0.1';
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
    event Transfer(address from, address to, uint amount);
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

    /* @function Transfer
     * @name transfer
     * @param {address} receiver - Address to send coin to
     * @param {uint} amount - Amount of coin to send
     */
    function transfer(address _to, uint _value) public {
        if (balances[msg.sender] < _value) throw;
        if (amount < burnRate * 1000) throw;
        balances[msg.sender] -= _value;
        uint remining = burnCoin(_value);
        balances[_to] += remining;
        Transfer(msg.sender, _to, remining);
    }
    
    function () {
        throw;
    }
}
