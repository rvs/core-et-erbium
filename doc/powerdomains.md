# Power Domains.

There  power domains in the design are:

* CPU
* MRAM
* Hyperbus
* ChipID
* Chiplet

The state of Hyperbus and Chiplet powerdomains are based on the chipmode signal.

MRAM powerdomain is based on the MRAM deepsleep bit.
ChipID powerdomain is based on the chipid lock logic.
CPU Power domain is TODO
