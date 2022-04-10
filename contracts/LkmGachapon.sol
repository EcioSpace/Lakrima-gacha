// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface ERC721_CONTRACT {
    function safeMint(address to, string memory partCode) external;
}

interface RANDOM_CONTRACT {
    function startRandom() external returns (uint256);
}

interface RANDOM_RATE {
    function getGenPool(uint16 _rarity, uint16 _number)
        external
        view
        returns (uint16);

    function getNFTPool(uint16 _number) external view returns (uint16);

    function getEquipmentPool(uint16 _number) external view returns (uint16);

    function getBlueprintPool(uint16 itemType, uint16 _number)
        external
        view
        returns (uint16);

    function getSpaceWarriorPool(uint16 _part, uint16 _number)
        external
        view
        returns (uint16);
}

contract LKMGashaOpener is Ownable {
    using Strings for string;

    uint16 private constant NFT_TYPE = 0; //Kingdom
    uint16 private constant SUITE = 5; //Battle Suit
    uint16 private constant WEAP = 8; //WEAP

    uint16 private constant BLUEPRINT_COMM = 0;
    uint16 private constant BLUEPRINT_RARE = 1;
    uint16 private constant BLUEPRINT_EPIC = 2;
    uint16 private constant BLUEPRINT_LIMITED = 8;
    uint16 private constant BLUEPRINT_LEGENDARY = 9;

    event OpenBox(address _by, string partCode);
    event ChangeRandomRateContract(address _address);
    event ChangeNftCoreContract(address _address);
    event ChangeRandomWorkerContract(address _address);
    event ChangelakrimaTokenContract(address _address);
    event ChangePoolWeapPrice(uint256 price);
    event ChangePoolSuitePrice(uint256 price);

    address public nftCoreContract;
    address public randomWorkerContract;
    address public lakrimaTokenContract;
    address public randomRateAddress;

    mapping(uint16 => uint16) private WEAP_RARITY;
    mapping(uint16 => uint16) private SUIT_RARITY;

    uint256 public weapGashaPrice = 9500 * 1e18;
    uint256 public suiteGashaPrice = 9500 * 1e18;

    enum randomType {
        SUITE,
        WEAP
    }

    constructor() {}

    function changelakrimaTokenContract(address _address) public onlyOwner {
        lakrimaTokenContract = _address;
        emit ChangelakrimaTokenContract(_address);
    }

    function changeRandomWorkerContract(address _address) public onlyOwner {
        randomWorkerContract = _address;
        emit ChangeRandomWorkerContract(_address);
    }

    function changeNftCoreContract(address _address) public onlyOwner {
        nftCoreContract = _address;
        emit ChangeNftCoreContract(_address);
    }

    //Change RandomRate type Contract

    function changeRandomRateAddress(address _address) public onlyOwner {
        randomRateAddress = _address;
        emit ChangeRandomRateContract(_address);
    }

    function changePoolWeapPrice(uint256 price) public onlyOwner {
        weapGashaPrice = price;
        emit ChangePoolWeapPrice(price);
    }

    function changePoolSuitePrice(uint256 price) public onlyOwner {
        suiteGashaPrice = price;
        emit ChangePoolSuitePrice(price);
    }

    function generateNFT(randomType _randomType) internal {
        uint256 _randomNumber = RANDOM_CONTRACT(randomWorkerContract)
            .startRandom();

        string memory _partCode = createNFTCode(_randomNumber, _randomType);
        mintNFT(msg.sender, _partCode);
        emit OpenBox(msg.sender, _partCode);
    }

    function updateWeapRarity(uint16[] memory _id, uint16 rarity)
        public
        onlyOwner
    {
        require(_id.length > 0, "ID: id length should be more than");
        for (uint16 i = 0; i < _id.length; i++) {
            WEAP_RARITY[_id[i]] = rarity;
        }
    }

    function updateSuitRarity(uint16[] memory _id, uint16 rarity)
        public
        onlyOwner
    {
        require(_id.length > 0, "ID: id length should be more than");
        for (uint16 i = 0; i < _id.length; i++) {
            SUIT_RARITY[_id[i]] = rarity;
        }
    }

    function checkWeapRarity(uint16 _id) public view returns (uint16) {
        return WEAP_RARITY[_id];
    }

    function checkSuitRarity(uint16 _id) public view returns (uint16) {
        return SUIT_RARITY[_id];
    }

    function openGasha(randomType _randomType) public {
        if (_randomType == randomType.SUITE) {
            uint256 _balance = IERC20(lakrimaTokenContract).balanceOf(
                msg.sender
            );
            require(
                _balance >= suiteGashaPrice,
                "ECIO: Your balance is insufficient."
            );
            //charge ECIO // Need Approval
            IERC20(lakrimaTokenContract).transferFrom(
                msg.sender,
                address(this),
                suiteGashaPrice
            );
            // mint NFT and random for user.
            generateNFT(_randomType);
        } else if (_randomType == randomType.WEAP) {
            uint256 _balance = IERC20(lakrimaTokenContract).balanceOf(
                msg.sender
            );
            require(
                _balance >= weapGashaPrice,
                "ECIO: Your balance is insufficient."
            );
            //charge ECIO // Need Approval
            IERC20(lakrimaTokenContract).transferFrom(
                msg.sender,
                address(this),
                suiteGashaPrice
            );
            // mint NFT and random for user.
            generateNFT(_randomType);
        }
    }

    function mintNFT(address to, string memory concatedCode) private {
        ERC721_CONTRACT _nftCore = ERC721_CONTRACT(nftCoreContract);
        _nftCore.safeMint(to, concatedCode);
    }

    function createNFTCode(uint256 _randomNumber, randomType _randomType)
        internal
        view
        returns (string memory)
    {
        string memory partCode;

        if (_randomType == randomType.SUITE) {
            uint16 equipmentRandom = getNumberAndMod(_randomNumber, 2, 1000);
            //BLUEPRINT_RARE
            uint16 ePartId = RANDOM_RATE(randomRateAddress).getBlueprintPool(
                5,
                equipmentRandom
            );

            uint16 bpRarity = checkSuitRarity(ePartId);

            partCode = createBlueprintPartCode(bpRarity, ePartId, _randomType);
        } else if (_randomType == randomType.WEAP) {
            uint16 equipmentRandom = getNumberAndMod(_randomNumber, 2, 1000);
            //BLUEPRINT_RARE
            uint16 ePartId = RANDOM_RATE(randomRateAddress).getBlueprintPool(
                8,
                equipmentRandom
            );

            uint16 bpRarity = checkWeapRarity(ePartId);

            partCode = createBlueprintPartCode(bpRarity, ePartId, _randomType);
        }
        return partCode;
    }

    function getNumberAndMod(
        uint256 _ranNum,
        uint16 digit,
        uint16 mod
    ) public view virtual returns (uint16) {
        if (digit == 1) {
            return uint16((_ranNum % 10000) % mod);
        } else if (digit == 2) {
            return uint16(((_ranNum % 100000000) / 10000) % mod);
        } else if (digit == 3) {
            return uint16(((_ranNum % 1000000000000) / 100000000) % mod);
        } else if (digit == 4) {
            return
                uint16(((_ranNum % 10000000000000000) / 1000000000000) % mod);
        } else if (digit == 5) {
            return
                uint16(
                    ((_ranNum % 100000000000000000000) / 10000000000000000) %
                        mod
                );
        } else if (digit == 6) {
            return
                uint16(
                    ((_ranNum % 1000000000000000000000000) /
                        100000000000000000000) % mod
                );
        } else if (digit == 7) {
            return
                uint16(
                    ((_ranNum % 10000000000000000000000000000) /
                        1000000000000000000000000) % mod
                );
        } else if (digit == 8) {
            return
                uint16(
                    ((_ranNum % 100000000000000000000000000000000) /
                        10000000000000000000000000000) % mod
                );
        }

        return 0;
    }

    function createBlueprintPartCode(
        uint16 bpRarity,
        uint16 equipmentPartId,
        randomType _randomType
    ) private pure returns (string memory) {
        string memory partCode;

        if (_randomType == randomType.SUITE) {
            //battleSuiteCode
            partCode = createPartCode(
                SUITE, //equipmentTypeId
                0, //combatRanksCode
                0, //WEAPCode
                0, //humanGENCode
                0, //battleBotCode
                equipmentPartId, //battleSuiteCode
                0, //battleDROCode
                0, //battleGearCode
                0, //trainingCode
                0, //kingdomCode
                bpRarity
            );
        } else if (_randomType == randomType.WEAP) {
            //BPWeaponCode
            partCode = createPartCode(
                WEAP, //equipmentTypeId
                0, //combatRanksCode
                equipmentPartId, //WEAPCode
                0, //humanGENCode
                0, //battleBotCode
                0, //battleSuiteCode
                0, //battleDROCode
                0, //battleGearCode
                0, //trainingCode
                0, //kingdomCode
                bpRarity
            );
        }

        return partCode;
    }

    function createPartCode(
        uint16 equipmentCode,
        uint16 starCode,
        uint16 weapCode,
        uint16 humanGENCode,
        uint16 battleBotCode,
        uint16 battleSuiteCode,
        uint16 battleDROCode,
        uint16 battleGearCode,
        uint16 trainingCode,
        uint16 kingdomCode,
        uint16 nftTypeCode
    ) internal pure returns (string memory) {
        string memory code = convertCodeToStr(nftTypeCode);
        code = concateCode(code, kingdomCode);
        code = concateCode(code, trainingCode);
        code = concateCode(code, battleGearCode);
        code = concateCode(code, battleDROCode);
        code = concateCode(code, battleSuiteCode);
        code = concateCode(code, battleBotCode);
        code = concateCode(code, humanGENCode);
        code = concateCode(code, weapCode);
        code = concateCode(code, starCode);
        code = concateCode(code, equipmentCode); //Reserved
        code = concateCode(code, 0); //Reserved
        code = concateCode(code, 0); //Reserved
        return code;
    }

    function concateCode(string memory concatedCode, uint256 digit)
        internal
        pure
        returns (string memory)
    {
        concatedCode = string(
            abi.encodePacked(convertCodeToStr(digit), concatedCode)
        );

        return concatedCode;
    }

    function convertCodeToStr(uint256 code)
        private
        pure
        returns (string memory)
    {
        if (code <= 9) {
            return string(abi.encodePacked("0", Strings.toString(code)));
        }

        return Strings.toString(code);
    }

    //transfer token to burn address
    function transfer(address _to, uint256 _amount) public onlyOwner {
        IERC20 _token = IERC20(lakrimaTokenContract);
        _token.transfer(_to, _amount);
    }
}
