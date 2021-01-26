import { parseUnits } from 'ethers/lib/utils';
import { run, ethers } from 'hardhat';

import DisbursementArtifact from '../artifacts/contracts/Disbursement.sol/Disbursement.json';
import { DisbursementFactory } from '../typechain/DisbursementFactory';

async function main() {
	await run('typechain');
	const signer = await ethers.getSigners();

	try {
		const disbursementFactory = (new ethers.ContractFactory(
			DisbursementArtifact.abi,
			DisbursementArtifact.bytecode,
			signer[0]
		) as any) as DisbursementFactory;

		const claimPercentage = parseUnits('55596419', 7);
		const claimant = '0x8943eb8F104bCf826910e7d2f4D59edfe018e0e7';

		const disbursement = await disbursementFactory.deploy(claimant, claimPercentage);

		console.log(disbursement.address);
	} catch (error) {}
}

main().then(() => process.exit(0)).catch((error) => {
	console.error(error);
	process.exit(1);
});
