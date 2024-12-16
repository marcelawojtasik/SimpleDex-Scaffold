//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// Compatible with OpenZeppelin Contracts ^5.0.0

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * A smart contract that implements a decentralized exchange (DEX) for two ERC20 tokens.
 * It also allows changing state variables of the contract and tracking the changes
 * @author MarcelaWojtasik
 */
contract SimpleDex {
    // State Variables
    address owner;
    IERC20 tokenA;
    IERC20 tokenB;
    uint256 public liquidityA;
    uint256 public liquidityB;

    // Events: a way to emit log statements from smart contract that can be listened to by external parties
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    event Swap(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);
    
    // Constructor: Called once on contract deployment
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    //modifier to restrict critical functions to the contract owner.
    modifier onlyOwner() {
        owner == msg.sender;
        _;
    }

/* *Añado liquidez en pares: una cantidad válida de tokens A y otra de tokens B.
*Le sumo a la liquidez los tokens añadidos
*Emito evento que informa cambio en variable de estado */
    function addLiquidity (uint256 amountA, uint256 amountB) external onlyOwner{
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        liquidityA += amountA;
        liquidityB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

/* *Calculo cantidad de  tokens q recibiré al realizar intercambio bajo modelo AMM
*Aseguro liquidez del pool: Formula de producto constante (x + dx) * (y - dy) = x * y */
    function amountOut(uint256 amountIn, uint256 liquidityIn, uint256 liquidityOut) private pure returns (uint256) {
        require(amountIn > 0 && liquidityIn > 0 && liquidityOut > 0, "Invalid reserves or input");
        return (amountIn * liquidityOut) / (liquidityIn + amountIn);
    }   

/* *Swap de tokens AforB
*Le sumo a la liquidez los tokens añadidos y resto los resultantes al exchange
*Emito evento que informa cambio en variable de estado */
    function swapAforB(uint256 amountAIn) public {
        require(amountAIn > 0, "Amount must be greater than zero");
        uint256 amountBOut = amountOut (amountAIn, liquidityA, liquidityB);

        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        liquidityA += amountAIn;
        liquidityB -= amountBOut;

        emit Swap(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }


    function swapBforA(uint256 amountBIn) public {
        require(amountBIn > 0, "Amount must be greater than zero");        
        uint256 amountAOut = amountOut(amountBIn, liquidityB, liquidityA);
        
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        liquidityB += amountBIn;
        liquidityA -= amountAOut;

        emit Swap(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

/**Remuevo liquidez de a pares: una cantidad válida de tokens A y otra de tokens B.
*Le resto a la liquidez los tokens removidos 
*Emito evento que informa cambio en variable de estado */

    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner{
        require(amountA <= liquidityA && amountB <= liquidityB, "Insufficient liquidity");

        liquidityA -= amountA;
        liquidityB -= amountB;

        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

//Obtención de precio del token: Verifico que la dirección ingresada sea válida.
//Si el token ingresado es TokenA, la función calcula el precio dividiendo la cantidad de TokenB en el pool entre la cantidad de TokenA. A la inversa si no es TokenA (Entonces es B)
//Multiplico por 10e18 para manejar los decimales y asegurar la precisión en los cálculos.
    function getPrice(address _token) external view returns (uint256) {
        require(_token == address(tokenA) || _token == address(tokenB), "Invalid token");

        if (_token == address(tokenA)) {
            return liquidityB * 1e18 / liquidityA;
        } else {
            return liquidityA * 1e18 / liquidityB;
        }
    }

}

//Successfully verified contract SimpleDex on the block explorer.
//https://sepolia.etherscan.io/address/0xd57Ec4740FaE036D446E653B83f88a82975EE9bB#code