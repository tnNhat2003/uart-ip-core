# Parametric UART Transceiver IP Core with Self-Checking Testbenches

A synthesizable, fully parameterized **UART (Universal Asynchronous Receiver-Transmitter)** IP core designed in Verilog. This core features dynamic runtime configuration, robust hardware handshaking, mid-bit sampling for noise cancellation, and is validated by a rigorous self-checking verification suite.

---

## Hardware Architecture

![UART Hardware Architecture](uart_hardware_architecture.jpg)

The IP consists of two independent, highly optimized FSM-driven blocks:
*   **`UartTx` (Transmitter Engine):** Operates on a 3-state FSM (`POST_RESET`, `IDLE`, `SEND_PACKET`). It features an edge-triggered write-oneshot detector and an integrated parity generator.
*   **`UartRx` (Receiver Engine):** Operates on a 3-state FSM (`IDLE`, `RECEIVE`, `VALIDATE`). It utilizes a mid-bit sampling mechanism (`clock_divider_i / 2`) for noise rejection and validates start, parity, and stop bits.

---

## Key Features

*   **Parametric Baud Rate:** Parameterized clock divider bit-width (`CLOCK_DIVIDER_WIDTH`) optimizes resource utilization depending on target system clocks.
*   **Dynamic Runtime Frame Configuration:** 
    *   **Stop Bits:** Run-time selectable 1 or 2 stop bits (`two_stop_bits_i`).
    *   **Parity:** Run-time configurable parity (`parity_bit_i`, `parity_even_i`) supporting Even, Odd, or No Parity.
*   **Robust Hardware Handshaking:** Prevent data loss and overwrites using edge-triggered `write_i`/`write_busy_o` (TX) and `ack_i`/`read_ready_o` (RX) flow-control ports.
*   **Noise Glitch Rejection:** Confirms start-bit validity at the mid-bit sample point to abort false transactions.

---

## Interface Signal Port Map

### System & Control Registers
*   `clock_i` / `reset_i`: Core system clock and active-high synchronous reset.
*   `clock_divider_i` `[CLOCK_DIVIDER_WIDTH-1:0]`: Defines baud rate timing.

### Configuration Inputs
*   `two_stop_bits_i`: Transmits 2 stop bits if High, 1 if Low.
*   `parity_bit_i`: Enables parity check if High.
*   `parity_even_i`: Even parity if High, Odd parity if Low.

### Physical SerDes & Bus Interface
*   `serial_i` / `serial_o`: UART RX/TX physical lines.
*   `data_i` `[7:0]` / `data_o` `[7:0]`: 8-bit parallel TX/RX data buses.
*   `write_i` / `write_busy_o`: Edge-triggered write strobe and busy indicator.
*   `read_ready_o` / `ack_i`: Receive data-ready flag and acknowledgement strobe.

---

## Verification Suite

The repository contains **15 independent, self-checking testbenches** that execute targeted corner cases to guarantee IP integrity:

| Testbench Category | Target Verifications | Key Test Files |
| :--- | :--- | :--- |
| **Baud Rate & Timing** | Validates data correctness under 1x, 2x, 4x, and 8x clock ratios | `uart_tx_write_1x_test.v`, `uart_rx_read_2x_test.v`, `uart_rx_read_8x_test.v` |
| **Error & Noise Mitigation** | Aborts receipt upon finding invalid start-bits (noise/glitch) | `uart_rx_invalid_start_bit_test.v` |
| **Handshake & Flow Control** | Verifies oneshot triggers and prevents data overwrite under consecutive writes | `uart_tx_overwrite_test.v`, `uart_tx_write_oneshot_test.v`, `uart_rx_overwrite_test.v` |
| **Frame Formatting** | Verifies Parity generation/detection and Stop-bit configuration | `uart_tx_parity_test.v`, `uart_tx_stop_bit_test.v`, `uart_rx_parity_test.v` |
| **Reset & Recovery** | Ensures FSMs properly align and block writes during and immediately after a reset event | `uart_tx_reset_test.v`, `uart_tx_write_reset_test.v` |

All simulations are written in pure synthesizable-friendly Verilog tasks, outputting clear standard-out failures if any protocol timing is breached.
