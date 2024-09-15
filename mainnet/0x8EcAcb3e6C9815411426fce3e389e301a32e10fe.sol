// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.12;





///
interface ITPLBodyParts {
    error UnknownPart();

    enum BodyParts {
        ARM,
        HEAD,
        BODY,
        LEGS,
        ENGINE
    }

    enum BodyPartModel {
        ENFORCER,
        RAVAGER,
        BEHEMOTH,
        LUPIS,
        NEXUS
    }

    function getBodyPart(uint256 generationId, uint256 partId) external view returns (uint256);

    function getBodyPartModel(uint256 generationId, uint256 partId) external view returns (uint256);
}

// 
pragma solidity ^0.8.12;







///
contract TPLBodyParts is ITPLBodyParts {
    
    
    
    
    function getBodyPart(uint256 generationId, uint256 partId) public pure returns (uint256) {
        if (partId <= 2 || (partId >= 18 && partId <= 21)) {
            return uint256(BodyParts.ARM);
        } else if (partId >= 8 && partId <= 12) {
            return uint256(BodyParts.HEAD);
        } else if (partId >= 13 && partId <= 17) {
            return uint256(BodyParts.BODY);
        } else if (partId >= 22 && partId <= 26) {
            return uint256(BodyParts.LEGS);
        } else if (partId >= 3 && partId <= 7) {
            return uint256(BodyParts.ENGINE);
        }

        revert UnknownPart();
    }

    
    
    
    
    
    function getBodyPartModel(uint256 generationId, uint256 partId) public pure returns (uint256) {
        if (partId <= 13) {
            if (partId <= 6) {
                if (partId <= 3) {
                    if (partId == 1) {
                        return uint256(BodyPartModel.ENFORCER);
                    }
                    if (partId == 2) {
                        return uint256(BodyPartModel.LUPIS);
                    }
                    if (partId == 3) {
                        return uint256(BodyPartModel.ENFORCER);
                    }
                } else {
                    if (partId == 4) {
                        return uint256(BodyPartModel.RAVAGER);
                    }
                    if (partId == 5) {
                        return uint256(BodyPartModel.BEHEMOTH);
                    }
                    if (partId == 6) {
                        return uint256(BodyPartModel.LUPIS);
                    }
                }
            } else {
                if (partId <= 10) {
                    if (partId == 7) {
                        return uint256(BodyPartModel.NEXUS);
                    }
                    if (partId == 8) {
                        return uint256(BodyPartModel.ENFORCER);
                    }
                    if (partId == 9) {
                        return uint256(BodyPartModel.RAVAGER);
                    }
                    if (partId == 10) {
                        return uint256(BodyPartModel.BEHEMOTH);
                    }
                } else {
                    if (partId == 11) {
                        return uint256(BodyPartModel.LUPIS);
                    }
                    if (partId == 12) {
                        return uint256(BodyPartModel.NEXUS);
                    }
                    if (partId == 13) {
                        return uint256(BodyPartModel.ENFORCER);
                    }
                }
            }
        } else {
            if (partId <= 20) {
                if (partId <= 17) {
                    if (partId == 14) {
                        return uint256(BodyPartModel.RAVAGER);
                    }
                    if (partId == 15) {
                        return uint256(BodyPartModel.BEHEMOTH);
                    }
                    if (partId == 16) {
                        return uint256(BodyPartModel.LUPIS);
                    }
                    if (partId == 17) {
                        return uint256(BodyPartModel.NEXUS);
                    }
                } else {
                    if (partId == 18) {
                        return uint256(BodyPartModel.RAVAGER);
                    }
                    if (partId == 19) {
                        return uint256(BodyPartModel.BEHEMOTH);
                    }
                    if (partId == 20) {
                        return uint256(BodyPartModel.LUPIS);
                    }
                }
            } else {
                if (partId <= 23) {
                    if (partId == 21) {
                        return uint256(BodyPartModel.NEXUS);
                    }
                    if (partId == 22) {
                        return uint256(BodyPartModel.ENFORCER);
                    }
                    if (partId == 23) {
                        return uint256(BodyPartModel.RAVAGER);
                    }
                } else {
                    if (partId == 24) {
                        return uint256(BodyPartModel.BEHEMOTH);
                    }
                    if (partId == 25) {
                        return uint256(BodyPartModel.LUPIS);
                    }
                    if (partId == 26) {
                        return uint256(BodyPartModel.NEXUS);
                    }
                }
            }
        }

        revert UnknownPart();
    }
}