# Financial institutions and manual tracking

PesoFlow is a local-first expense tracker. GCash, Maya/PayMaya, GoTyme, MariBank,
BDO, BPI and other institution names are user-entered labels on manually tracked
financial accounts. They do not establish provider connections or verification.

Users can create cash, e-wallet, bank, savings and credit accounts, edit opening
balances/details, record expenses/income/internal transfers and inspect history.
Card network/final-four metadata is optional and must reflect the actual card.
Debit cards do not create duplicate underlying balances; available credit is
shown separately from cash. Neutral icons are used where licensed logos are absent.

No financial provider SDK, OAuth consent flow, bank credential collection,
Open Finance adapter, scraping, payment initiation, bank sync or reconnect action
is implemented. Historical provider observation fields remain readable for data
compatibility; local entries cannot manufacture a provider-reported balance.
The optional NestJS health endpoint is independent of mobile startup.
