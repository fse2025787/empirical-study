# MajorIssue-1(Reviewer1&2): In-depth analysis of the detection results.

In the following, we present an in-depth analysis of the algorithm rules employed by each tool and how they align with the overall detection results. Note that all these rules are directly extracted from the tool’s papers or documentation to ensure objectivity.

<!--
Our analysis for each vulnerability includes the following key points:

1. **Summary of Tool Algorithm Rules:** We provide a summary of the algorithmic rules employed by each tool, with these rules directly extracted from the tool’s papers or documentation to ensure objectivity.
2. **Comparison of Similarities and Differences in Algorithm Rules:** We compare the algorithmic rules of different tools, highlighting both their similarities and differences.
3. **Analysis of How Tool Algorithm Rules Align with TP Rate (RQ2):** We analyze how the algorithmic rules of each tool align with its true positive rate.
4. **Analysis of How Tool Algorithm Rules Align with Tool Consistency (RQ3):** We analyze how the algorithmic rules of each tool align with the overlap in their detection results.

## Table of Contents
1. [Reentrancy](#vulnerability-1-reentrancy)
2. [Unprotected SELFDESTRUCT Instruction](#vulnerability-2-unprotected-selfdestruct-instruction)
3. [Authorization through tx.origin](#vulnerability-3-authorization-through-txorigin)
4. [Unprotected Ether Withdrawal](#vulnerability-4-unprotected-ether-withdrawal)
5. [Integer Overflow and Underflow](#vulnerability-5-integer-overflow-and-underflow)

-->

## Vulnerability: Reentrancy
> DASP-Top1 & SWC-107 
### Summary

| Tools | Approach | Level | Detection Rules |
| --------| --- | ---- | ------- |
| [Mythril](https://github.com/muellerberndt/smashing-smart-contracts/blob/master/smashing-smart-contracts-1of1.pdf) | Symbolic Execution | Bytecode	|If an external call to an untrusted address is detected, analyze the control flow graph for possible state changes that occur after the call returns.  |
| [Semgrep](https://github.com/Decurity/semgrep-smart-contracts?tab=readme-ov-file) | Pattern Matching | Source Code	|1. Function `borrowFresh()` in Compound performs state update after `doTransferOut()`. <br>2. ERC677 `callAfterTransfer()` / ERC777 `tokensReceived()` / ERC721 `onERC721Received()`. <br>3. `getRate()`/`getPoolTokens()`/`get_virtual_price()` call on a Balancer pool is not protected from the read-only reentrancy. |
| [Slither](https://dl.acm.org/doi/10.1109/wetseb.2019.00008) | Intermediate Representation Matching | Source Code | A state variable is changed only after an external call (the build-in function `call()`). |
| [Solhint](https://github.com/protofire/solhint/blob/develop/docs/rules/security/reentrancy.md) | Pattern Matching | Source Code	|Avoid state changes after transfer.  |
| [Vandal](https://arxiv.org/abs/1809.03981) | Intermediate Representation Matching | Bytecode	|A call is flagged as reentrant if it forwards sufficient gas and is not protected by a mutex.|


### Comparison

**C1.** Mythril and Slither apply the same general rule (state change after call), which does not account for reentrancy protection.

**C2.** Vandal excludes false positives related to gas checks and mutex protection based on the general rules above.

**C3.** Semgrep targets specific patterns based on actual DeFi exploits.

**C4.** Solhint identifies state changes after the built-in  `send()` and `transfer` functions, but this is an incorrect rule, as these functions are safe due to their gas limitations.



### RQ2 (TP Rate)

![TP Rate](Table6_REN.png)

As shown in the total column of Table 6, Semgrep exhibits the highest true positive rate (TPR), as it targets specific DeFi exploits (**C3**) rather than general reentrancy. Vandal has the second-highest TPR, as it identifies some vulnerability protection techniques (**C2**). Mythril and Slither have similarly low TPRs, as their general rules do not account for any vulnerability protections (**C1**). Solhint’s TPR is nearly zero due to incorrect rules (**C4**).


### RQ3 (Overlap)

![TP Rate](../_RQ3/overlap/upset_data/RQ3_upset_graph_SWC-107.png)

As shown in the UpSet diagram, the six column indicates the greatest overlap between Slither and Vandal, as both use the same intermediate representation matching approach, and their rules are partially similar (**C1**&**C2**). 

Moreover, as seen in the ten column, there is minimal overlap between Slither and Mythril. Although both tools apply the same general rule, Mythril utilizes a symbolic execution approach that faces path explosion issues, limiting its detection capabilities.

The seventh and eighth columns show overlap between Semgrep and Vandal, as well as between Semgrep and Slither, which reflects the fact that the general rule covers some specific rules (**C1**&**C2**&**C3**) to some extent. 

The columns twelve through fifteen illustrate that Solhint has little overlap with other tools (**C4**), due to its incorrect rule.



<!-- ## Vulnerability 2: Unprotected SELFDESTRUCT Instruction
> DASP-Top2 & SWC-106 

### Summary

| Tools | Approach | Level | Detection Rules |
| --------| --- | ---- | ------- |
| Mythril | | | Any sender can trigger execution of the SELFDESTRUCT instruction to destroy this contract account and withdraw its balance to an arbitrary address.|
| Semgrep | | | Contract can be destructed by anyone. |
| Slither | | | slither	Unprotected call to a function executing `selfdestruct`/`suicide`.|
| VeriSmart | | |Given a statement that deactivates contracts, we report a suicidal vulnerability if the statement can be executed by untrusted users.|
| Ethainter | | |  Accessible selfdestruct vulnerability is more commonly encountered in combination with a tainted guard.|
| Vandal | | | Any code path leading to a selfdestruct instruction, that can be executed by an arbitrary caller.|

### Comparison

### RQ2

### RQ3


## Vulnerability 3: Authorization through tx.origin
> DASP-Top2 & SWC-115 

### Summary

| Tools | Approach | Level | Detection Rules |
| --------| --- | ---- | ------- |
| Mythril | | | Currently we just point out the usage of `tx.origin`. We should check whether it is being used in some sort of authorization.(like `require()`)|
| SmartCheck | | | The pattern detects the environmental variable `tx.origin`.|
| Slither | | | `tx.origin`-based protection can be abused by a malicious contract if a legitimate user interacts with the malicious contract.|
| Solhint | | | Avoid to use `tx.origin`.|
| Vandal | | | Checking that an origin instruction exists, and that its result is used in some other potentially sensitive operation such as a conditional or a write to storage.|
| SolidityCheck | | | Using `tx.origin` for authentication.|

### Comparison

### RQ2

### RQ3

## Vulnerability 4: Unprotected Ether Withdrawal
> DASP-Top2 & SWC-105 

### Summary
| Tools | Approach | Level | Detection Rules |
| --------| --- | ---- | ------- |
| Mythril | | | An issue is reported if there is a valid end state where the attacker has successfully increased their Ether balance. |
| Semgrep | | | Function `sweepToken` is allowed to be called by anyone.|
| Slither | | | Unprotected call to a function sending Ether to an arbitrary address. |
| VeriSmart | | | Given a statement that sends Ethers to accounts, we report a leaking vulnerability if the contract leaks Ethers to an untrusted user and the amount of the leaked Ethers is greater than the amount of Ethers sent from the untrusted user. |
| Ethainter | | | With a tainted selfdestruct vulnerability, the receiving address of the funds can be controlled by any user of the contract. |
| Vandal | | | If an arbitrary caller can force it to transfer Ether, and can manipulate the address to which that Ether is transferred. |


### Comparison

### RQ2

### RQ3

## Vulnerability 5: Integer Overflow and Underflow
> DASP-Top3 & SWC-101 

### Summary

| Tools | Approach | Level | Detection Rules |
| --------| --- | ---- | ------- |
| Mythril | | | For every SUB instruction, check if there's a possible state where op1 > op0. For every ADD, MUL instruction, check if  there's a possible state where op1 + op0 > 2^32 - 1.|
| SmartCheck | | | The pattern detects arithmetic operations +, -, *, which are not inside a conditional statement. This rule was temporarily muted for testing (Section 4) due to a high false positive rate. |
| Semgrep | | | basic-arithmetic-underflow：Possible arithmetic underflow. |
| MadMax | | | Loop overflows are conservatively asserted to be likely if the induction variable is cast to a short integer or ideally one byte. The loop has to be łdynamically boundž to be vulnerable, i.e., the number of iterations is determined by some run-time value. |
| VeriSmart | | | when we want to check whether a contract contains integer overflow vulnerabilities, given an assignment x := y+z, we assume an assertion assert(y+z >= y) is inserted right before the assignment. |

### Comparison

### RQ2

### RQ3

-->