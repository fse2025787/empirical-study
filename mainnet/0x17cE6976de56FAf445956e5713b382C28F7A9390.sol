// SPDX-License-Identifier: AGPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-01-12
*/

// hevm: flattened sources of src/LerpJob.sol
// 
pragma solidity =0.8.9 >=0.8.0;

////// src/interfaces/IJob.sol
// Copyright (C) 2021 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
/* pragma solidity >=0.8.0; */



interface IJob {

    
    
    
    
    function work(bytes32 network, bytes calldata args) external;

    
    
    
    
    
    
    function workable(bytes32 network) external returns (bool canWork, bytes memory args);

}

////// src/base/TimedJob.sol
// Copyright (C) 2021 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
/* pragma solidity 0.8.9; */

/* import {IJob} from "../interfaces/IJob.sol"; */

interface SequencerLike_4 {
    function isMaster(bytes32 network) external view returns (bool);
}



abstract contract TimedJob is IJob {
    
    SequencerLike_4 public immutable sequencer;
    uint256 public immutable maxDuration;       // The max duration between ticks
    uint256 public last;

    // --- Errors ---
    error NotMaster(bytes32 network);
    error TimerNotElapsed(uint256 currentTime, uint256 expiry);

    constructor(address _sequencer, uint256 _maxDuration) {
        sequencer = SequencerLike_4(_sequencer);
        maxDuration = _maxDuration;
    }

    function work(bytes32 network, bytes calldata) external {
        if (!sequencer.isMaster(network)) revert NotMaster(network);
        uint256 expiry = last + maxDuration;
        if (block.timestamp < expiry) revert TimerNotElapsed(block.timestamp, expiry);
        
        last = block.timestamp;
        update();
    }

    function workable(bytes32 network) external view override returns (bool, bytes memory) {
        if (!sequencer.isMaster(network)) return (false, bytes("Network is not master"));
        if (block.timestamp < last + maxDuration) return (false, bytes("Timer hasn't elapsed"));
        
        return (true, "");
    }

    function update() virtual internal;

}

////// src/LerpJob.sol
// Copyright (C) 2021 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
/* pragma solidity 0.8.9; */

/* import {TimedJob} from "./base/TimedJob.sol"; */

interface LerpFactoryLike {
    function tall() external;
}


contract LerpJob is TimedJob {
    
    LerpFactoryLike public immutable lerpFactory;

    constructor(address _sequencer, address _lerpFactory, uint256 _duration) TimedJob(_sequencer, _duration) {
        lerpFactory = LerpFactoryLike(_lerpFactory);
    }

    function update() internal override {
        lerpFactory.tall();
    }

}