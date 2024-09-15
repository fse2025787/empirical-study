// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 
pragma solidity ^0.7.4;




interface IBMICoverStakingView {
    function getPolicyBookAPY(address policyBookAddress, uint256 bmiPriceInUSDT)
        external
        view
        returns (uint256);

    function policyBookByNFT(uint256 tokenId) external view returns (address);

    function stakingInfoByStaker(
        address staker,
        address[] calldata policyBooksAddresses,
        uint256 bmiPriceInUSDT,
        uint256 offset,
        uint256 limit
    )
        external
        view
        returns (
            IBMICoverStaking.PolicyBookInfo[] memory policyBooksInfo,
            IBMICoverStaking.UserInfo[] memory usersInfo,
            uint256[] memory nftsCount,
            IBMICoverStaking.NFTsInfo[][] memory nftsInfo
        );

    function stakingInfoByToken(uint256 tokenId)
        external
        view
        returns (IBMICoverStaking.StakingInfo memory);

    // Not Migratable
    // function totalStaked(address user) external view returns (uint256);
    // function totalStakedSTBL(address user) external view returns (uint256);
    // function getStakerBMIProfit(address staker, address policyBookAddress, uint256 offset, uint256 limit) external view returns (uint256) ;
    // function getSlashedBMIProfit(uint256 tokenId) external view returns (uint256);
    // function getBMIProfit(uint256 tokenId) external view returns (uint256);
    // function uri(uint256 tokenId) external view returns (string memory);
    // function tokenOfOwnerByIndex(address user, uint256 index) external view returns (uint256);
    // function ownerOf(uint256 tokenId) external view returns (address);
    // function getSlashingPercentage() external view returns (uint256);
    // function getSlashedStakerBMIProfit( address staker, address policyBookAddress, uint256 offset, uint256 limit) external view returns (uint256 totalProfit) ;
    // function balanceOf(address user) external view returns (uint256);
    // function _aggregateForEach( address staker, address policyBookAddress, uint256 offset, uint256 limit, function(uint256) view returns (uint256) func) internal view returns (uint256 total);
    // function stakedByNFT(uint256 tokenId) external view returns (uint256);
    // function stakedSTBLByNFT(uint256 tokenId) external view returns (uint256);
}

// 
pragma solidity ^0.7.4;



abstract contract AbstractDependant {
    
    bytes32 private constant _INJECTOR_SLOT =
        0xd6b8f2e074594ceb05d47c27386969754b6ad0c15e5eb8f691399cd0be980e76;

    modifier onlyInjectorOrZero() {
        address _injector = injector();

        require(_injector == address(0) || _injector == msg.sender, "Dependant: Not an injector");
        _;
    }

    function setInjector(address _injector) external onlyInjectorOrZero {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            sstore(slot, _injector)
        }
    }

    
    function setDependencies(IContractsRegistry) external virtual;

    function injector() public view returns (address _injector) {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            _injector := sload(slot)
        }
    }
}
// 
pragma solidity ^0.7.4;
















