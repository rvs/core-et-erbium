#Handshake logic

* It is guaranteed that:
	* After CE is asserted Busy goes high in the same cycle.
	* The Rising Edge of busy does not violate setup/hold constraints.
	* Falling Edge of Busy can violate setup/hold constraints.
* Is CE deasserted after all transactions are completed i.e. Wr +Busy or only after write?
* Depending on the clock frequency, Busy period might be less than a clock cycle or it may span multiple clock cycles.
* The design can be implemented using a BypassFIFO from Bluespec.
* We Need Ckt that:
	* Identified the first transaction condition and enables deq.
	* For other transactions the deq is connected to TxnAcpt.
* Behavior:
	* First transaction is enqueued and dequeued simultaneously.
	* For second transaction
		* if busy is low, txnAcpt is high and txn is enqueued and dequeued simultaneously
		* If busy is high txnAcpt is low and the txn is enqueued in FIFO
	*

| Condition          | Next Condition | Q0 | Q1 | nxt_Busy | busy | tgt |
|                    |                | -- |    |          |      |     |
| Reset              | Reset          | A  | A  | 0        | 0    |  0  |
| Txn1               | Txn2           | A  | A  | 1        | 0    |  0  |

Busy captured
| Txn2               | Txn3           | A_ | A  | 1        | 1    |  1  |
Busy missed
| Txn2 | Txn2 | A | A | 1 | 0 | 0 |
| Txn2 | Txn3 |   |   |   |   |   |
