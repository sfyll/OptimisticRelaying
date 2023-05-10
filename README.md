# OptimisticRelaying

Write-up: [Here]()

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
