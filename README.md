# UART Receiver with Baud Rate Generator and Parity Checking

## Overview

This project implements a simple UART Receiver in Verilog. The design consists of three major modules:

1. **Baud Rate Generator**
2. **UART Receiver (SIPO)**
3. **Parity and Frame Checker**

The receiver collects an incoming UART frame, stores the received bits into an 11-bit register, performs start-bit, stop-bit, and parity verification, and reports any detected errors.

---

# UART Frame Format

The receiver expects the following UART frame:

| Bit Position | Description |
| ------------ | ----------- |
| 0            | Start Bit   |
| 1-8          | Data Bits   |
| 9            | Parity Bit  |
| 10           | Stop Bit    |

Frame Layout:

```text
[Stop][Parity][D7][D6][D5][D4][D3][D2][D1][D0][Start]
```

Stored inside:

```verilog
concat_data[10:0]
```

---

# Module Hierarchy

```text
test1
│
├── baudrategenerator
│
├── uartrx
│
└── ParityCheckRX
```

---

# Top Module

## Module: test1

### Inputs

| Signal  | Width | Description         |
| ------- | ----- | ------------------- |
| clk1    | 1     | System clock        |
| rate1   | 1     | Baud rate selection |
| reset1  | 1     | Active-high reset   |
| txline1 | 1     | UART serial input   |

### Outputs

| Signal     | Width | Description                         |
| ---------- | ----- | ----------------------------------- |
| done       | 1     | Indicates frame processing complete |
| paritygen1 | 1     | Generated parity                    |
| out1       | 3     | Error status bits                   |

---

# Baud Rate Generator

## Module: baudrategenerator

Generates a baud tick used by the UART receiver FSM.

### Baud Selection

| rate | Baud Mode |
| ---- | --------- |
| 0    | 9600      |
| 1    | 19200     |

### Internal Counter Values

| Baud Rate | Count Limit |
| --------- | ----------- |
| 9600      | 52          |
| 19200     | 26          |

When the counter reaches the selected terminal count:

```verilog
baud <= 1'b1;
```

for one clock cycle.

---

# UART Receiver

## Module: uartrx

Receives serial UART data and stores it into an 11-bit shift register.

### FSM States

| State | Description                    |
| ----- | ------------------------------ |
| IDLE  | Waiting for start bit          |
| START | Start bit verification         |
| DATA  | Receiving data and parity bits |
| STOP  | Stop bit verification          |

### State Diagram

```text
      +------+
      | IDLE |
      +------+
          |
          v
      +-------+
      | START |
      +-------+
          |
          v
      +------+
      | DATA |
      +------+
          |
          v
      +------+
      | STOP |
      +------+
          |
          v
      IDLE
```

---

## Data Storage

### Start Bit

```verilog
concat_data[0]
```

### Data Bits

```verilog
concat_data[1] to concat_data[8]
```

### Parity Bit

```verilog
concat_data[9]
```

### Stop Bit

```verilog
concat_data[10]
```

---

## Data Counter

The receiver uses:

```verilog
reg [3:0] stop_count;
```

to count received bits while in the DATA state.

Transition to STOP occurs when:

```verilog
stop_count == 4'b1001
```

---

## SIPO Enable

The signal:

```verilog
sipoe
```

becomes high in the STOP state indicating that a complete frame has been captured.

---

# Parity and Frame Checker

## Module: ParityCheckRX

Performs:

1. Stop-bit verification
2. Start-bit verification
3. Parity verification

---

## Generated Parity

```verilog
paritygen = ^concatdata[8:1];
```

This performs XOR reduction on all received data bits.

---

# Error Outputs

The output bus:

```verilog
out[2:0]
```

contains frame status information.

## out[0] : Stop Bit Error

| Condition    | Value |
| ------------ | ----- |
| Stop bit = 1 | 0     |
| Stop bit ≠ 1 | 1     |

---

## out[1] : Start Bit Error

| Condition     | Value |
| ------------- | ----- |
| Start bit = 0 | 0     |
| Start bit ≠ 0 | 1     |

---

## out[2] : Parity Error

| Condition       | Value |
| --------------- | ----- |
| Parity matches  | 0     |
| Parity mismatch | 1     |

---

## Error Summary

```text
out[2] = Parity Error
out[1] = Start Bit Error
out[0] = Stop Bit Error
```

Example:

```text
out = 000
```

No errors detected.

```text
out = 001
```

Stop-bit error.

```text
out = 100
```

Parity error.

```text
out = 111
```

Start, stop, and parity errors detected.

---

# Done Signal

Output:

```verilog
not_done
```

is connected to the top-level signal:

```verilog
done
```

Meaning:

| done | Description                |
| ---- | -------------------------- |
| 0    | Frame received and checked |
| 1    | Receiver still processing  |

---

# Reset Behavior

All modules use active-high reset.

Upon reset:

```verilog
state <= IDLE;
count <= 0;
baud <= 0;
stop_count <= 0;
concat_data <= 0;
```

---

# Files

```text
test1.v
├── test1
├── baudrategenerator
├── uartrx
└── ParityCheckRX
```

---

# Future Improvements

* Mid-bit sampling for improved UART robustness.
* Configurable data width.
* Configurable parity modes (Even/Odd/None).
* Multiple stop-bit support.
* Oversampling receiver (8x/16x).
* Receive FIFO for buffering incoming data.
* Error counters and status registers.

---

# Author Notes

This implementation is intended as a learning-oriented UART receiver demonstrating:

* FSM design
* Serial-to-parallel conversion
* Baud rate generation
* Parity checking
* Start/stop bit validation
* Modular RTL design
