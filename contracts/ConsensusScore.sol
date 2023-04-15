// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ConsensusScore {
  struct PubKey {
    string n;
    string g;
  }
  struct AccumulatedScore {
    string sum;
    string count;
  }

  struct Score {
    bool isCreated;
    string encryptedSum;
    string encryptedCount;
    string proof;
    uint32 value;
    uint32 rem;
  }

  mapping(address => PubKey) private _pubKeys;
  mapping(address => AccumulatedScore) private _accumulatedScores;
  mapping(address => Score) private _scores;

  // validity of a public key is defined by having both n and g.
  // this also works as a membership check
  // because register() method is the only way to set a valid public key
  // and keys are valid after and only after registration.
  function hasValidKey(address addr) public view returns (bool) {
    return bytes(_pubKeys[addr].n).length > 0
      && bytes(_pubKeys[addr].g).length > 0;
  }

  // only this method can register a new user.
  // the membership is defined by eigher having a valid public key or not.
  function register(string memory n, string memory g) public {
    require(!hasValidKey(msg.sender), 'Already registered');
    _pubKeys[msg.sender] = PubKey(n, g);
    _accumulatedScores[msg.sender] = AccumulatedScore(g, g);  // zero, zero
  }

  function fetchPubKey(address addr) public view returns (string memory, string memory) {
    require(hasValidKey(addr), 'User is not registered');
    return (_pubKeys[addr].n, _pubKeys[addr].g);
  }
  function fetchAccumulatedScore(address addr) public view returns (string memory, string memory) {
    require(hasValidKey(addr), 'User is not registered');
    return (_accumulatedScores[addr].sum, _accumulatedScores[addr].count);
  }
  // TODO: many...(and not sure if these are possible)
  //  1. addition must be performed on-chain to ensure score is added on the previous score
  //     (now, the added score is supposed to be calculated off-chain)
  //  2. we may need big-number library to perform addition
  //  3. we need to verify that the new score is encrypted with the public key of the evaluated user
  //    (...but verification contract seems to support only uint integers... not big numbers used for encryption...)
  //  4. additional control may necessary when the evaluation is the second or more time
  //     (for example, subtract the previous evaluation before the addition...?)
  function updateEncryptedScore(address addr, string memory encryptedSum, string memory encryptedCount) public {
    require(hasValidKey(addr), 'User is not registered');
    require(hasValidKey(msg.sender), 'Only registered users can update scores');
    _accumulatedScores[addr].sum = encryptedSum;
    _accumulatedScores[addr].count = encryptedCount;
  }
  // TODO:
  //  score must be verified...
  function updateScore(
    string memory encryptedSum, 
    string memory encryptedCount, 
    string memory proof, 
    uint32 value,
    uint32 rem
  ) public {
    require(hasValidKey(msg.sender), 'User is not registered');
    _scores[msg.sender] = Score({
      isCreated: true,
      encryptedSum: encryptedSum,
      encryptedCount: encryptedCount, 
      proof: proof, 
      value: value, 
      rem: rem
    });
  }
  function getScore(address addr) public view returns (
    string memory, 
    string memory, 
    string memory, 
    uint32, 
    uint32
  ) {
    require(hasValidKey(addr), 'User is not registered');
    require(_scores[addr].isCreated, 'Score is not created');
    Score memory score = _scores[addr];
    return (
      score.encryptedSum, 
      score.encryptedCount, 
      score.proof, 
      score.value, 
      score.rem
    );
  }
}
