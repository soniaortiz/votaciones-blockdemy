
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value); // usadas para Frontend
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}
contract ERC20Detailed is IERC20{
    // interface

    //name
    //symbol
    // decimals
    string public  constant name = "Blockdemy Community Token";
    string public constant symbol = "BCT";
    uint public constant decimals = 18;

    // balances
    mapping(address=> uint256) balances;
    // allowances
    mapping(address => mapping(address=>uint256)) allowed;
    // totalSupply

    uint256 _totalSupply = 1000 *1e18;
    //functions 
    constructor(){
        balances[msg.sender] = _totalSupply;
    }

    function totalSupply() public override view returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance){
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public override returns (bool success){
        require(_value <= balances[msg.sender], "Verificacion fallida");
        balances[msg.sender] = balances[msg.sender]-_value;
        balances[_to]+= _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /*
        Verificar que el numero de tokens a enviar sea igual o menor que el balance del owner
        verificar que el numero de tokens a enviar sea igual o menor que los permitidos por el owner

        actualizar balance de quien envia
        actualizar el balance del allowance del spender
        actualizar balance de quien recibe/compra
        emitimos evento transfer
        retornamos true
    */
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success){
        require(_value<= balances[_from], 'No hay suficientes fondos');
        require(_value<= allowed[_from][msg.sender], 'Excede la cantidad permitida, operacion invalida');
        balances[_from]-= _value;
        allowed[_from][msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }


    function approve(address _spender, uint256 _value) public override returns (bool success){
        require(balances[msg.sender]>= _value, 'No tienes los fondos necesarios');
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) external view returns (uint256 remaining){

    }
    // event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    //events
}