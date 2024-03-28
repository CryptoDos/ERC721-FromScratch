// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./IERC721Reciever.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract ERC721 {
    string public name;
    string public symbol;

    uint public nextTokenIdToMint;
    address public contractOwner;

    // token id => owner
    mapping(uint => address) internal _owners;
    // owner => token count
    mapping(address => uint) internal _balances;

    // tokenId => approved address
    mapping(address => uint) internal _tokenApprovals;

    //owner => (operator=>yes/no)
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
    // token id => token uri
    mapping(uint256 => string) _tokenUris;

    // events
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        nextTokenIdToMint = 0;
        contractOwner = msg.sender;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        require(_owner != address(0), "!Add0");
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _owners[_tokenId];
    }

    function safeTransferFrom(_from, _to, _tokenId) public payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public payable {
        require(
            ownerOf(_tokenId) == msg.sender ||
                _tokenApprovals[_tokenId] == msg.sender ||
                _operatorApprovals[ownerOf[_tokenId][msg.sender]],
            "!Auth"
        );
        _transfer(from, to, _tokenId);
        //trigger func check
        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "!ERC721Implementer"
        );
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable {
        require(
            ownerOf(_tokenId) == msg.sender ||
                _tokenApprovals[_tokenId] == msg.sender ||
                _operatorApprovals[ownerOf[_tokenId][msg.sender]],
            "!Auth"
        );
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) public payable {
        require(ownerOf(_tokenId) == msg.sender, "!Owner");
        _tokenApprovals[_tokenId] = approved;
        emit Approval(_owner(_tokenId), _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return _tokenApprovals[_tokenId];
    }

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function mintTo(address _to, string memory _uri) public {
        require(contractOwner == msg.sender, "!Auth");
        _owners[nextTokenIdToMint] = _to;
        _balances[_to] += 1;
        _tokenUris[nextTokenIdToMint] = _uri;
        emit Transfer(address(0), _to, _tokenId);
        nextTokenIdToMint += 1;
    }

    function _tokenUri(uint256 _tokenId) public view returns (string) {
        return _tokenUris[_tokenId];
    }

    function totalSupply() public view returns (uint256) {
        return nextTokenIdToMint;
    }

    //Internal function
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length > 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _transfer(address from, address to, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == from, "!Owner");
        require(_to != address(0), "!ToAdd0");
        delete _tokenApprovals[_tokenId];
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }
}
