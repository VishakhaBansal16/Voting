//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 < 0.8.0;
contract Ballot{
    struct vote{
        address voterAddress;
        string choice; // yes, no or not interested
    }
    struct voter{
        string voterName;
        bool voted;
    }
    uint private countResult=0;
    uint public finalResult=0;
    uint public totalVoter=0;
    uint public totalVote=0;
    address public ballotOfficialAddress;
    string public ballotOfficialName;
    string public proposal;
    mapping(uint => vote) private votes;
    mapping (address => voter) public voterRegister;
    enum State{
        Created,
        Voting,
        Ended
    }
    State public state;
    modifier condition(bool _condition){
        require(_condition);
        _;
    }
    modifier onlyOfficial(){
        require(msg.sender==ballotOfficialAddress);
        _;
    }
    modifier inState(State _state){
        require(state==_state);
        _;
    }
    constructor(
        string memory _ballotOfficialName,
        string memory _proposal
    ){
        ballotOfficialAddress=msg.sender;
        ballotOfficialName=_ballotOfficialName;
        proposal=_proposal;
        state=State.Created;
    }
    
    function addVoter(
        address _voterAddress,
        string memory _voterName
    ) public
      inState(State.Created)
      onlyOfficial
      {
          voter memory v;
          v.voterName=_voterName;
          v.voted=false;
          voterRegister[_voterAddress]=v;
          totalVoter++;
      }
    
    function startVote() 
    public 
    inState(State.Created)
    onlyOfficial
    {
      state=State.Voting;
    }

    function doVote(string memory _choice)
    public inState(State.Voting)
    returns(bool voted)
    {
        bool isFound=false;
        if(bytes(voterRegister[msg.sender].voterName).length!=0 && voterRegister[msg.sender].voted == false)
        {
            voterRegister[msg.sender].voted=true;
            vote memory v;
            v.voterAddress =msg.sender;
            v.choice=_choice;
            if(keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked("yes"))){
                countResult++;
            }
            votes[totalVote]=v;
            totalVote++;
            isFound=true;
        }
        return isFound;
    }
    
    function endVote()
     public
     inState(State.Voting)
     onlyOfficial
     {
        state=State.Ended;
        finalResult=countResult;
     }
} 