contract BMICoverStakingView is IBMICoverStakingView, AbstractDependant {
    using SafeMath for uint256;
    using Math for uint256;

    IBMICoverStaking public bmiCoverStaking;
    IRewardsGenerator public rewardsGenerator;
    ILiquidityMining public liquidityMining;

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        rewardsGenerator = IRewardsGenerator(_contractsRegistry.getRewardsGeneratorContract());
        bmiCoverStaking = IBMICoverStaking(_contractsRegistry.getBMICoverStakingContract());
    }

    
    
    
    
    function getPolicyBookAPY(address policyBookAddress, uint256 bmiPriceInUSDT)
        public
        view
        override
        returns (uint256)
    {
        require(bmiPriceInUSDT > 0, "Invalid BMI price");
        return
            IPolicyBook(policyBookAddress).whitelisted()
                ? rewardsGenerator.getPolicyBookAPY(policyBookAddress, bmiPriceInUSDT)
                : 0;
    }

    
    
    
    function policyBookByNFT(uint256 tokenId) external view override returns (address) {
        (address policyBookAddress, ) = bmiCoverStaking._stakersPool(tokenId);
        return policyBookAddress;
    }

    
    
    
    
    
    
    
    
    
    ///     (nftIndex, uri, stakedBMIXAmount, stakedSTBLAmount, reward (in BMI))
    function stakingInfoByStaker(
        address staker,
        address[] calldata policyBooksAddresses,
        uint256 bmiPriceInUSDT,
        uint256 offset,
        uint256 limit
    )
        external
        view
        override
        returns (
            IBMICoverStaking.PolicyBookInfo[] memory policyBooksInfo,
            IBMICoverStaking.UserInfo[] memory usersInfo,
            uint256[] memory nftsCount,
            IBMICoverStaking.NFTsInfo[][] memory nftsInfo
        )
    {
        uint256 to = (offset.add(limit)).min(bmiCoverStaking.balanceOf(staker)).max(offset);

        policyBooksInfo = new IBMICoverStaking.PolicyBookInfo[](policyBooksAddresses.length);
        usersInfo = new IBMICoverStaking.UserInfo[](policyBooksAddresses.length);
        nftsCount = new uint256[](policyBooksAddresses.length);
        nftsInfo = new IBMICoverStaking.NFTsInfo[][](policyBooksAddresses.length);

        for (uint256 i = 0; i < policyBooksAddresses.length; i++) {
            nftsInfo[i] = new IBMICoverStaking.NFTsInfo[](to - offset);

            policyBooksInfo[i] = IBMICoverStaking.PolicyBookInfo(
                rewardsGenerator.getStakedPolicyBookSTBL(policyBooksAddresses[i]),
                rewardsGenerator.getPolicyBookRewardPerBlock(policyBooksAddresses[i]),
                getPolicyBookAPY(policyBooksAddresses[i], bmiPriceInUSDT),
                IPolicyBook(policyBooksAddresses[i]).getAPY()
            );

            for (uint256 j = offset; j < to; j++) {
                uint256 nftIndex = bmiCoverStaking.tokenOfOwnerByIndex(staker, j);
                (address policyBookAddress, uint256 stakedBMIXAmount) =
                    bmiCoverStaking._stakersPool(nftIndex);

                if (policyBookAddress == policyBooksAddresses[i]) {
                    nftsInfo[i][nftsCount[i]] = IBMICoverStaking.NFTsInfo(
                        nftIndex,
                        bmiCoverStaking.uri(nftIndex),
                        stakedBMIXAmount,
                        rewardsGenerator.getStakedNFTSTBL(nftIndex),
                        bmiCoverStaking.getBMIProfit(nftIndex)
                    );

                    usersInfo[i].totalStakedBMIX = usersInfo[i].totalStakedBMIX.add(
                        nftsInfo[i][nftsCount[i]].stakedBMIXAmount
                    );
                    usersInfo[i].totalStakedSTBL = usersInfo[i].totalStakedSTBL.add(
                        nftsInfo[i][nftsCount[i]].stakedSTBLAmount
                    );
                    usersInfo[i].totalBmiReward = usersInfo[i].totalBmiReward.add(
                        nftsInfo[i][nftsCount[i]].reward
                    );

                    nftsCount[i]++;
                }
            }
        }
    }

    
    
    
    function stakingInfoByToken(uint256 tokenId)
        external
        view
        override
        returns (IBMICoverStaking.StakingInfo memory _stakingInfo)
    {
        (_stakingInfo.policyBookAddress, _stakingInfo.stakedBMIXAmount) = bmiCoverStaking
            ._stakersPool(tokenId);
        require(_stakingInfo.policyBookAddress != address(0), "BDS: Token doesn't exist");
    }
}

// 
pragma solidity ^0.7.4;


interface IRewardsGenerator {
    struct PolicyBookRewardInfo {
        uint256 rewardMultiplier; // includes 5 decimal places
        uint256 totalStaked;
        uint256 lastUpdateBlock;
        uint256 lastCumulativeSum; // includes 100 percentage
        uint256 cumulativeReward; // includes 100 percentage
    }

