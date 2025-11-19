// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title Inheritance and Super Keyword Demo
 * @dev Demonstrates method overriding, virtual functions, and the use of 'super' 
 * in single and multiple inheritance chains (C3 Linearization).
 */
contract A{
    event Log(string);
    
    // 'virtual' allows derived contracts to override this function.
    function set() public  virtual  {
        emit Log("A: set() called."); 
    }
    
    function set1() public  virtual {
        emit Log("A: set1() called."); 
    }
}

contract B is A{
    // Overrides A.set() and explicitly calls the base contract's implementation.
    function set() public virtual override {
        emit Log("B: set() called."); 
        A.set(); 
    }
    
    function set1() public virtual override {
        emit Log("B: set1() called.");
        A.set1(); 
    }
}

contract C is B{
    // Overrides B.set() and uses 'super'.
    function set() public virtual override {
        emit Log("C: set() called.");
        super.set(); // 'super' calls the immediate parent's (B's) implementation.
    }
    
    function set1() public virtual override {
        emit Log("C: set1() called.");
        super.set1(); 
    }
}

contract D is B , C{
    // Multiple Inheritance: Must explicitly list all direct parents that implemented the function.
    function set() public override(B,C){
        emit Log("D: set() called.");
        // 'super' calls the implementation of the *last* contract in the inheritance list (C).
        super.set(); 
    }
    
    function set1() public override(B,C) {
        emit Log("D: set1() called.");
        super.set1();
    }
}
