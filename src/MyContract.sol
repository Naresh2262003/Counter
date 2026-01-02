// SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// contract Counter {
//     uint256 public number;

//     function setNumber(uint256 newNumber) public {
//         number = newNumber;
//     }

//     function increment() public {
//         number++;
//     }
// }

pragma solidity ^0.8.0;

contract MyContract {
    string private name;
    uint256 private age;
    bool private isStudent;

    function setName(string memory _name) public {
        name = _name;
    }

    function getName() public view returns (string memory) {
        return name;
    }

    function setAge(uint256 _age) public {
        // if(_age > 0){
        //     age = _age;
        // }
        // This works, BUT there is a flaw: if I send 0, the function just finishes silently. I paid for the transaction (gas), but nothing happened, and I don't get an error message telling me why.In Solidity, we use a special function called require. It checks a condition; if the condition is false, it cancels the transaction and refunds the remaining gas.

        require(_age > 0, "Age must be greater than 0");
        age = _age;
    }

    function getAge() public view returns (uint256) {
        return age;
    }

    function setStudentStatus( bool _isStudent) public {
        isStudent= _isStudent;
    }

    function getStudentStatus() public view returns(bool){
        return isStudent;
    }
}
