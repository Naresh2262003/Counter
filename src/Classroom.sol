pragma solidity ^0.8.0;

contract Classroom {
    mapping (address => uint256) public score;

    function setScore(uint256 _score) public {
        score[msg.sender]= _score;
    }

    function getScore(address _user) public view returns (uint256){
        return score[_user];
    }
}