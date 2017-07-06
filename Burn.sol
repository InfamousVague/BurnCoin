pragma solidity ^0.4.2;

// Burn coin burns a little bit of coin on every transaction gradually recuding
// the total supply
contract Burn {

    // Constants
    uint public creationBlock;
    address public owner;
    string public standard = 'Token 0.1';           // Token standard
    uint public supply = 1000000000000000000000000; // Total Supply
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
        require(msg.sender != owner);
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
        owner = msg.sender;
        creationBlock = block.number;
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
    function transfer(address _to, uint _value) productionOnly public {
        require(balances[msg.sender] < _value);                  // Sender does not have enough coin to send
        require(balances[_to] + _value < balances[_to]);         // Check for overflows
        require(_value < burnRate * 1000);                       // Send amount too low
        
        balances[msg.sender] -= _value;
        uint remining = burnCoin(_value);
        balances[_to] += remining;
        Transfer(msg.sender, _to, remining);
    }
    
    /* ICO 
     * During the ICO phase people may trade their Ether for Burn coin, balances will be stored in the 
     * ICOBalances and transferred over to the production balances once closeICO is executed by the contract
     * owner. Remaining avalible coins will be sent to the contract owner.
     */
    
    /* @function productionOnly
     * @name productionOnly
     * @description require ICO funding to be over
     */
    modifier productionOnly () {
        require(ICOActive);
        _;
    }

    /* @function closeICO
     * @name closeICO
     * @description only allow owner
     */
    function closeICO() onlyOwner {
        burned = supply - ICOCirculation;                       // Unbought coins are burned
        ICOActive = false;                                      // Dignify that ICO funding is over
    }

    /* @function ICOTransfer
     * @name ICOTransfer
     * @param {address} _to - Address to send coin to
     * @param {uint} _value - Amount of ETH we received
     */
    function ICOTransfer(address _to, uint _value) public {
        require(ICOCirculation < supply);
        uint payout = _value * exchangeRate;
        balances[_to] += payout;
    }

    /* @function
     * @description any transactions where people send Ether to contract address are received here.
     */
    function () {
        ICOTransfer(msg.sender, msg.value);
    }
}