    struct StakeRewardInfo {
        uint256 lastCumulativeSum; // includes 100 percentage
        uint256 cumulativeReward;
        uint256 stakeAmount;
    }

    
    function updatePolicyBookShare(
        uint256 newRewardMultiplier,
        address policyBook,
        bool isStablecoin
    ) external;

    
    function aggregate(
        address policyBookAddress,
        uint256[] calldata nftIndexes,
        uint256 nftIndexTo
    ) external;

    
    function stake(
        address policyBookAddress,
        uint256 nftIndex,
        uint256 amount
    ) external;

    
    function getPolicyBookAPY(address policyBookAddress, uint256 bmiPriceInUSDT)
        external
        view
        returns (uint256);

    
    function getPolicyBookRewardMultiplier(address policyBookAddress)
        external
        view
        returns (uint256);

    
    function getPolicyBookRewardPerBlock(address policyBookAddress)
        external
        view
        returns (uint256);

    
    function getStakedPolicyBookSTBL(address policyBookAddress) external view returns (uint256);

    
    function getStakedNFTSTBL(uint256 nftIndex) external view returns (uint256);

    
    function getReward(address policyBookAddress, uint256 nftIndex)
        external
        view
        returns (uint256);

    
    function withdrawFunds(address policyBookAddress, uint256 nftIndex) external returns (uint256);

    
    function withdrawReward(address policyBookAddress, uint256 nftIndex)
        external
        returns (uint256);
}

// 
pragma solidity ^0.7.4;





interface IPolicyBookFacade {
    
    
    
    function buyPolicy(uint256 _epochsNumber, uint256 _coverTokens) external;

    
    
    
    function buyPolicyFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external;

    function policyBook() external view returns (IPolicyBook);

    function userLiquidity(address account) external view returns (uint256);

    
    function forceUpdateBMICoverStakingRewardMultiplier() external;

    
    
    
    
    
    
    function getPolicyPrice(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _buyer
    )
        external
        view
        returns (
            uint256 totalSeconds,
            uint256 totalPrice,
            uint256 pricePercentage
        );

    function secondsToEndCurrentEpoch() external view returns (uint256);

    
    function VUreinsurnacePool() external view returns (uint256);

    
    function LUreinsurnacePool() external view returns (uint256);

    
    function LUuserLeveragePool(address userLeveragePool) external view returns (uint256);

    
    function totalLeveragedLiquidity() external view returns (uint256);

    function userleveragedMPL() external view returns (uint256);

    function reinsurancePoolMPL() external view returns (uint256);

    function rebalancingThreshold() external view returns (uint256);

    function safePricingModel() external view returns (bool);

    
    
