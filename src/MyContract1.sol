pragma solidity ^0.8.0;

contract MyContract {
    string private name;
    uint256 private age;
    bool private status;

    event NameChanged(string oldname, string newname);
    event AgeChanged(address owner, uint256 newage);
    event StatusChanged( bool newstatus);

    event AgeReset(address user, uint256 previousage);

    function setName(string memory _name) public{
        string memory previousName = name;
        name = _name;
        emit NameChanged(previousName, _name);
    }

    function resetAge() public {
        // Check current state, not input
        require(age != 0, "Age is already 0, nothing to reset");
        
        uint256 previousAge = age;
        age = 0; // Hardcode the reset
        
        emit AgeReset(msg.sender, previousAge);
    }

    function setAge(uint256 _age) public{
        age = _age;
        emit AgeChanged(msg.sender, _age);
    }

    function setStatus(bool _status) public{
        status = _status;
        emit StatusChanged(_status);
    }

}