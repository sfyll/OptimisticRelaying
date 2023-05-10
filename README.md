# OptimisticRelaying


Optimistic relays have been gaining market share ever since the ultra sound relay went live on mainnet. They remove latency from the builder submission flow, thereby allowing them to propose blocks with higher proposer rewards. They also minimize centralization effects around relays by lowering barriers to entry via decreased operating costs and reduced incentives for collocation. Ultimately, by making block building more efficient, optimistic relays increase Ethereum’s security budget.

Hence, not only does optimistic architecture have staying power, but it is most likely to grow in market share until further protocol upgrades are pushed onto Ethereum. While most work is being done in minimizing latency around block production activities, not much has been put forward to reduce trust assumptions towards relay. Ironically, the downside of optimistic relaying architecture is that it increases the degree to which relays are trusted.

Fortunately, most of the puzzle pieces have been assembled, and it would require little overhead to implement a solution. By leveraging [Yi Sun](https://github.com/yi-sun/circom-pairing), [succinctlabs](https://github.com/succinctlabs/telepathy-circuits) and the current SSZ encoded builder-proposer communication, relays could publicly show that both the builder and proposer agreed on a specific block. A first step towards trustlessly resolving invalid block dispute could be using a weak proof by deduction where each invalid block and its child have the same parent hash. More importantly, by making such resolution public and programmable, it is against the relay interest to "forge" invalid blocks as the missed reward would go to the proposer while ruining the relay reputation.

Interestingly, they are many upsides to such infrastructure. Running the [circom-pairing vm](https://hackmd.io/V-7Aal05Tiy-ozmzTGBYPA?view) costs around $1 per hour, or $8760 per year vs an [estimated $100,000 per year](https://collective.flashbots.net/t/mev-boost-community-call-1-9-mar-2023/1367/3) for non-optimistic relays vm. Verifying a Groth16 proof on-chain costs approx. 230,000 gas units, but this activity can be subsidized by the faulty block builder.

Furthermore, builders can deposit more collateral, efficiently and confidently. Indeed, it is strongly against relays interests to defraud builders, given that only relays would have the necessary information (Beacon Block Headers, Bid Trace and their respective signatures) and would put their reputation on the line via the transparency of dispute resolution. That means no collateral split per builder-relay relationship and no limit on posted collateral, which would be more in line with the high block value that can be [proposed](https://etherscan.io/tx/0x0bff9cfabf3e532cd30f94cc2cb17a491f3209e9be9140834025a2cc6d7f6b61).

By allowing trustless latency reduction, we can actually [make Ethereum safer](https://www.paradigm.xyz/2023/04/mev-boost-ethereum-consensus). Hence, this seems like a no-brainer. 

I've implemented most of what's been discussed as a zero-knowledge encryption exercise after completing 0xParc’s awesome [class](https://zkiap.com/#34e5b6cf6e1d4dd3901940d4be2edb0b). As such, you can find it on my [**github**](https://github.com/SFYLL/OptimisticRelaying).

You might wonder why I didn't finish it all? Simply because I've already devoted >1.5y of my life to MEV and its optimisations. As such, I refuse to pay, out of my pocket, for more of it to test some circuits. Nonetheless, since that's a net positive for the network, it's worth making it public. Obviously, I am happy to help in getting this through.

See yall in the mempool.

### Quick Start

1. Clone the repository and navigate to the project root directory:

```
git clone https://github.com/SFYLL/OptimisticRelaying.git
cd OptimisticRelaying
```

2. Install dependencies (in virtual env for the sake of your sanity):
```
pip install -r requirements.txt
```

3. run the tests:

```
./run_test.sh
```

### TODOs

To run it in prod:
- Implement BLS signature verification circom circuit, using previous work of [succinctlabs](https://github.com/succinctlabs/telepathy-circuits) and [Yi Sun](https://github.com/yi-sun/circom-pairing)
-	Implement proof of invalid block. A first step could be using a weak proof by deduction where the invalid block and its child have the same parent hash. Can query external protocols such as [axiom](https://www.axiom.xyz)