    function __PolicyBookFacade_init(
        address pbProxy,
        address liquidityProvider,
        uint256 initialDeposit
    ) external;

    
    
    
    function buyPolicyFromDistributor(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external;

    
    
    
    
    function buyPolicyFromDistributorFor(
        address _buyer,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external;

    
    
    function addLiquidity(uint256 _liquidityAmount) external;

    
    
    
    function addLiquidityFromDistributorFor(address _user, uint256 _liquidityAmount) external;

    function addLiquidityAndStakeFor(
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external;

    
    
    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount) external;

    
    function withdrawLiquidity() external;

    
    
    
    function deployLeverageFundsAfterRebalance(
        uint256 deployedAmount,
        ILeveragePortfolio.LeveragePortfolio leveragePool
    ) external;

    
    
    function deployVirtualFundsAfterRebalance(uint256 deployedAmount) external;

    
    function reevaluateProvidedLeverageStable() external;

    
    
    
    function setMPLs(uint256 _userLeverageMPL, uint256 _reinsuranceLeverageMPL) external;

    
    
    function setRebalancingThreshold(uint256 _newRebalancingThreshold) external;

    
    
    function setSafePricingModel(bool _safePricingModel) external;

    
    function getClaimApprovalAmount(address user) external view returns (uint256);

    
    
    
    function requestWithdrawal(uint256 _tokensToWithdraw) external;

    function listUserLeveragePools(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _userLeveragePools);

    function countUserLeveragePools() external view returns (uint256);

    
    
    
    
    
    function info()
        external
        view
        returns (
            string memory _symbol,
            address _insuredContract,
            IPolicyBookFabric.ContractType _contractType,
            bool _whitelisted
        );
}

// 
pragma solidity ^0.7.4;

interface IPolicyBookFabric {
    enum ContractType {CONTRACT, STABLECOIN, SERVICE, EXCHANGE, VARIOUS}

    
    
    
    
    
    
    
    function create(
        address _contract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol,
        uint256 _initialDeposit,
        address _shieldMiningToken
    ) external returns (address);

    function createLeveragePools(
        address _insuranceContract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external returns (address);
}

// 
pragma solidity ^0.7.4;






interface IPolicyBook {
    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    struct PolicyHolder {
        uint256 coverTokens;
        uint256 startEpochNumber;
        uint256 endEpochNumber;
        uint256 paid;
        uint256 reinsurancePrice;
    }

    struct WithdrawalInfo {
        uint256 withdrawalAmount;
        uint256 readyToWithdrawDate;
        bool withdrawalAllowed;
    }

    struct BuyPolicyParameters {
        address buyer;
        address holder;
        uint256 epochsNumber;
        uint256 coverTokens;
        uint256 distributorFee;
        address distributor;
    }

    function policyHolders(address _holder)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function policyBookFacade() external view returns (IPolicyBookFacade);

    function setPolicyBookFacade(address _policyBookFacade) external;

    function EPOCH_DURATION() external view returns (uint256);

    function stblDecimals() external view returns (uint256);

    function READY_TO_WITHDRAW_PERIOD() external view returns (uint256);

    function whitelisted() external view returns (bool);

    function epochStartTime() external view returns (uint256);

    // @TODO: should we let DAO to change contract address?
    
    
    function insuranceContractAddress() external view returns (address _contract);

    
    
    function contractType() external view returns (IPolicyBookFabric.ContractType _type);

    function totalLiquidity() external view returns (uint256);

    function totalCoverTokens() external view returns (uint256);

    // 
    // function userleveragedMPL() external view returns (uint256);

    // 
    // function reinsurancePoolMPL() external view returns (uint256);

    // function bmiRewardMultiplier() external view returns (uint256);

    function withdrawalsInfo(address _userAddr)
        external
        view
        returns (
            uint256 _withdrawalAmount,
            uint256 _readyToWithdrawDate,
            bool _withdrawalAllowed
        );

    function __PolicyBook_init(
        address _insuranceContract,
        IPolicyBookFabric.ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external;

    function whitelist(bool _whitelisted) external;

    function getEpoch(uint256 time) external view returns (uint256);

    
    function convertBMIXToSTBL(uint256 _amount) external view returns (uint256);

    
    function convertSTBLToBMIX(uint256 _amount) external view returns (uint256);

    
    function submitClaimAndInitializeVoting(string calldata evidenceURI) external;

    
    function submitAppealAndInitializeVoting(string calldata evidenceURI) external;

    
    function commitClaim(
        address claimer,
        uint256 claimEndTime,
        IClaimingRegistry.ClaimStatus status
    ) external;

    
    function commitWithdrawnClaim(address claimer) external;

    
    function getNewCoverAndLiquidity()
        external
        view
        returns (uint256 newTotalCoverTokens, uint256 newTotalLiquidity);

    
    
    
    
    
    
    
    function buyPolicy(
        address _buyer,
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        uint256 _distributorFee,
        address _distributor
    ) external returns (uint256, uint256);

    
    function endActivePolicy(address _holder) external;

    function updateEpochsInfo() external;

    
    
    
    function addLiquidityFor(address _liquidityHolderAddr, uint256 _liqudityAmount) external;

    
    
    
    
    
    function addLiquidity(
        address _liquidityBuyerAddr,
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external returns (uint256);

    function getAvailableBMIXWithdrawableAmount(address _userAddr) external view returns (uint256);

    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);

    function requestWithdrawal(uint256 _tokensToWithdraw, address _user) external;

    // function requestWithdrawalWithPermit(
    //     uint256 _tokensToWithdraw,
    //     uint8 _v,
    //     bytes32 _r,
    //     bytes32 _s
    // ) external;

    function unlockTokens() external;

    
    function withdrawLiquidity(address sender)
        external
        returns (uint256 _tokensToWithdraw, uint256 _stblTokensToWithdraw);

    
    function updateLiquidity(uint256 _newLiquidity) external;

    function getAPY() external view returns (uint256);

    
    function userStats(address _user) external view returns (PolicyHolder memory);

    
    
    
    
    
    
    
    
    function numberStats()
        external
        view
        returns (
            uint256 _maxCapacities,
            uint256 _buyPolicyCapacity,
            uint256 _totalSTBLLiquidity,
            uint256 _totalLeveragedLiquidity,
            uint256 _stakedSTBL,
            uint256 _annualProfitYields,
            uint256 _annualInsuranceCost,
            uint256 _bmiXRatio
        );
}

// 
pragma solidity ^0.7.4;


interface ILiquidityMining {
    struct TeamDetails {
        string teamName;
        address referralLink;
        uint256 membersNumber;
        uint256 totalStakedAmount;
        uint256 totalReward;
    }

    struct UserInfo {
        address userAddr;
        string teamName;
        uint256 stakedAmount;
        uint256 mainNFT; // 0 or NFT index if available
        uint256 platinumNFT; // 0 or NFT index if available
    }

    struct UserRewardsInfo {
        string teamName;
        uint256 totalBMIReward; // total BMI reward
        uint256 availableBMIReward; // current claimable BMI reward
        uint256 incomingPeriods; // how many month are incoming
        uint256 timeToNextDistribution; // exact time left to next distribution
        uint256 claimedBMI; // actual number of claimed BMI
        uint256 mainNFTAvailability; // 0 or NFT index if available
        uint256 platinumNFTAvailability; // 0 or NFT index if available
        bool claimedNFTs; // true if user claimed NFTs
    }

    struct MyTeamInfo {
        TeamDetails teamDetails;
        uint256 myStakedAmount;
        uint256 teamPlace;
    }

    struct UserTeamInfo {
        address teamAddr;
        uint256 stakedAmount;
        uint256 countOfRewardedMonth;
        bool isNFTDistributed;
    }

    struct TeamInfo {
        string name;
        uint256 totalAmount;
        address[] teamLeaders;
    }

    function startLiquidityMiningTime() external view returns (uint256);

    function getTopTeams() external view returns (TeamDetails[] memory teams);

    function getTopUsers() external view returns (UserInfo[] memory users);

    function getAllTeamsLength() external view returns (uint256);

    function getAllTeamsDetails(uint256 _offset, uint256 _limit)
        external
        view
        returns (TeamDetails[] memory _teamDetailsArr);

    function getMyTeamsLength() external view returns (uint256);

    function getMyTeamMembers(uint256 _offset, uint256 _limit)
        external
        view
        returns (address[] memory _teamMembers, uint256[] memory _memberStakedAmount);

    function getAllUsersLength() external view returns (uint256);

    function getAllUsersInfo(uint256 _offset, uint256 _limit)
        external
        view
        returns (UserInfo[] memory _userInfos);

    function getMyTeamInfo() external view returns (MyTeamInfo memory _myTeamInfo);

    function getRewardsInfo(address user)
        external
        view
        returns (UserRewardsInfo memory userRewardInfo);

    function createTeam(string calldata _teamName) external;

    function deleteTeam() external;

    function joinTheTeam(address _referralLink) external;

    function getSlashingPercentage() external view returns (uint256);

    function investSTBL(uint256 _tokensAmount, address _policyBookAddr) external;

    function distributeNFT() external;

    function checkPlatinumNFTReward(address _userAddr) external view returns (uint256);

    function checkMainNFTReward(address _userAddr) external view returns (uint256);

    function distributeBMIReward() external;

    function getTotalUserBMIReward(address _userAddr) external view returns (uint256);

    function checkAvailableBMIReward(address _userAddr) external view returns (uint256);

    
    
    function isLMLasting() external view returns (bool);

    
    
    function isLMEnded() external view returns (bool);

    function getEndLMTime() external view returns (uint256);
}

// 
pragma solidity ^0.7.4;

interface ILeveragePortfolio {
    enum LeveragePortfolio {USERLEVERAGEPOOL, REINSURANCEPOOL}
    struct LevFundsFactors {
        uint256 netMPL;
        uint256 netMPLn;
        address policyBookAddr;
    }

    function targetUR() external view returns (uint256);

    function d_ProtocolConstant() external view returns (uint256);

    function a_ProtocolConstant() external view returns (uint256);

    function max_ProtocolConstant() external view returns (uint256);

    
    
    function deployLeverageStableToCoveragePools(LeveragePortfolio leveragePoolType)
        external
        returns (uint256);

    
    function deployVirtualStableToCoveragePools() external returns (uint256);

    
    
    function setRebalancingThreshold(uint256 threshold) external;

    
    
    
    
    
    function setProtocolConstant(
        uint256 _targetUR,
        uint256 _d_ProtocolConstant,
        uint256 _a1_ProtocolConstant,
        uint256 _max_ProtocolConstant
    ) external;

    
    
    
    //function calcM(uint256 poolUR) external returns (uint256);

    
    function totalLiquidity() external view returns (uint256);

    
    /// add the 20% of premium + portion of 80% of premium where reisnurance pool participate in coverage pools (vStable)  : access policybook
    
    
    function addPolicyPremium(uint256 epochsNumber, uint256 premiumAmount) external;

    
    
    function listleveragedCoveragePools(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _coveragePools);

    
    function countleveragedCoveragePools() external view returns (uint256);

    function updateLiquidity(uint256 _lostLiquidity) external;

    function forceUpdateBMICoverStakingRewardMultiplier() external;
}

// 
pragma solidity ^0.7.4;


interface IContractsRegistry {
    function getAMMRouterContract() external view returns (address);

    function getAMMBMIToETHPairContract() external view returns (address);

    function getAMMBMIToUSDTPairContract() external view returns (address);

    function getSushiSwapMasterChefV2Contract() external view returns (address);

    function getWrappedTokenContract() external view returns (address);

    function getUSDTContract() external view returns (address);

    function getBMIContract() external view returns (address);

    function getPriceFeedContract() external view returns (address);

    function getPolicyBookRegistryContract() external view returns (address);

    function getPolicyBookFabricContract() external view returns (address);

    function getBMICoverStakingContract() external view returns (address);

    function getBMICoverStakingViewContract() external view returns (address);

    function getBMITreasury() external view returns (address);

    function getRewardsGeneratorContract() external view returns (address);

    function getBMIUtilityNFTContract() external view returns (address);

    function getNFTStakingContract() external view returns (address);

    function getLiquidityBridgeContract() external view returns (address);

    function getClaimingRegistryContract() external view returns (address);

    function getPolicyRegistryContract() external view returns (address);

    function getLiquidityRegistryContract() external view returns (address);

    function getClaimVotingContract() external view returns (address);

    function getReinsurancePoolContract() external view returns (address);

    function getLeveragePortfolioViewContract() external view returns (address);

    function getCapitalPoolContract() external view returns (address);

    function getPolicyBookAdminContract() external view returns (address);

    function getPolicyQuoteContract() external view returns (address);

    function getBMIStakingContract() external view returns (address);

    function getSTKBMIContract() external view returns (address);

    function getStkBMIStakingContract() external view returns (address);

    function getVBMIContract() external view returns (address);

    function getLiquidityMiningStakingETHContract() external view returns (address);

    function getLiquidityMiningStakingUSDTContract() external view returns (address);

    function getReputationSystemContract() external view returns (address);

    function getDefiProtocol1Contract() external view returns (address);

    function getAaveLendPoolAddressProvdierContract() external view returns (address);

    function getAaveATokenContract() external view returns (address);

    function getDefiProtocol2Contract() external view returns (address);

    function getCompoundCTokenContract() external view returns (address);

    function getCompoundComptrollerContract() external view returns (address);

    function getDefiProtocol3Contract() external view returns (address);

    function getYearnVaultContract() external view returns (address);

    function getYieldGeneratorContract() external view returns (address);

    function getShieldMiningContract() external view returns (address);
}

// 
pragma solidity ^0.7.4;




interface IClaimingRegistry {
    enum ClaimStatus {
        CAN_CLAIM,
        UNCLAIMABLE,
        PENDING,
        AWAITING_CALCULATION,
        REJECTED_CAN_APPEAL,
        REJECTED,
        ACCEPTED,
        EXPIRED
    }

    struct ClaimInfo {
        address claimer;
        address policyBookAddress;
        string evidenceURI;
        uint256 dateSubmitted;
        uint256 dateEnded;
        bool appeal;
        ClaimStatus status;
        uint256 claimAmount;
        uint256 claimRefund;
    }

    struct ClaimWithdrawalInfo {
        uint256 readyToWithdrawDate;
        bool committed;
    }

    struct RewardWithdrawalInfo {
        uint256 rewardAmount;
        uint256 readyToWithdrawDate;
    }

    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    function claimWithdrawalInfo(uint256 index)
        external
        view
        returns (uint256 readyToWithdrawDate, bool committed);

    function rewardWithdrawalInfo(address voter)
        external
        view
        returns (uint256 rewardAmount, uint256 readyToWithdrawDate);

    
    function anonymousVotingDuration(uint256 index) external view returns (uint256);

    
    function votingDuration(uint256 index) external view returns (uint256);

    
    function validityDuration(uint256 index) external view returns (uint256);

    
    function anyoneCanCalculateClaimResultAfter(uint256 index) external view returns (uint256);

    function canCalculateClaim(uint256 index, address calculator) external view returns (bool);

    
    function canBuyNewPolicy(address buyer, address policyBookAddress) external;

    
    function getClaimWithdrawalStatus(uint256 index) external view returns (WithdrawalStatus);

    
    function getRewardWithdrawalStatus(address voter) external view returns (WithdrawalStatus);

    
    function hasProcedureOngoing(address poolAddress) external view returns (bool);

    
    function submitClaim(
        address user,
        address policyBookAddress,
        string calldata evidenceURI,
        uint256 cover,
        bool appeal
    ) external returns (uint256);

    
    function claimExists(uint256 index) external view returns (bool);

    
    function claimSubmittedTime(uint256 index) external view returns (uint256);

    
    function claimEndTime(uint256 index) external view returns (uint256);

    
    function isClaimAnonymouslyVotable(uint256 index) external view returns (bool);

    
    function isClaimExposablyVotable(uint256 index) external view returns (bool);

    
    function isClaimVotable(uint256 index) external view returns (bool);

    
    function canClaimBeCalculatedByAnyone(uint256 index) external view returns (bool);

    
    function isClaimPending(uint256 index) external view returns (bool);

    
    function countPolicyClaimerClaims(address user) external view returns (uint256);

    
    function countPendingClaims() external view returns (uint256);

    
    function countClaims() external view returns (uint256);

    
    function claimOfOwnerIndexAt(address claimer, uint256 orderIndex)
        external
        view
        returns (uint256);

    
    function pendingClaimIndexAt(uint256 orderIndex) external view returns (uint256);

    
    function claimIndexAt(uint256 orderIndex) external view returns (uint256);

    
    function claimIndex(address claimer, address policyBookAddress)
        external
        view
        returns (uint256);

    
    function isClaimAppeal(uint256 index) external view returns (bool);

    
    function policyStatus(address claimer, address policyBookAddress)
        external
        view
        returns (ClaimStatus);

    
    function claimStatus(uint256 index) external view returns (ClaimStatus);

    
    function claimOwner(uint256 index) external view returns (address);

    
    function claimPolicyBook(uint256 index) external view returns (address);

    
    function claimInfo(uint256 index) external view returns (ClaimInfo memory _claimInfo);

    function getAllPendingClaimsAmount(uint256 _limit)
        external
        view
        returns (uint256 _totalClaimsAmount);

    function getAllPendingRewardsAmount(uint256 _limit)
        external
        view
        returns (uint256 _totalRewardsAmount);

    function getClaimableAmounts(uint256[] memory _claimIndexes) external view returns (uint256);

    function getBMIRewardForCalculation(uint256 index) external view returns (uint256);

    
    function acceptClaim(uint256 index, uint256 amount) external;

    
    function rejectClaim(uint256 index) external;

    
    function expireClaim(uint256 index) external;

    
    ///         or offensive.
    
    
    
    function updateImageUriOfClaim(uint256 claim_Index, string calldata _newEvidenceURI) external;

    function requestClaimWithdrawal(uint256 index) external;

    function requestRewardWithdrawal(address voter, uint256 rewardAmount) external;

    function getWithdrawClaimRequestIndexListCount() external view returns (uint256);

    function getWithdrawRewardRequestVoterListCount() external view returns (uint256);
}

// 
pragma solidity ^0.7.4;


interface IBMICoverStaking {
    struct StakingInfo {
        address policyBookAddress;
        uint256 stakedBMIXAmount;
    }

    struct PolicyBookInfo {
        uint256 totalStakedSTBL;
        uint256 rewardPerBlock;
        uint256 stakingAPY;
        uint256 liquidityAPY;
    }

    struct UserInfo {
        uint256 totalStakedBMIX;
        uint256 totalStakedSTBL;
        uint256 totalBmiReward;
    }

    struct NFTsInfo {
        uint256 nftIndex;
        string uri;
        uint256 stakedBMIXAmount;
        uint256 stakedSTBLAmount;
        uint256 reward;
    }

    function aggregateNFTs(address policyBookAddress, uint256[] calldata tokenIds) external;

    function stakeBMIX(uint256 amount, address policyBookAddress) external;

    function stakeBMIXWithPermit(
        uint256 bmiXAmount,
        address policyBookAddress,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function stakeBMIXFrom(address user, uint256 amount) external;

    function stakeBMIXFromWithPermit(
        address user,
        uint256 bmiXAmount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    // mappings

    function _stakersPool(uint256 index)
        external
        view
        returns (address policyBookAddress, uint256 stakedBMIXAmount);

    // function getPolicyBookAPY(address policyBookAddress) external view returns (uint256);

    function restakeBMIProfit(uint256 tokenId) external;

    function restakeStakerBMIProfit(address policyBookAddress) external;

    function withdrawBMIProfit(uint256 tokenID) external;

    function withdrawStakerBMIProfit(address policyBookAddress) external;

    function withdrawFundsWithProfit(uint256 tokenID) external;

    function withdrawStakerFundsWithProfit(address policyBookAddress) external;

    function getSlashedBMIProfit(uint256 tokenId) external view returns (uint256);

    function getBMIProfit(uint256 tokenId) external view returns (uint256);

    function getSlashedStakerBMIProfit(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 totalProfit);

    function getStakerBMIProfit(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 totalProfit);

    function totalStaked(address user) external view returns (uint256);

    function totalStakedSTBL(address user) external view returns (uint256);

    function stakedByNFT(uint256 tokenId) external view returns (uint256);

    function stakedSTBLByNFT(uint256 tokenId) external view returns (uint256);

    function balanceOf(address user) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function uri(uint256 tokenId) external view returns (string memory);

    function tokenOfOwnerByIndex(address user, uint256 index) external view returns (uint256);
}

// 
pragma solidity ^0.7.4;


uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60; // 365 days * 24 hours * 60 minutes * 60 seconds
uint256 constant DAYS_IN_THE_YEAR = 365;
uint256 constant MAX_INT = type(uint256).max;

uint256 constant DECIMALS18 = 10**18;

uint256 constant PRECISION = 10**25;
uint256 constant PERCENTAGE_100 = 100 * PRECISION;

uint256 constant BLOCKS_PER_DAY = 6450;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

uint256 constant APY_TOKENS = DECIMALS18;

uint256 constant PROTOCOL_PERCENTAGE = 20 * PRECISION;

uint256 constant DEFAULT_REBALANCING_THRESHOLD = 10**23;

uint256 constant EPOCH_DAYS_AMOUNT = 7;

// ClaimVoting ClaimingRegistry
uint256 constant APPROVAL_PERCENTAGE = 66 * PRECISION;
uint256 constant PENALTY_THRESHOLD = 11 * PRECISION;
uint256 constant QUORUM = 10 * PRECISION;
uint256 constant CALCULATION_REWARD_PER_DAY = PRECISION;
uint256 constant PERCENTAGE_50 = 50 * PRECISION;

// PolicyBook
uint256 constant MINUMUM_COVERAGE = 100 * DECIMALS18; // 100 STBL
uint256 constant ANNUAL_COVERAGE_TOKENS = MINUMUM_COVERAGE * 10; // 1000 STBL

uint256 constant PREMIUM_DISTRIBUTION_EPOCH = 1 days;
uint256 constant MAX_PREMIUM_DISTRIBUTION_EPOCHS = 90;

// 

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// 

pragma solidity ^0.7.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}