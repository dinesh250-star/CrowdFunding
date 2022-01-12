// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;
contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline;
    uint public goal;
    uint public raisedAmount;
    struct Request {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }
    mapping(uint => Request) public requests;
    uint public numRequests;
    constructor(uint _goal,uint _deadline){
        goal = _goal;
        deadline = block.number + _deadline;
        minimumContribution = 100 wei;
        admin = msg.sender;
    }
    function contribute() public payable {
        require(block.number < deadline,"Deadline has passed");
        require(msg.value >= minimumContribution,"Minimum Contribution not met");
        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }
    receive() payable external{
        contribute();
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    function getRefund() public {
        require(block.number > deadline && raisedAmount < goal);
        require(contributors[msg.sender] > 0);
        // address payable recipient = payable(msg.sender);
        // uint value = contributors[msg.sender];
        // recipient.transfer(value);
      
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }
    modifier onlyAdmin(){
        require(msg.sender == admin,"Only admin can call");
        _;
    }
    function createRequest(string calldata _description,address payable _recipient,uint _value)public onlyAdmin{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
        
    }
}
