# CLINT

Erbium CLINT is composed of 2 parts: a timer system for timer interrupts and a Local interrupts system, to deliver software interrupts to each hart in Erbium.

The RISC-V timer is a real-time counter for the system.  It provides the processors with a way to measure time at a fixed frequency that is independent of the processor’s frequency.   
Erbium features a single time instance for the CPU subsystem. 

The Local interrupts system allows a hart to send software interrupts to other harts.

Both designs are inherited from ET-SoC1. Design philosophy is to treat Erbium as a derivative of ET-SoC1 and minimize changes between them.

## Mechanism

The CPU subsystem timer is implemented as a 64-bits counter that increments every 100ns (10MHz). When the counter overflows, it wraps around to 0 and continues to increment from there.  Because the counter is 64 bits wide, overflow will occur sometime around 64,000 years.  
The counter is exposed through the mtime register.

The timer is assumed to be connected to a 200 MHz reference clock. To accommodate that to the 10MHz increment, the timer implements a prescaler. Prescaler will increment every 1ns, will increment the timer counter when it reaches the threshold and then reset back to 0\. The threshold is configurable through the time\_config register.

Since the reference clock input is optional, the timer can be configured to work with the internal ring oscillator as a reference clock. This will not generate precise time count but will allow to use the timer interrupts in a standalone device.

Timer interrupts are controlled by the mtimecmp register. This register lives inside the CPU subsystem timer. When the value stored on it is greater than the one exposed by the mtime register, a timer interrupt will be asserted. The interrupt is deasserted when the condition is not met anymore.

Since there is a single mtimecmp register, the timer interrupt is broadcasted between all the harts of the system. The software can control who takes the interrupt using the mtime\_local\_target register and the mie CSR.

Local interrupts can be sent using the mip\_trigger/mipi\_clear registers. Writing 1 on bit N of mipi\_trigger will assert the interrupt for hart N. Writing 1 on bit N of mipi\_clear will de-assert the interrupt for hart N.

## Design Diagram

![clint_diagram](output/clint.png)
