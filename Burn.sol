pragma solidity ^0.4.2;

contract owned {
    address public owner;                      // Owner of contract

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

// Burn coin burns a little bit of coin on every transaction gradually recuding
// the total supply
contract Burn is owned {
    // Constants
    string public standard = 'Token 0.1';           // Token standard
    uint public supply = 10000000000000000000000000;// Total Supply
    string public name = 'Burn';                    // Name of the token
    string public symbol = 'BURN';                  // Symbol of the token
    uint public decimals = 18;                      // Decimals for token
    uint public burnRate = 1;//ppt                  // burnRate where x ppt is burned
    
    // Variables
    uint public burned = 0;                         // Total token burned
    mapping (address => uint) public balances;      // Balances

    // ICO Constants
    bool public ICOActive = true;                   // Dignifies if ICO funding is still active
    uint public exchangeRate = 500;                 // ICO return is equal to 1 wei * exchange rate

    // ICO Variables
    uint public ICOCirculation = 0;                 // Used to ensure ICO offerings do not exceed supply
    mapping (address => uint) public ICObalances;   // ICO balances, to be transferred to actual balances upon ICO colsing
    
    // Events
    event Transfer(address from, address to, uint amount);
    event Burned(address burner, uint amount);

    /* @modifier onlyOwner
     * @description ensures only the contract owner can execute this command
     */
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    /* @constructor Burn
     * @param {uint} _supply - The total coin in circulation
     * @param {string} _name - The name of the coin
     * @param {string} _symbol - The symbol of the coin
     * @param {uint} _decimals - The total decimal places
     * @param {uint} _burnRate - ppt to burn
     */
    function Burn(uint _supply, string _name, string _symbol, uint _decimals, uint _burnRate) {
        supply = _supply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        burnRate = _burnRate;
        balances[owner] = _supply;
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
    function transfer(address _to, uint _value) productionOnly public returns (bool success) {
        if (balances[msg.sender] < _value) {
            return false;                                       // Sender does not have enough coin to send
        } else if (_value < burnRate * 1000) {
            return false;                                       // Send amount too low
        } else {
            balances[msg.sender] -= _value;
            uint remining = burnCoin(_value);
            balances[_to] += remining;
            Transfer(msg.sender, _to, remining);
            return true;
        }   
    }
    
    /* ICO 
     * During the ICO phase people may trade their Ether for Burn coin, balances will be stored in the 
     * ICOBalances and transferred over to the production balances once closeICO is executed by the contract
     * owner. Remaining avalible coins will be sent to the contract owner.
     */
    
    modifier productionOnly () {
        if (ICOActive) throw;
        _;
    }


    function closeICO() onlyOwner {
        balances[owner] = supply - ICOCirculation;              // Send remaining coin to owner
        ICOActive = false;                                      // Dignify that ICO funding is over
    }

    function ICOTransfer(address _to, uint _value) public returns (bool success) {
        if (ICOCirculation < supply) {
            uint payout = _value * exchangeRate;
            balances[_to] += payout;
            ICOCirculation += payout;
            balances[owner] -= payout;
            return true;
        } else {
            return false;
        }
    }

    // Executes when somebody sends ether to contract address
    function () payable {
        ICOTransfer(msg.sender, msg.value);
    }
}
